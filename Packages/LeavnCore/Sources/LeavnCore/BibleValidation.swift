import Foundation

// MARK: - Bible Validation Utilities
public enum BibleValidation {
    
    // MARK: - Supported Books
    /// Books that are available in most standard Bible translations
    public static let supportedBooks: Set<String> = {
        // Old Testament (39 books)
        let oldTestament: Set<String> = [
            "gen", "exo", "lev", "num", "deu", "jos", "jdg", "rut",
            "1sa", "2sa", "1ki", "2ki", "1ch", "2ch", "ezr", "neh",
            "est", "job", "psa", "pro", "ecc", "sng", "isa", "jer",
            "lam", "ezk", "dan", "hos", "jol", "amo", "oba", "jon",
            "mic", "nam", "hab", "zep", "hag", "zec", "mal"
        ]
        
        // New Testament (27 books)
        let newTestament: Set<String> = [
            "mat", "mrk", "luk", "jhn", "act", "rom", "1co", "2co",
            "gal", "eph", "php", "col", "1th", "2th", "1ti", "2ti",
            "tit", "phm", "heb", "jas", "1pe", "2pe", "1jn", "2jn",
            "3jn", "jud", "rev"
        ]
        
        return oldTestament.union(newTestament)
    }()
    
    // MARK: - Validation Methods
    
    /// Checks if a book is supported by standard Bible APIs
    public static func isBookSupported(_ book: BibleBook) -> Bool {
        return supportedBooks.contains(book.id.lowercased())
    }
    
    /// Checks if a chapter is valid for a given book
    public static func isChapterValid(for book: BibleBook, chapter: Int) -> Bool {
        guard isBookSupported(book) else { return false }
        return chapter > 0 && chapter <= book.chapterCount
    }
    
    /// Checks if a verse is likely valid (basic range check)
    public static func isVerseValid(for book: BibleBook, chapter: Int, verse: Int) -> Bool {
        guard isChapterValid(for: book, chapter: chapter) else { return false }
        return verse > 0 && verse <= 200 // Most chapters have < 200 verses
    }
    
    /// Returns only supported books from BibleBook.allCases
    public static var supportedBibleBooks: [BibleBook] {
        BibleBook.allCases.filter { isBookSupported($0) }
    }
    
    /// Pre-flight check for async operations
    public static func canLoadChapter(book: BibleBook?, chapter: Int) -> Bool {
        guard let book = book else { return false }
        return isChapterValid(for: book, chapter: chapter)
    }
}

// MARK: - User-Friendly Error Messages
public extension BibleValidation {
    enum ErrorMessage {
        public static func unsupportedBook(_ book: BibleBook) -> String {
            "\(book.name) is not available in your current Bible version."
        }
        
        public static func invalidChapter(_ chapter: Int, book: BibleBook) -> String {
            "Chapter \(chapter) does not exist in \(book.name)."
        }
        
        public static func invalidVerse(_ verse: Int) -> String {
            "Verse \(verse) could not be found."
        }
        
        public static let genericUnavailable = "This content is currently unavailable."
    }
}

// MARK: - Bible Error
public enum BibleError: LocalizedError {
    case unsupportedBook(BibleBook)
    case invalidChapter(Int, BibleBook)
    case invalidVerse(Int)
    case contentUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedBook(let book):
            return BibleValidation.ErrorMessage.unsupportedBook(book)
        case .invalidChapter(let chapter, let book):
            return BibleValidation.ErrorMessage.invalidChapter(chapter, book: book)
        case .invalidVerse(let verse):
            return BibleValidation.ErrorMessage.invalidVerse(verse)
        case .contentUnavailable:
            return BibleValidation.ErrorMessage.genericUnavailable
        }
    }
}