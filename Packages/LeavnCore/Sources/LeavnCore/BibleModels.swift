import Foundation


// MARK: - Bible Models

public struct BibleVerse: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let bookName: String
    public let bookId: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let translation: String
    public let isRedLetter: Bool
    
    public init(
        id: String = UUID().uuidString,
        bookName: String,
        bookId: String,
        chapter: Int,
        verse: Int,
        text: String,
        translation: String,
        isRedLetter: Bool = false
    ) {
        self.id = id
        self.bookName = bookName
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.translation = translation
        self.isRedLetter = isRedLetter
    }
    
    public var reference: String {
        "\(bookName) \(chapter):\(verse)"
    }
    
    public var shortReference: String {
        "\(chapter):\(verse)"
    }
}

public struct BibleChapter: Identifiable, Codable, Sendable {
    public let id: String
    public let bookName: String
    public let bookId: String
    public let chapterNumber: Int
    public let verses: [BibleVerse]
    
    public init(
        id: String = UUID().uuidString,
        bookName: String,
        bookId: String,
        chapterNumber: Int,
        verses: [BibleVerse]
    ) {
        self.id = id
        self.bookName = bookName
        self.bookId = bookId
        self.chapterNumber = chapterNumber
        self.verses = verses
    }
}

public struct BibleBook: Identifiable, Codable, Hashable, Sendable, CaseIterable {
    public let id: String
    public let name: String
    public let abbreviation: String
    public let testament: Testament
    public let chapterCount: Int
    public let bookNumber: Int
    
    public init(
        id: String,
        name: String,
        abbreviation: String,
        testament: Testament,
        chapterCount: Int,
        bookNumber: Int
    ) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.testament = testament
        self.chapterCount = chapterCount
        self.bookNumber = bookNumber
    }
}

public enum Testament: String, Codable, CaseIterable, Sendable {
    case old = "Old Testament"
    case new = "New Testament"
}

public extension BibleBook {
    init?(from string: String) {
        guard let book = BibleBook.allCases.first(where: { $0.id.lowercased() == string.lowercased() || $0.name.lowercased() == string.lowercased() }) else {
            return nil
        }
        self = book
    }
}

public extension BibleBook {
    // Old Testament
    static let genesis = BibleBook(from: "gen")!
    static let exodus = BibleBook(from: "exo")!
    static let leviticus = BibleBook(from: "lev")!
    static let numbers = BibleBook(from: "num")!
    static let deuteronomy = BibleBook(from: "deu")!
    static let joshua = BibleBook(from: "jos")!
    static let judges = BibleBook(from: "jdg")!
    static let ruth = BibleBook(from: "rut")!
    static let firstSamuel = BibleBook(from: "1sa")!
    static let secondSamuel = BibleBook(from: "2sa")!
    static let firstKings = BibleBook(from: "1ki")!
    static let secondKings = BibleBook(from: "2ki")!
    static let firstChronicles = BibleBook(from: "1ch")!
    static let secondChronicles = BibleBook(from: "2ch")!
    static let ezra = BibleBook(from: "ezr")!
    static let nehemiah = BibleBook(from: "neh")!
    static let esther = BibleBook(from: "est")!
    static let job = BibleBook(from: "job")!
    static let psalms = BibleBook(from: "psa")!
    static let proverbs = BibleBook(from: "pro")!
    static let ecclesiastes = BibleBook(from: "ecc")!
    static let songOfSolomon = BibleBook(from: "sng")!
    static let isaiah = BibleBook(from: "isa")!
    static let jeremiah = BibleBook(from: "jer")!
    static let lamentations = BibleBook(from: "lam")!
    static let ezekiel = BibleBook(from: "ezk")!
    static let daniel = BibleBook(from: "dan")!
    static let hosea = BibleBook(from: "hos")!
    static let joel = BibleBook(from: "jol")!
    static let amos = BibleBook(from: "amo")!
    static let obadiah = BibleBook(from: "oba")!
    static let jonah = BibleBook(from: "jon")!
    static let micah = BibleBook(from: "mic")!
    static let nahum = BibleBook(from: "nam")!
    static let habakkuk = BibleBook(from: "hab")!
    static let zephaniah = BibleBook(from: "zep")!
    static let haggai = BibleBook(from: "hag")!
    static let zechariah = BibleBook(from: "zec")!
    static let malachi = BibleBook(from: "mal")!
    
