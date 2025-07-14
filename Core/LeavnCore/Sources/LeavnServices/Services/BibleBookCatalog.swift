import Foundation

// MARK: - Bible Book Catalog
public final class BibleBookCatalog {
    private let supportedTranslations: [BibleTranslation]
    private let bibleBooks: [BibleBook]
    
    public init() {
        self.supportedTranslations = Self.createSupportedTranslations()
        self.bibleBooks = Self.createBibleBooks()
    }
    
    public func getSupportedTranslations() -> [BibleTranslation] {
        return supportedTranslations
    }
    
    public func getBooks(includeApocrypha: Bool = false) -> [BibleBook] {
        if includeApocrypha {
            return bibleBooks
        } else {
            return bibleBooks.filter { !$0.isApocrypha }
        }
    }
    
    public func getBook(by name: String) -> BibleBook? {
        return bibleBooks.first { book in
            book.name.lowercased() == name.lowercased() ||
            book.abbreviation.lowercased() == name.lowercased()
        }
    }
    
    public func getBooksByTestament(_ testament: BibleBook.Testament) -> [BibleBook] {
        return bibleBooks.filter { $0.testament == testament }
    }
    
    public func getApocryphaBooks() -> [BibleBook] {
        return bibleBooks.filter { $0.isApocrypha }
    }
    
    // MARK: - Static Data Creation
    private static func createSupportedTranslations() -> [BibleTranslation] {
        return [
            // ESV API Translations
            BibleTranslation(
                id: "esv",
                name: "English Standard Version",
                abbreviation: "ESV",
                language: "en",
                description: "Literal translation emphasizing word-for-word accuracy",
                includesApocrypha: false,
                apiSource: .esv
            ),
            
            // Bible.com API Translations (would need actual IDs from API)
            BibleTranslation(
                id: "niv",
                name: "New International Version",
                abbreviation: "NIV",
                language: "en",
                description: "Balance between word-for-word and thought-for-thought translation",
                includesApocrypha: false,
                apiSource: .bibleCom
            ),
            
            BibleTranslation(
                id: "nasb",
                name: "New American Standard Bible",
                abbreviation: "NASB",
                language: "en",
                description: "Literal translation with high accuracy to original text",
                includesApocrypha: false,
                apiSource: .bibleCom
            ),
            
            BibleTranslation(
                id: "nlt",
                name: "New Living Translation",
                abbreviation: "NLT",
                language: "en",
                description: "Thought-for-thought translation for modern readers",
                includesApocrypha: false,
                apiSource: .bibleCom
            ),
            
            BibleTranslation(
                id: "nrsv",
                name: "New Revised Standard Version",
                abbreviation: "NRSV",
                language: "en",
                description: "Scholarly translation including deuterocanonical books",
                includesApocrypha: true,
                apiSource: .bibleCom
            ),
            
            BibleTranslation(
                id: "nab",
                name: "New American Bible",
                abbreviation: "NAB",
                language: "en",
                description: "Catholic translation with complete Apocrypha",
                includesApocrypha: true,
                apiSource: .bibleCom
            ),
            
            BibleTranslation(
                id: "rsvce",
                name: "Revised Standard Version Catholic Edition",
                abbreviation: "RSV-CE",
                language: "en",
                description: "Catholic edition with deuterocanonical books",
                includesApocrypha: true,
                apiSource: .bibleCom
            )
        ]
    }
    
