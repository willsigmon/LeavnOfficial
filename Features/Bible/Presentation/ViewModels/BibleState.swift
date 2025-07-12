import Foundation

public struct BibleState: Equatable {
    // Current reading state
    public var currentBook: BibleBook?
    public var currentChapter: BibleChapter?
    public var currentTranslation: BibleTranslation = .niv
    
    // Data
    public var books: [BibleBook] = []
    public var availableTranslations: [BibleTranslation] = []
    public var dailyVerse: BibleVerse?
    
    // Annotations
    public var bookmarks: [VerseBookmark] = []
    public var highlights: [VerseHighlight] = []
    public var insights: [String: [VerseInsight]] = [:] // verseId -> insights
    
    // UI State
    public var isLoadingChapter = false
    public var isLoadingBooks = false
    public var isGeneratingInsight = false
    public var searchQuery = ""
    public var filteredBooks: [BibleBook] = []
    
    // Reading preferences
    public var readingConfig = BibleReadingConfig.default
    
    // Error handling
    public var error: Error?
    
    public static func == (lhs: BibleState, rhs: BibleState) -> Bool {
        lhs.currentBook == rhs.currentBook &&
        lhs.currentChapter == rhs.currentChapter &&
        lhs.currentTranslation == rhs.currentTranslation &&
        lhs.books == rhs.books &&
        lhs.availableTranslations == rhs.availableTranslations &&
        lhs.dailyVerse == rhs.dailyVerse &&
        lhs.bookmarks == rhs.bookmarks &&
        lhs.highlights == rhs.highlights &&
        lhs.isLoadingChapter == rhs.isLoadingChapter &&
        lhs.isLoadingBooks == rhs.isLoadingBooks &&
        lhs.isGeneratingInsight == rhs.isGeneratingInsight &&
        lhs.searchQuery == rhs.searchQuery &&
        lhs.filteredBooks == rhs.filteredBooks &&
        lhs.readingConfig == rhs.readingConfig &&
        (lhs.error == nil && rhs.error == nil || lhs.error != nil && rhs.error != nil)
    }
    
    // Computed properties
    public var hasCurrentChapter: Bool {
        currentChapter != nil
    }
    
    public var currentReference: String? {
        guard let book = currentBook, let chapter = currentChapter else { return nil }
        return "\(book.name) \(chapter.number)"
    }
    
    public var isVerseBookmarked: (String) -> Bool {
        return { verseId in
            self.bookmarks.contains { $0.verse.id == verseId }
        }
    }
    
    public var isVerseHighlighted: (String) -> Bool {
        return { verseId in
            self.highlights.contains { $0.verseId == verseId }
        }
    }
    
    public var highlightColor: (String) -> String? {
        return { verseId in
            self.highlights.first { $0.verseId == verseId }?.color
        }
    }
}