    // New Testament
    static let matthew = BibleBook(from: "mat")!
    static let mark = BibleBook(from: "mrk")!
    static let luke = BibleBook(from: "luk")!
    static let john = BibleBook(from: "jhn")!
    static let acts = BibleBook(from: "act")!
    static let romans = BibleBook(from: "rom")!
    static let firstCorinthians = BibleBook(from: "1co")!
    static let secondCorinthians = BibleBook(from: "2co")!
    static let galatians = BibleBook(from: "gal")!
    static let ephesians = BibleBook(from: "eph")!
    static let philippians = BibleBook(from: "php")!
    static let colossians = BibleBook(from: "col")!
    static let firstThessalonians = BibleBook(from: "1th")!
    static let secondThessalonians = BibleBook(from: "2th")!
    static let firstTimothy = BibleBook(from: "1ti")!
    static let secondTimothy = BibleBook(from: "2ti")!
    static let titus = BibleBook(from: "tit")!
    static let philemon = BibleBook(from: "phm")!
    static let hebrews = BibleBook(from: "heb")!
    static let james = BibleBook(from: "jas")!
    static let firstPeter = BibleBook(from: "1pe")!
    static let secondPeter = BibleBook(from: "2pe")!
    static let firstJohn = BibleBook(from: "1jn")!
    static let secondJohn = BibleBook(from: "2jn")!
    static let thirdJohn = BibleBook(from: "3jn")!
    static let jude = BibleBook(from: "jud")!
    static let revelation = BibleBook(from: "rev")!
}

public struct BibleTranslation: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let abbreviation: String
    public let language: String
    public let languageCode: String
    
    public init(
        id: String,
        name: String,
        abbreviation: String,
        language: String,
        languageCode: String
    ) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.language = language
        self.languageCode = languageCode
    }

        public static var kjv: BibleTranslation {
        return BibleTranslation(
            id: "kjv",
            name: "King James Version",
            abbreviation: "KJV",
            language: "English",
            languageCode: "en"
        )
    }

    public static let defaultTranslations: [BibleTranslation] = [
        BibleTranslation(
            id: "kjv",
            name: "King James Version",
            abbreviation: "KJV",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            id: "asv",
            name: "American Standard Version",
            abbreviation: "ASV",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            id: "bbe",
            name: "Bible in Basic English",
            abbreviation: "BBE",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            id: "web",
            name: "World English Bible",
            abbreviation: "WEB",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            id: "ylt",
            name: "Young's Literal Translation",
            abbreviation: "YLT",
            language: "English",
            languageCode: "en"
        )
    ]
    
    public var getBibleCode: String {
        return id
    }
}

// MARK: - User Models

public struct User: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let email: String?
    public let preferences: UserPreferences
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        email: String? = nil,
        preferences: UserPreferences = UserPreferences(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.preferences = preferences
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct UserPreferences: Codable, Sendable {
    public var defaultTranslation: String
    public var fontSize: Double
    public var theme: AppTheme
    public var dailyVerseEnabled: Bool
    public var dailyVerseTime: Date
    
    public init(
        defaultTranslation: String = "ESV",
        fontSize: Double = 18.0,
        theme: AppTheme = .system,
        dailyVerseEnabled: Bool = true,
        dailyVerseTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!
    ) {
        self.defaultTranslation = defaultTranslation
        self.fontSize = fontSize
        self.theme = theme
        self.dailyVerseEnabled = dailyVerseEnabled
        self.dailyVerseTime = dailyVerseTime
    }
}

public enum AppTheme: String, Codable, CaseIterable, Sendable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

// MARK: - Library Models

public struct Bookmark: Identifiable, Codable, Sendable {
    public let id: String
    public let verse: BibleVerse
    public let note: String?
    public let tags: [String]
    public let color: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        verse: BibleVerse,
        note: String? = nil,
        tags: [String] = [],
        color: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.verse = verse
        self.note = note
        self.tags = tags
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct ReadingPlan: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let duration: Int // days
    public let days: [ReadingPlanDay]
    public let isActive: Bool
    public let startDate: Date?
    public let progress: Double
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        duration: Int,
        days: [ReadingPlanDay],
        isActive: Bool = false,
        startDate: Date? = nil,
        progress: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.days = days
        self.isActive = isActive
        self.startDate = startDate
        self.progress = progress
    }
}

