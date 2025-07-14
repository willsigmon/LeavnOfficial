import Foundation
import SwiftUI
import Combine

@MainActor
class BibleViewModel: BaseViewModel {
    @Published var selectedBook: String = "Genesis"
    @Published var selectedChapter: Int = 1
    @Published var selectedTranslation: String = "ESV"
    @Published var books: [BibleBook] = []
    @Published var currentChapter: BibleChapter?
    @Published var availableTranslations: [BibleTranslation] = []
    @Published var chapterLoadingState = LoadingState<BibleChapter>.idle
    
    internal let bibleService: BibleServiceProtocol
    internal let userDataManager: UserDataManagerProtocol
    internal let analyticsService: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        bibleService: BibleServiceProtocol? = nil,
        userDataManager: UserDataManagerProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.bibleService = bibleService ?? container.bibleService
        self.userDataManager = userDataManager ?? container.userDataManager
        self.analyticsService = analyticsService ?? container.analyticsService
        
        super.init()
        
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        execute({
            // Load available translations
            self.availableTranslations = try await self.bibleService.getAvailableTranslations()
            
            // Load the current chapter
            await self.loadChapter()
            
            // Track analytics
            self.analyticsService.track(event: "bible_opened", properties: [
                "translation": self.selectedTranslation,
                "book": self.selectedBook,
                "chapter": self.selectedChapter
            ])
        }, onError: { error in
            // For initial load, we still want to show something
            self.handle(error: error) {
                Task { await self.loadInitialData() }
            }
        })
    }
    
    func loadChapter() async {
        chapterLoadingState = .loading
        
        do {
            let chapter = try await bibleService.getChapter(
                book: selectedBook,
                chapter: selectedChapter,
                translation: selectedTranslation
            )
            currentChapter = chapter
            chapterLoadingState = .loaded(chapter)
        } catch {
            chapterLoadingState = .error(error)
            handle(error: error) {
                Task { await self.loadChapter() }
            }
        }
    }
    
    func selectBook(_ book: String) {
        selectedBook = book
        selectedChapter = 1
        
        Task {
            await loadChapter()
        }
        
        analyticsService.track(event: "book_selected", properties: ["book": book])
    }
    
    func selectChapter(_ chapter: Int) {
        selectedChapter = chapter
        
        Task {
            await loadChapter()
        }
        
        analyticsService.track(event: "chapter_selected", properties: [
            "book": selectedBook,
            "chapter": chapter
        ])
    }
    
    func selectTranslation(_ translation: String) {
        selectedTranslation = translation
        
        Task {
            await loadChapter()
        }
        
        analyticsService.track(event: "translation_selected", properties: ["translation": translation])
    }
    
    func searchVerses(query: String) async -> [BibleVerse] {
        do {
            let results = try await bibleService.searchVerses(
                query: query,
                translation: selectedTranslation
            )
            
            analyticsService.track(event: "verse_search", properties: [
                "query": query,
                "translation": selectedTranslation,
                "results_count": results.count
            ])
            
            return results
        } catch {
            self.error = error
            print("Search failed: \(error)")
            return []
        }
    }
    
    func getDailyVerse() async -> BibleVerse? {
        do {
            let verse = try await bibleService.getDailyVerse()
            
            analyticsService.track(event: "daily_verse_viewed", properties: [
                "verse": verse.reference
            ])
            
            return verse
        } catch {
            self.error = error
            print("Failed to get daily verse: \(error)")
            return nil
        }
    }
}

// MARK: - SwiftUI Environment Integration

extension View {
    func withBibleViewModel() -> some View {
        self.environmentObject(BibleViewModel())
    }
}