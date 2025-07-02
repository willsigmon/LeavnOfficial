import Foundation
import LeavnCore
import LeavnServices
import SwiftUI
import Combine

@MainActor
public final class BibleReaderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var verses: [BibleVerse] = []
    @Published public private(set) var currentBook: BibleBook
    @Published public private(set) var currentChapter: Int
    @Published public private(set) var currentTranslation: BibleTranslation
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    @Published public var fontSize: CGFloat = 18.0
    @Published public private(set) var highlightedVerses: Set<String> = []
    @Published public var scrollToVerse: String?
    
    // MARK: - Dependencies
    private let bibleService: BibleServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let supportedTranslations = ["ESV", "NIV", "NASB", "KJV", "MSG", "NLT"]
    
    // MARK: - Computed Properties
    var navigationTitle: String {
        "\(currentBook.name) \(currentChapter)"
    }
    
    var chapterButtonTitle: String {
        "Chapter \(currentChapter)"
    }
    
    // MARK: - Initialization
    public init(
        book: BibleBook? = nil,
        chapter: Int = 1,
        translation: BibleTranslation = .kjv,
        bibleService: BibleServiceProtocol? = nil,
        cacheService: CacheServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.bibleService = bibleService ?? container.requireBibleService()
        self.cacheService = cacheService ?? container.requireCacheService()
        self.analyticsService = analyticsService ?? container.analyticsService
        
        // Set initial state
        self.currentBook = book ?? BibleBook.genesis
        self.currentChapter = chapter
        self.currentTranslation = translation
        
        // Load initial data
        Task {
            await loadChapter()
        }
    }
    
    // MARK: - Public Methods
    
    public func loadChapter() async {
        isLoading = true
        error = nil
        
        do {
            let chapter = try await bibleService.getChapter(
                book: currentBook.id,
                chapter: currentChapter,
                translation: currentTranslation
            )
            
            await MainActor.run {
                self.verses = chapter.verses
                self.isLoading = false
                
                // Track the chapter view
                Task {
                    await self.analyticsService?.track(event: AnalyticsEvent(
                        name: "chapter_viewed",
                        parameters: [
                            "book": self.currentBook.name,
                            "chapter": "\(self.currentChapter)",
                            "translation": self.currentTranslation.abbreviation
                        ]
                    ))
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
                // Load sample verses as fallback
                self.verses = BibleConstants.SampleData.sampleChapter
            }
        }
    }
    
    public func reloadChapter() async {
        await loadChapter()
    }
    
    public func selectBook(_ book: BibleBook) {
        currentBook = book
        currentChapter = 1
        Task {
            await loadChapter()
        }
    }
    
    public func selectChapter(_ chapter: Int) {
        currentChapter = chapter
        Task {
            await loadChapter()
        }
    }
    
    public func selectTranslation(_ translation: BibleTranslation) {
        currentTranslation = translation
        saveUserPreferences()
        Task {
            await loadChapter()
        }
    }
    
    public func loadComparisons(for verse: BibleVerse) async {
        "\(currentBook.name) \(currentChapter)"
    }
    
    public func nextChapter() {
        if currentChapter < (currentBook.chapterCount ?? 0) {
            currentChapter += 1
        } else if let nextBook = BibleConstants.nextBook(after: currentBook) {
            currentBook = nextBook
            currentChapter = 1
        }
        Task {
            await loadChapter()
        }
    }
    
    public func previousChapter() {
        if currentChapter > 1 {
            currentChapter -= 1
        } else if let previousBook = BibleConstants.previousBook(before: currentBook) {
            currentBook = previousBook
            currentChapter = previousBook.chapterCount ?? 1
        }
        Task {
            await loadChapter()
        }
    }
    
    func toggleVerseHighlight(_ verse: BibleVerse) {
        if highlightedVerses.contains(verse.id) {
            highlightedVerses.remove(verse.id)
        } else {
            highlightedVerses.insert(verse.id)
        }
    }
    
    func selectVerse(_ verse: BibleVerse) {
        // Used for long press actions
    }
    
    func increaseFontSize() {
        fontSize = min(fontSize + 2, 36)
        saveUserPreferences()
    }
    
    func decreaseFontSize() {
        fontSize = max(fontSize - 2, 12)
        saveUserPreferences()
    }
    
    func scrollToVerse(id: String) {
        scrollToVerse = id
    }
    
    // MARK: - Private Methods
    
    private func loadUserPreferences() {
        // Load font size from UserDefaults
        if let savedFontSize = UserDefaults.standard.object(forKey: "bibleReaderFontSize") as? CGFloat {
            fontSize = savedFontSize
        }
        
        // Load translation from UserDefaults if available
        if let translationData = UserDefaults.standard.data(forKey: "selectedBibleTranslation"),
           let translation = try? JSONDecoder().decode(BibleTranslation.self, from: translationData) {
            currentTranslation = translation
        }
    }
    
    private func saveUserPreferences() {
        UserDefaults.standard.set(Double(fontSize), forKey: "bibleFontSize")
        UserDefaults.standard.set(currentTranslation.abbreviation, forKey: "defaultTranslation")
    }
}
