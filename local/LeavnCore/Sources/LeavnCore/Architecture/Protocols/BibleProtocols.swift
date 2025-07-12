import Foundation

// MARK: - Repository Protocols

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

// MARK: - Use Case Protocols

public protocol GetBibleChapterUseCaseProtocol {
    func execute(bookId: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter
}

public protocol GetDailyVerseUseCaseProtocol {
    func execute() async throws -> BibleVerse
}

public protocol CompareTranslationsUseCaseProtocol {
    func execute(bookId: String, chapter: Int, verse: Int, translations: [BibleTranslation]) async throws -> [BibleVerse]
}

public protocol ManageBookmarksUseCaseProtocol {
    func getBookmarks() async throws -> [VerseBookmark]
    func addBookmark(verse: BibleVerse, note: String?, tags: [String]) async throws -> VerseBookmark
    func updateBookmark(_ bookmark: VerseBookmark) async throws
    func deleteBookmark(_ bookmark: VerseBookmark) async throws
    func isBookmarked(verseId: String) async throws -> Bool
}

public protocol GenerateVerseInsightUseCaseProtocol {
    func execute(for verse: BibleVerse, type: VerseInsight.InsightType) async throws -> VerseInsight
    func getCachedInsights(for verseId: String) async throws -> [VerseInsight]
}

// MARK: - Models (extend existing if needed)

public struct VerseHighlight: Identifiable, Codable, Equatable {
    public let id: UUID
    public let verseId: String
    public let color: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        verseId: String,
        color: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.verseId = verseId
        self.color = color
        self.createdAt = createdAt
    }
}

public struct VerseBookmark: Identifiable, Codable, Equatable {
    public let id: UUID
    public let verse: BibleVerse
    public let note: String?
    public let tags: [String]
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        verse: BibleVerse,
        note: String? = nil,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.verse = verse
        self.note = note
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct VerseInsight: Identifiable, Codable, Equatable {
    public let id: UUID
    public let verseId: String
    public let type: InsightType
    public let content: String
    public let createdAt: Date
    
    public enum InsightType: String, Codable, CaseIterable {
        case theological = "Theological"
        case historical = "Historical"
        case practical = "Practical"
        case crossReference = "Cross Reference"
    }
    
    public init(
        id: UUID = UUID(),
        verseId: String,
        type: InsightType,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.verseId = verseId
        self.type = type
        self.content = content
        self.createdAt = createdAt
    }
}