public struct ReadingPlanDay: Identifiable, Codable, Sendable {
    public let id: String
    public let dayNumber: Int
    public let readings: [BibleReading]
    public let isCompleted: Bool
    public let completedAt: Date?
    
    public init(
        id: String = UUID().uuidString,
        dayNumber: Int,
        readings: [BibleReading],
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.readings = readings
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}

public struct BibleReading: Codable, Sendable {
    public let bookId: String
    public let startChapter: Int
    public let startVerse: Int?
    public let endChapter: Int
    public let endVerse: Int?
    
    public init(
        bookId: String,
        startChapter: Int,
        startVerse: Int? = nil,
        endChapter: Int,
        endVerse: Int? = nil
    ) {
        self.bookId = bookId
        self.startChapter = startChapter
        self.startVerse = startVerse
        self.endChapter = endChapter
        self.endVerse = endVerse
    }
}

// MARK: - AI Models

public struct AIInsight: Identifiable, Codable, Sendable {
    public let id: String
    public let type: InsightType
    public let title: String
    public let content: String
    public let relatedVerses: [BibleVerse]
    
    public init(
        id: String = UUID().uuidString,
        type: InsightType,
        title: String,
        content: String,
        relatedVerses: [BibleVerse] = []
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.relatedVerses = relatedVerses
    }
}

public enum InsightType: String, Codable, CaseIterable, Sendable {
    case historical = "Historical"
    case theological = "Theological"
    case practical = "Practical"
    case devotional = "Devotional"
}

// MARK: - Sync Models

public enum SyncStatus: String, Codable, Sendable {
    case idle = "Idle"
    case syncing = "Syncing"
    case completed = "Completed"
    case failed = "Failed"
    case disabled = "Disabled"
}

// MARK: - AI Context

public struct AIContext: Codable, Sendable {
    public let userLevel: String?
    public let preferredStyle: String?
    public let additionalContext: String?
    
    public init(
        userLevel: String? = nil,
        preferredStyle: String? = nil,
        additionalContext: String? = nil
    ) {
        self.userLevel = userLevel
        self.preferredStyle = preferredStyle
        self.additionalContext = additionalContext
    }
}

// MARK: - Translation Comparison

public struct TranslationComparison: Codable, Sendable {
    public let verse: BibleVerse
    public let translations: [String: String]
    public let differences: [String]
    public let recommendations: [String]
    
    public init(
        verse: BibleVerse,
        translations: [String: String],
        differences: [String],
        recommendations: [String]
    ) {
        self.verse = verse
        self.translations = translations
        self.differences = differences
        self.recommendations = recommendations
    }
}

// MARK: - Historical Context

public struct HistoricalContext: Codable, Sendable {
    public let description: String
    public let period: String?
    public let culturalNotes: [String]?
    public let archaeologicalFindings: [String]?
    
    public init(
        description: String,
        period: String? = nil,
        culturalNotes: [String]? = nil,
        archaeologicalFindings: [String]? = nil
    ) {
        self.description = description
        self.period = period
        self.culturalNotes = culturalNotes
        self.archaeologicalFindings = archaeologicalFindings
    }
}

// MARK: - Library Types

public struct Note: Identifiable, Codable, Sendable {
    public let id: String
    public let verse: BibleVerse
    public let content: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        verse: BibleVerse,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.verse = verse
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct Highlight: Identifiable, Codable, Sendable {
    public let id: String
    public let verse: BibleVerse
    public let colorIndex: Int
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        verse: BibleVerse,
        colorIndex: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.verse = verse
        self.colorIndex = colorIndex
        self.createdAt = createdAt
    }
}

public struct ReadingHistory: Codable, Sendable {
    public let id: String
    public let book: String
    public let chapter: Int
    public let startVerse: Int?
    public let endVerse: Int?
    public let translation: String
    public let timestamp: Date
    public let duration: TimeInterval?
    
    public init(
        id: String = UUID().uuidString,
        book: String,
        chapter: Int,
        startVerse: Int? = nil,
        endVerse: Int? = nil,
        translation: String,
        timestamp: Date = Date(),
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.book = book
        self.chapter = chapter
        self.startVerse = startVerse
        self.endVerse = endVerse
        self.translation = translation
        self.timestamp = timestamp
        self.duration = duration
    }
}

public struct ReadingStats: Sendable {
    public let totalDaysRead: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let totalVersesRead: Int
    public let totalChaptersRead: Int
    public let averageReadingTime: TimeInterval
    public let favoriteBooks: [String]
    
