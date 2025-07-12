import Foundation

public protocol BibleRepositoryProtocol {
    // Book operations
    func fetchAllBooks() async throws -> [BibleBook]
    func fetchBook(withId id: String) async throws -> BibleBook?
    func searchBooks(query: String) async throws -> [BibleBook]
    
    // Chapter operations
    func fetchChapter(bookId: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter
    func fetchChapterCount(for bookId: String) async throws -> Int
    
    // Verse operations
    func fetchVerse(bookId: String, chapter: Int, verse: Int, translation: BibleTranslation) async throws -> BibleVerse?
    func fetchVerses(bookId: String, chapter: Int, translation: BibleTranslation) async throws -> [BibleVerse]
    func searchVerses(query: String, translation: BibleTranslation, books: [String]?) async throws -> [BibleVerse]
    
    // Translation operations
    func fetchAvailableTranslations() async throws -> [BibleTranslation]
    func fetchVersesInTranslations(bookId: String, chapter: Int, verse: Int, translations: [BibleTranslation]) async throws -> [BibleVerse]
    
    // Reading plan operations
    func fetchDailyVerse() async throws -> BibleVerse
    func fetchReadingPlan(type: String) async throws -> [BibleVerse]
}

public protocol BibleAnnotationRepositoryProtocol {
    // Highlight operations
    func fetchHighlights() async throws -> [VerseHighlight]
    func fetchHighlight(for verseId: String) async throws -> VerseHighlight?
    func saveHighlight(_ highlight: VerseHighlight) async throws
    func deleteHighlight(_ highlight: VerseHighlight) async throws
    
    // Bookmark operations
    func fetchBookmarks() async throws -> [VerseBookmark]
    func fetchBookmark(for verseId: String) async throws -> VerseBookmark?
    func saveBookmark(_ bookmark: VerseBookmark) async throws
    func updateBookmark(_ bookmark: VerseBookmark) async throws
    func deleteBookmark(_ bookmark: VerseBookmark) async throws
    
    // Note operations
    func fetchNotes(for verseId: String) async throws -> [String]
    func saveNote(for verseId: String, note: String) async throws
}

public protocol BibleInsightRepositoryProtocol {
    func fetchInsights(for verseId: String) async throws -> [VerseInsight]
    func generateInsight(for verse: BibleVerse, type: VerseInsight.InsightType) async throws -> VerseInsight
    func saveInsight(_ insight: VerseInsight) async throws
    func deleteInsight(_ insight: VerseInsight) async throws
}