    private static func createBibleBooks() -> [BibleBook] {
        var books: [BibleBook] = []
        
        // Old Testament Books
        books.append(contentsOf: [
            BibleBook(id: "gen", name: "Genesis", abbreviation: "Gen", testament: .oldTestament, bookNumber: 1, chapterCount: 50, category: .law),
            BibleBook(id: "exo", name: "Exodus", abbreviation: "Exo", testament: .oldTestament, bookNumber: 2, chapterCount: 40, category: .law),
            BibleBook(id: "lev", name: "Leviticus", abbreviation: "Lev", testament: .oldTestament, bookNumber: 3, chapterCount: 27, category: .law),
            BibleBook(id: "num", name: "Numbers", abbreviation: "Num", testament: .oldTestament, bookNumber: 4, chapterCount: 36, category: .law),
            BibleBook(id: "deu", name: "Deuteronomy", abbreviation: "Deu", testament: .oldTestament, bookNumber: 5, chapterCount: 34, category: .law),
            
            BibleBook(id: "jos", name: "Joshua", abbreviation: "Jos", testament: .oldTestament, bookNumber: 6, chapterCount: 24, category: .history),
            BibleBook(id: "jdg", name: "Judges", abbreviation: "Jdg", testament: .oldTestament, bookNumber: 7, chapterCount: 21, category: .history),
            BibleBook(id: "rut", name: "Ruth", abbreviation: "Rut", testament: .oldTestament, bookNumber: 8, chapterCount: 4, category: .history),
            BibleBook(id: "1sa", name: "1 Samuel", abbreviation: "1Sa", testament: .oldTestament, bookNumber: 9, chapterCount: 31, category: .history),
            BibleBook(id: "2sa", name: "2 Samuel", abbreviation: "2Sa", testament: .oldTestament, bookNumber: 10, chapterCount: 24, category: .history),
            BibleBook(id: "1ki", name: "1 Kings", abbreviation: "1Ki", testament: .oldTestament, bookNumber: 11, chapterCount: 22, category: .history),
            BibleBook(id: "2ki", name: "2 Kings", abbreviation: "2Ki", testament: .oldTestament, bookNumber: 12, chapterCount: 25, category: .history),
            BibleBook(id: "1ch", name: "1 Chronicles", abbreviation: "1Ch", testament: .oldTestament, bookNumber: 13, chapterCount: 29, category: .history),
            BibleBook(id: "2ch", name: "2 Chronicles", abbreviation: "2Ch", testament: .oldTestament, bookNumber: 14, chapterCount: 36, category: .history),
            BibleBook(id: "ezr", name: "Ezra", abbreviation: "Ezr", testament: .oldTestament, bookNumber: 15, chapterCount: 10, category: .history),
            BibleBook(id: "neh", name: "Nehemiah", abbreviation: "Neh", testament: .oldTestament, bookNumber: 16, chapterCount: 13, category: .history),
            BibleBook(id: "est", name: "Esther", abbreviation: "Est", testament: .oldTestament, bookNumber: 17, chapterCount: 10, category: .history),
            
            BibleBook(id: "job", name: "Job", abbreviation: "Job", testament: .oldTestament, bookNumber: 18, chapterCount: 42, category: .wisdom),
            BibleBook(id: "psa", name: "Psalms", abbreviation: "Psa", testament: .oldTestament, bookNumber: 19, chapterCount: 150, category: .wisdom),
            BibleBook(id: "pro", name: "Proverbs", abbreviation: "Pro", testament: .oldTestament, bookNumber: 20, chapterCount: 31, category: .wisdom),
            BibleBook(id: "ecc", name: "Ecclesiastes", abbreviation: "Ecc", testament: .oldTestament, bookNumber: 21, chapterCount: 12, category: .wisdom),
            BibleBook(id: "sng", name: "Song of Songs", abbreviation: "Sng", testament: .oldTestament, bookNumber: 22, chapterCount: 8, category: .wisdom),
            
            BibleBook(id: "isa", name: "Isaiah", abbreviation: "Isa", testament: .oldTestament, bookNumber: 23, chapterCount: 66, category: .prophets),
            BibleBook(id: "jer", name: "Jeremiah", abbreviation: "Jer", testament: .oldTestament, bookNumber: 24, chapterCount: 52, category: .prophets),
            BibleBook(id: "lam", name: "Lamentations", abbreviation: "Lam", testament: .oldTestament, bookNumber: 25, chapterCount: 5, category: .prophets),
            BibleBook(id: "ezk", name: "Ezekiel", abbreviation: "Ezk", testament: .oldTestament, bookNumber: 26, chapterCount: 48, category: .prophets),
            BibleBook(id: "dan", name: "Daniel", abbreviation: "Dan", testament: .oldTestament, bookNumber: 27, chapterCount: 12, category: .prophets),
            BibleBook(id: "hos", name: "Hosea", abbreviation: "Hos", testament: .oldTestament, bookNumber: 28, chapterCount: 14, category: .prophets),
            BibleBook(id: "jol", name: "Joel", abbreviation: "Jol", testament: .oldTestament, bookNumber: 29, chapterCount: 3, category: .prophets),
            BibleBook(id: "amo", name: "Amos", abbreviation: "Amo", testament: .oldTestament, bookNumber: 30, chapterCount: 9, category: .prophets),
            BibleBook(id: "oba", name: "Obadiah", abbreviation: "Oba", testament: .oldTestament, bookNumber: 31, chapterCount: 1, category: .prophets),
            BibleBook(id: "jon", name: "Jonah", abbreviation: "Jon", testament: .oldTestament, bookNumber: 32, chapterCount: 4, category: .prophets),
            BibleBook(id: "mic", name: "Micah", abbreviation: "Mic", testament: .oldTestament, bookNumber: 33, chapterCount: 7, category: .prophets),
            BibleBook(id: "nam", name: "Nahum", abbreviation: "Nam", testament: .oldTestament, bookNumber: 34, chapterCount: 3, category: .prophets),
            BibleBook(id: "hab", name: "Habakkuk", abbreviation: "Hab", testament: .oldTestament, bookNumber: 35, chapterCount: 3, category: .prophets),
            BibleBook(id: "zep", name: "Zephaniah", abbreviation: "Zep", testament: .oldTestament, bookNumber: 36, chapterCount: 3, category: .prophets),
            BibleBook(id: "hag", name: "Haggai", abbreviation: "Hag", testament: .oldTestament, bookNumber: 37, chapterCount: 2, category: .prophets),
            BibleBook(id: "zec", name: "Zechariah", abbreviation: "Zec", testament: .oldTestament, bookNumber: 38, chapterCount: 14, category: .prophets),
            BibleBook(id: "mal", name: "Malachi", abbreviation: "Mal", testament: .oldTestament, bookNumber: 39, chapterCount: 4, category: .prophets)
        ])
        
        // New Testament Books
        books.append(contentsOf: [
            BibleBook(id: "mat", name: "Matthew", abbreviation: "Mat", testament: .newTestament, bookNumber: 40, chapterCount: 28, category: .gospels),
            BibleBook(id: "mrk", name: "Mark", abbreviation: "Mrk", testament: .newTestament, bookNumber: 41, chapterCount: 16, category: .gospels),
            BibleBook(id: "luk", name: "Luke", abbreviation: "Luk", testament: .newTestament, bookNumber: 42, chapterCount: 24, category: .gospels),
            BibleBook(id: "jhn", name: "John", abbreviation: "Jhn", testament: .newTestament, bookNumber: 43, chapterCount: 21, category: .gospels),
            
            BibleBook(id: "act", name: "Acts", abbreviation: "Act", testament: .newTestament, bookNumber: 44, chapterCount: 28, category: .history),
            
            BibleBook(id: "rom", name: "Romans", abbreviation: "Rom", testament: .newTestament, bookNumber: 45, chapterCount: 16, category: .epistles),
            BibleBook(id: "1co", name: "1 Corinthians", abbreviation: "1Co", testament: .newTestament, bookNumber: 46, chapterCount: 16, category: .epistles),
            BibleBook(id: "2co", name: "2 Corinthians", abbreviation: "2Co", testament: .newTestament, bookNumber: 47, chapterCount: 13, category: .epistles),
            BibleBook(id: "gal", name: "Galatians", abbreviation: "Gal", testament: .newTestament, bookNumber: 48, chapterCount: 6, category: .epistles),
            BibleBook(id: "eph", name: "Ephesians", abbreviation: "Eph", testament: .newTestament, bookNumber: 49, chapterCount: 6, category: .epistles),
            BibleBook(id: "php", name: "Philippians", abbreviation: "Php", testament: .newTestament, bookNumber: 50, chapterCount: 4, category: .epistles),
            BibleBook(id: "col", name: "Colossians", abbreviation: "Col", testament: .newTestament, bookNumber: 51, chapterCount: 4, category: .epistles),
            BibleBook(id: "1th", name: "1 Thessalonians", abbreviation: "1Th", testament: .newTestament, bookNumber: 52, chapterCount: 5, category: .epistles),
            BibleBook(id: "2th", name: "2 Thessalonians", abbreviation: "2Th", testament: .newTestament, bookNumber: 53, chapterCount: 3, category: .epistles),
            BibleBook(id: "1ti", name: "1 Timothy", abbreviation: "1Ti", testament: .newTestament, bookNumber: 54, chapterCount: 6, category: .epistles),
            BibleBook(id: "2ti", name: "2 Timothy", abbreviation: "2Ti", testament: .newTestament, bookNumber: 55, chapterCount: 4, category: .epistles),
            BibleBook(id: "tit", name: "Titus", abbreviation: "Tit", testament: .newTestament, bookNumber: 56, chapterCount: 3, category: .epistles),
            BibleBook(id: "phm", name: "Philemon", abbreviation: "Phm", testament: .newTestament, bookNumber: 57, chapterCount: 1, category: .epistles),
            BibleBook(id: "heb", name: "Hebrews", abbreviation: "Heb", testament: .newTestament, bookNumber: 58, chapterCount: 13, category: .epistles),
            BibleBook(id: "jas", name: "James", abbreviation: "Jas", testament: .newTestament, bookNumber: 59, chapterCount: 5, category: .epistles),
            BibleBook(id: "1pe", name: "1 Peter", abbreviation: "1Pe", testament: .newTestament, bookNumber: 60, chapterCount: 5, category: .epistles),
            BibleBook(id: "2pe", name: "2 Peter", abbreviation: "2Pe", testament: .newTestament, bookNumber: 61, chapterCount: 3, category: .epistles),
            BibleBook(id: "1jn", name: "1 John", abbreviation: "1Jn", testament: .newTestament, bookNumber: 62, chapterCount: 5, category: .epistles),
            BibleBook(id: "2jn", name: "2 John", abbreviation: "2Jn", testament: .newTestament, bookNumber: 63, chapterCount: 1, category: .epistles),
            BibleBook(id: "3jn", name: "3 John", abbreviation: "3Jn", testament: .newTestament, bookNumber: 64, chapterCount: 1, category: .epistles),
            BibleBook(id: "jud", name: "Jude", abbreviation: "Jud", testament: .newTestament, bookNumber: 65, chapterCount: 1, category: .epistles),
            
            BibleBook(id: "rev", name: "Revelation", abbreviation: "Rev", testament: .newTestament, bookNumber: 66, chapterCount: 22, category: .apocalyptic)
        ])
        
        // Apocrypha/Deuterocanonical Books
        books.append(contentsOf: [
            BibleBook(id: "tob", name: "Tobit", abbreviation: "Tob", testament: .apocrypha, bookNumber: 67, chapterCount: 14, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "jdt", name: "Judith", abbreviation: "Jdt", testament: .apocrypha, bookNumber: 68, chapterCount: 16, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "esg", name: "Esther (Greek)", abbreviation: "ESG", testament: .apocrypha, bookNumber: 69, chapterCount: 16, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "wis", name: "Wisdom of Solomon", abbreviation: "Wis", testament: .apocrypha, bookNumber: 70, chapterCount: 19, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "sir", name: "Sirach (Ecclesiasticus)", abbreviation: "Sir", testament: .apocrypha, bookNumber: 71, chapterCount: 51, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "bar", name: "Baruch", abbreviation: "Bar", testament: .apocrypha, bookNumber: 72, chapterCount: 6, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "lje", name: "Letter of Jeremiah", abbreviation: "LJe", testament: .apocrypha, bookNumber: 73, chapterCount: 1, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "s3y", name: "Song of the Three Young Men", abbreviation: "S3Y", testament: .apocrypha, bookNumber: 74, chapterCount: 1, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "sus", name: "Susanna", abbreviation: "Sus", testament: .apocrypha, bookNumber: 75, chapterCount: 1, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "bel", name: "Bel and the Dragon", abbreviation: "Bel", testament: .apocrypha, bookNumber: 76, chapterCount: 1, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "1ma", name: "1 Maccabees", abbreviation: "1Ma", testament: .apocrypha, bookNumber: 77, chapterCount: 16, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "2ma", name: "2 Maccabees", abbreviation: "2Ma", testament: .apocrypha, bookNumber: 78, chapterCount: 15, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "1es", name: "1 Esdras", abbreviation: "1Es", testament: .apocrypha, bookNumber: 79, chapterCount: 9, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "man", name: "Prayer of Manasseh", abbreviation: "Man", testament: .apocrypha, bookNumber: 80, chapterCount: 1, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "ps2", name: "Psalm 151", abbreviation: "Ps2", testament: .apocrypha, bookNumber: 81, chapterCount: 1, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "3ma", name: "3 Maccabees", abbreviation: "3Ma", testament: .apocrypha, bookNumber: 82, chapterCount: 7, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "2es", name: "2 Esdras", abbreviation: "2Es", testament: .apocrypha, bookNumber: 83, chapterCount: 16, isApocrypha: true, category: .deuterocanonical),
            BibleBook(id: "4ma", name: "4 Maccabees", abbreviation: "4Ma", testament: .apocrypha, bookNumber: 84, chapterCount: 18, isApocrypha: true, category: .deuterocanonical)
        ])
        
        return books
    }
    
    // MARK: - Utility Methods
    public func validateReference(_ reference: String, includeApocrypha: Bool = false) -> Bool {
        let books = getBooks(includeApocrypha: includeApocrypha)
        
        // Simple validation - in production, use more sophisticated parsing
        let components = reference.split(separator: " ")
        guard components.count >= 2 else { return false }
        
        let bookName = String(components.dropLast().joined(separator: " "))
        guard let book = getBook(by: bookName) else { return false }
        
        let chapterVerse = String(components.last!)
        let chapterVerseComponents = chapterVerse.split(separator: ":")
        
        guard let chapter = Int(chapterVerseComponents[0]) else { return false }
        guard chapter > 0 && chapter <= book.chapterCount else { return false }
        
        return true
    }
    
    public func normalizeBookName(_ name: String) -> String? {
        return getBook(by: name)?.name
    }
    
    public func getBookAbbreviation(_ name: String) -> String? {
        return getBook(by: name)?.abbreviation
    }
}