    public init(
        totalDaysRead: Int,
        currentStreak: Int,
        longestStreak: Int,
        totalVersesRead: Int,
        totalChaptersRead: Int,
        averageReadingTime: TimeInterval,
        favoriteBooks: [String]
    ) {
        self.totalDaysRead = totalDaysRead
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalVersesRead = totalVersesRead
        self.totalChaptersRead = totalChaptersRead
        self.averageReadingTime = averageReadingTime
        self.favoriteBooks = favoriteBooks
    }
}

// MARK: - Service Types

public struct APIEndpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let parameters: [String: String]?  // Changed to [String: String] for Sendable
    
    public init(path: String, method: HTTPMethod = .GET, headers: [String: String]? = nil, parameters: [String: String]? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
}

public enum HTTPMethod: String, Sendable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

public struct AnalyticsEvent: Sendable {
    public let name: String
    public let parameters: [String: String]?
    
    public init(name: String, parameters: [String: String]? = nil) {
        self.name = name
        self.parameters = parameters
    }
}

// MARK: - Reading Plan Progress

public struct ReadingPlanProgress: Codable, Sendable {
    public let planId: String
    public let currentDay: Int
    public let completedDays: [Int]
    public let startedAt: Date
    public let lastActivityAt: Date
    
    public init(
        planId: String,
        currentDay: Int,
        completedDays: [Int],
        startedAt: Date,
        lastActivityAt: Date
    ) {
        self.planId = planId
        self.currentDay = currentDay
        self.completedDays = completedDays
        self.startedAt = startedAt
        self.lastActivityAt = lastActivityAt
    }
}

// MARK: - Devotion Model

/// Newly added optional fields:
/// - author: String?
/// - scriptureReference: String?
/// - scriptureText: String?
/// - reflectionQuestions: [String]?
/// - imageName: String?
public extension BibleBook {
    static var oldTestament: [BibleBook] {
        allCases.filter { $0.testament == .old }
    }
    
    static var newTestament: [BibleBook] {
        allCases.filter { $0.testament == .new }
    }
    
