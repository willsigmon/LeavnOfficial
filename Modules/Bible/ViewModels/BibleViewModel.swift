import Foundation
import LeavnCore
import LeavnServices
import SwiftUI
import Combine

@MainActor
public final class BibleViewModel: ObservableObject, Sendable {
    // MARK: - Published Properties
    @Published public var currentBook: BibleBook?
    @Published public var currentChapter: Int = 1
    @Published public var verses: [BibleVerse] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var currentTranslation: BibleTranslation = .kjv
    @Published public var highlightedVerses: Set<String> = []
    
    // MARK: - Services
    private let bibleService: BibleServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let libraryService: LibraryServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    // MARK: - Computed Properties
    public var canGoPrevious: Bool {
        guard let book = currentBook else { return false }
        return currentChapter > 1 || (BibleBook.allCases.firstIndex(of: book) ?? 0) > 0
    }
    
    public var canGoNext: Bool {
        guard let book = currentBook else { return false }
        return currentChapter < book.chapterCount || (BibleBook.allCases.firstIndex(of: book) ?? 0) < BibleBook.allCases.count - 1
    }
    
    // MARK: - Initialization
    public init(
        bibleService: BibleServiceProtocol? = nil,
        cacheService: CacheServiceProtocol? = nil,
        libraryService: LibraryServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        // Use provided services or resolve from container
        self.bibleService = bibleService ?? DIContainer.shared.requireBibleService()
        self.cacheService = cacheService ?? DIContainer.shared.requireCacheService()
        self.libraryService = libraryService ?? DIContainer.shared.requireLibraryService()
        self.analyticsService = analyticsService ?? DIContainer.shared.analyticsService
        
        loadSavedPosition()
    }
    
    // MARK: - Public Methods
    public func loadInitialData() async {
        if currentBook == nil {
            currentBook = .genesis
        }
        guard let book = currentBook else { return }
        
        // Load offline content immediately if available
        if let offlineChapter = OfflineBibleData.getOfflineChapter(bookId: book.id, chapter: currentChapter) {
            await MainActor.run {
                self.verses = offlineChapter.verses
                self.currentBook = book
                self.currentChapter = currentChapter
            }
        }
        
        // Then try to load from cache/API in background
        await loadChapter(book: book, chapter: currentChapter)
    }
    
    public func loadChapter(book: BibleBook, chapter: Int) async {
        isLoading = true
        error = nil
        
        do {
            // First check cache
            let cacheKey = "verses_\(book.id)_\(chapter)_\(currentTranslation.id)"
            if let cachedVerses: [BibleVerse] = await cacheService.get(cacheKey, type: [BibleVerse].self) {
                self.verses = cachedVerses
                self.currentBook = book
                self.currentChapter = chapter
                savePosition()
            } else {
                // Fetch from API
                let chapterData = try await bibleService.getChapter(
                    book: book.id,
                    chapter: chapter,
                    translation: currentTranslation
                )
                
                self.verses = chapterData.verses
                self.currentBook = book
                self.currentChapter = chapter
                
                // Cache the result
                await cacheService.set(cacheKey, value: chapterData.verses, expirationDate: nil)
                savePosition()
            }
            
            // Track analytics
            await analyticsService?.track(event: AnalyticsEvent(
                name: "chapter_loaded",
                parameters: [
                    "book": book.name,
                    "chapter": String(chapter),
                    "translation": currentTranslation.name
                ]
            ))
            
            // Load highlights for these verses
            await loadHighlights()
            
        } catch {
            self.error = error
            logError("Failed to load chapter", error: error, category: .database)
        }
        
        isLoading = false
    }
    
    public func nextChapter() {
        guard let book = currentBook else { return }
        
        if currentChapter < book.chapterCount {
            Task {
                await loadChapter(book: book, chapter: currentChapter + 1)
            }
        } else if let currentIndex = BibleBook.allCases.firstIndex(of: book),
                  currentIndex < BibleBook.allCases.count - 1 {
            let nextBook = Array(BibleBook.allCases)[currentIndex + 1]
            Task {
                await loadChapter(book: nextBook, chapter: 1)
            }
        }
    }
    
    public func previousChapter() {
        guard let book = currentBook else { return }
        
        if currentChapter > 1 {
            Task {
                await loadChapter(book: book, chapter: currentChapter - 1)
            }
        } else if let currentIndex = BibleBook.allCases.firstIndex(of: book),
                  currentIndex > 0 {
            let previousBook = Array(BibleBook.allCases)[currentIndex - 1]
            Task {
                await loadChapter(book: previousBook, chapter: previousBook.chapterCount)
            }
        }
    }
    
    public func toggleHighlight(verse: BibleVerse) async {
        if highlightedVerses.contains(verse.id) {
            highlightedVerses.remove(verse.id)
            try? await libraryService.removeHighlight(verse.id)
        } else {
            highlightedVerses.insert(verse.id)
            let highlight = Highlight(id: UUID().uuidString, verse: verse, colorIndex: 0, createdAt: Date())
            try? await libraryService.addHighlight(highlight)
        }
    }
    
    public func addToFavorites(verse: BibleVerse) async {
        let bookmark = Bookmark(id: UUID().uuidString, verse: verse, note: nil, tags: ["favorite"], createdAt: Date())
        try? await libraryService.addBookmark(bookmark)
        
        await analyticsService?.track(event: AnalyticsEvent(
            name: "verse_favorited",
            parameters: [
                "book": verse.bookName,
                "chapter": String(verse.chapter),
                "verse": String(verse.verse),
                "translation": verse.translation
            ]
        ))
        
        // Show achievement if first favorite
        let favorites = (try? await libraryService.getBookmarksByTag("favorite")) ?? []
        if favorites.count == 1 {
            // Note: Achievement notification temporarily disabled due to access level
            // TODO: Make sendAchievementNotification public or create alternative
        }
    }
    
    // MARK: - Private Methods
    private func loadHighlights() async {
        let highlights = (try? await libraryService.getHighlights()) ?? []
        highlightedVerses = Set(highlights.map { $0.verse.id })
    }
    
    private func savePosition() {
        UserDefaults.standard.set(currentBook?.id, forKey: "lastBook")
        UserDefaults.standard.set(currentChapter, forKey: "lastChapter")
    }
    
    private func loadSavedPosition() {
        if let bookId = UserDefaults.standard.string(forKey: "lastBook") {
            currentBook = BibleBook(from: bookId)
        }
        
        let savedChapter = UserDefaults.standard.integer(forKey: "lastChapter")
        if savedChapter > 0 {
            currentChapter = savedChapter
        }
    }
}

// MARK: - Supporting Models
// Using BibleBook and BibleVerse from LeavnCore