    static let allCases: [BibleBook] = [
        // Old Testament
        BibleBook(id: "gen", name: "Genesis", abbreviation: "Gen", testament: .old, chapterCount: 50, bookNumber: 1),
        BibleBook(id: "exo", name: "Exodus", abbreviation: "Exo", testament: .old, chapterCount: 40, bookNumber: 2),
        BibleBook(id: "lev", name: "Leviticus", abbreviation: "Lev", testament: .old, chapterCount: 27, bookNumber: 3),
        BibleBook(id: "num", name: "Numbers", abbreviation: "Num", testament: .old, chapterCount: 36, bookNumber: 4),
        BibleBook(id: "deu", name: "Deuteronomy", abbreviation: "Deu", testament: .old, chapterCount: 34, bookNumber: 5),
        BibleBook(id: "jos", name: "Joshua", abbreviation: "Jos", testament: .old, chapterCount: 24, bookNumber: 6),
        BibleBook(id: "jdg", name: "Judges", abbreviation: "Jdg", testament: .old, chapterCount: 21, bookNumber: 7),
        BibleBook(id: "rut", name: "Ruth", abbreviation: "Rut", testament: .old, chapterCount: 4, bookNumber: 8),
        BibleBook(id: "1sa", name: "1 Samuel", abbreviation: "1 Sa", testament: .old, chapterCount: 31, bookNumber: 9),
        BibleBook(id: "2sa", name: "2 Samuel", abbreviation: "2 Sa", testament: .old, chapterCount: 24, bookNumber: 10),
        BibleBook(id: "1ki", name: "1 Kings", abbreviation: "1 Ki", testament: .old, chapterCount: 22, bookNumber: 11),
        BibleBook(id: "2ki", name: "2 Kings", abbreviation: "2 Ki", testament: .old, chapterCount: 25, bookNumber: 12),
        BibleBook(id: "1ch", name: "1 Chronicles", abbreviation: "1 Ch", testament: .old, chapterCount: 29, bookNumber: 13),
        BibleBook(id: "2ch", name: "2 Chronicles", abbreviation: "2 Ch", testament: .old, chapterCount: 36, bookNumber: 14),
        BibleBook(id: "ezr", name: "Ezra", abbreviation: "Ezr", testament: .old, chapterCount: 10, bookNumber: 15),
        BibleBook(id: "neh", name: "Nehemiah", abbreviation: "Neh", testament: .old, chapterCount: 13, bookNumber: 16),
        BibleBook(id: "est", name: "Esther", abbreviation: "Est", testament: .old, chapterCount: 10, bookNumber: 17),
        BibleBook(id: "job", name: "Job", abbreviation: "Job", testament: .old, chapterCount: 42, bookNumber: 18),
        BibleBook(id: "psa", name: "Psalms", abbreviation: "Ps", testament: .old, chapterCount: 150, bookNumber: 19),
        BibleBook(id: "pro", name: "Proverbs", abbreviation: "Pro", testament: .old, chapterCount: 31, bookNumber: 20),
        BibleBook(id: "ecc", name: "Ecclesiastes", abbreviation: "Ecc", testament: .old, chapterCount: 12, bookNumber: 21),
        BibleBook(id: "sng", name: "Song of Solomon", abbreviation: "Sng", testament: .old, chapterCount: 8, bookNumber: 22),
        BibleBook(id: "isa", name: "Isaiah", abbreviation: "Isa", testament: .old, chapterCount: 66, bookNumber: 23),
        BibleBook(id: "jer", name: "Jeremiah", abbreviation: "Jer", testament: .old, chapterCount: 52, bookNumber: 24),
        BibleBook(id: "lam", name: "Lamentations", abbreviation: "Lam", testament: .old, chapterCount: 5, bookNumber: 25),
        BibleBook(id: "ezk", name: "Ezekiel", abbreviation: "Ezk", testament: .old, chapterCount: 48, bookNumber: 26),
        BibleBook(id: "dan", name: "Daniel", abbreviation: "Dan", testament: .old, chapterCount: 12, bookNumber: 27),
        BibleBook(id: "hos", name: "Hosea", abbreviation: "Hos", testament: .old, chapterCount: 14, bookNumber: 28),
        BibleBook(id: "jol", name: "Joel", abbreviation: "Jol", testament: .old, chapterCount: 3, bookNumber: 29),
        BibleBook(id: "amo", name: "Amos", abbreviation: "Amo", testament: .old, chapterCount: 9, bookNumber: 30),
        BibleBook(id: "oba", name: "Obadiah", abbreviation: "Oba", testament: .old, chapterCount: 1, bookNumber: 31),
        BibleBook(id: "jon", name: "Jonah", abbreviation: "Jon", testament: .old, chapterCount: 4, bookNumber: 32),
        BibleBook(id: "mic", name: "Micah", abbreviation: "Mic", testament: .old, chapterCount: 7, bookNumber: 33),
        BibleBook(id: "nam", name: "Nahum", abbreviation: "Nam", testament: .old, chapterCount: 3, bookNumber: 34),
        BibleBook(id: "hab", name: "Habakkuk", abbreviation: "Hab", testament: .old, chapterCount: 3, bookNumber: 35),
        BibleBook(id: "zep", name: "Zephaniah", abbreviation: "Zep", testament: .old, chapterCount: 3, bookNumber: 36),
        BibleBook(id: "hag", name: "Haggai", abbreviation: "Hag", testament: .old, chapterCount: 2, bookNumber: 37),
        BibleBook(id: "zec", name: "Zechariah", abbreviation: "Zec", testament: .old, chapterCount: 14, bookNumber: 38),
        BibleBook(id: "mal", name: "Malachi", abbreviation: "Mal", testament: .old, chapterCount: 4, bookNumber: 39),
        // New Testament
        BibleBook(id: "mat", name: "Matthew", abbreviation: "Mat", testament: .new, chapterCount: 28, bookNumber: 40),
        BibleBook(id: "mrk", name: "Mark", abbreviation: "Mar", testament: .new, chapterCount: 16, bookNumber: 41),
        BibleBook(id: "luk", name: "Luke", abbreviation: "Luk", testament: .new, chapterCount: 24, bookNumber: 42),
        BibleBook(id: "jhn", name: "John", abbreviation: "Joh", testament: .new, chapterCount: 21, bookNumber: 43),
        BibleBook(id: "act", name: "Acts", abbreviation: "Act", testament: .new, chapterCount: 28, bookNumber: 44),
        BibleBook(id: "rom", name: "Romans", abbreviation: "Rom", testament: .new, chapterCount: 16, bookNumber: 45),
        BibleBook(id: "1co", name: "1 Corinthians", abbreviation: "1 Co", testament: .new, chapterCount: 16, bookNumber: 46),
        BibleBook(id: "2co", name: "2 Corinthians", abbreviation: "2 Co", testament: .new, chapterCount: 13, bookNumber: 47),
        BibleBook(id: "gal", name: "Galatians", abbreviation: "Gal", testament: .new, chapterCount: 6, bookNumber: 48),
        BibleBook(id: "eph", name: "Ephesians", abbreviation: "Eph", testament: .new, chapterCount: 6, bookNumber: 49),
        BibleBook(id: "php", name: "Philippians", abbreviation: "Phl", testament: .new, chapterCount: 4, bookNumber: 50),
        BibleBook(id: "col", name: "Colossians", abbreviation: "Col", testament: .new, chapterCount: 4, bookNumber: 51),
        BibleBook(id: "1th", name: "1 Thessalonians", abbreviation: "1 Th", testament: .new, chapterCount: 5, bookNumber: 52),
        BibleBook(id: "2th", name: "2 Thessalonians", abbreviation: "2 Th", testament: .new, chapterCount: 3, bookNumber: 53),
        BibleBook(id: "1ti", name: "1 Timothy", abbreviation: "1 Ti", testament: .new, chapterCount: 6, bookNumber: 54),
        BibleBook(id: "2ti", name: "2 Timothy", abbreviation: "2 Ti", testament: .new, chapterCount: 4, bookNumber: 55),
        BibleBook(id: "tit", name: "Titus", abbreviation: "Tit", testament: .new, chapterCount: 3, bookNumber: 56),
        BibleBook(id: "phm", name: "Philemon", abbreviation: "Phm", testament: .new, chapterCount: 1, bookNumber: 57),
        BibleBook(id: "heb", name: "Hebrews", abbreviation: "Heb", testament: .new, chapterCount: 13, bookNumber: 58),
        BibleBook(id: "jas", name: "James", abbreviation: "Jas", testament: .new, chapterCount: 5, bookNumber: 59),
        BibleBook(id: "1pe", name: "1 Peter", abbreviation: "1 Pe", testament: .new, chapterCount: 5, bookNumber: 60),
        BibleBook(id: "2pe", name: "2 Peter", abbreviation: "2 Pe", testament: .new, chapterCount: 3, bookNumber: 61),
        BibleBook(id: "1jn", name: "1 John", abbreviation: "1 Jn", testament: .new, chapterCount: 5, bookNumber: 62),
        BibleBook(id: "2jn", name: "2 John", abbreviation: "2 Jn", testament: .new, chapterCount: 1, bookNumber: 63),
        BibleBook(id: "3jn", name: "3 John", abbreviation: "3 Jn", testament: .new, chapterCount: 1, bookNumber: 64),
        BibleBook(id: "jud", name: "Jude", abbreviation: "Jud", testament: .new, chapterCount: 1, bookNumber: 65),
        BibleBook(id: "rev", name: "Revelation", abbreviation: "Rev", testament: .new, chapterCount: 22, bookNumber: 66)
    ]
}

public struct Devotion: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let verse: BibleVerse
    public let content: String
    public let prayer: String
    public let reflection: String
    public let date: Date
    public let author: String?
    public let scriptureReference: String?
    public let scriptureText: String?
    public let reflectionQuestions: [String]?
    public let imageName: String?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        verse: BibleVerse,
        content: String,
        prayer: String,
        reflection: String,
        date: Date = Date(),
        author: String? = nil,
        scriptureReference: String? = nil,
        scriptureText: String? = nil,
        reflectionQuestions: [String]? = nil,
        imageName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.verse = verse
        self.content = content
        self.prayer = prayer
        self.reflection = reflection
        self.date = date
        self.author = author
        self.scriptureReference = scriptureReference
        self.scriptureText = scriptureText
        self.reflectionQuestions = reflectionQuestions
        self.imageName = imageName
    }
}
