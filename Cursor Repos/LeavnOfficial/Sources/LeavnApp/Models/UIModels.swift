import Foundation

// MARK: - Bible Models

public struct Verse: Identifiable, Equatable, Codable {
    public let id: String
    public let book: String
    public let chapter: Int
    public let verseNumber: Int
    public let text: String
    public var highlights: [Highlight]
    public var notes: [Note]
    public var bookmarks: [Bookmark]
    
    public init(
        id: String? = nil,
        book: String,
        chapter: Int,
        verseNumber: Int,
        text: String,
        highlights: [Highlight] = [],
        notes: [Note] = [],
        bookmarks: [Bookmark] = []
    ) {
        self.id = id ?? "\(book)_\(chapter)_\(verseNumber)"
        self.book = book
        self.chapter = chapter
        self.verseNumber = verseNumber
        self.text = text
        self.highlights = highlights
        self.notes = notes
        self.bookmarks = bookmarks
    }
}

public struct CrossReference: Identifiable, Equatable, Codable {
    public let id: String
    public let fromBook: String
    public let fromChapter: Int
    public let fromVerse: Int
    public let toBook: String
    public let toChapter: Int
    public let toVerse: Int
    public let type: ReferenceType
    
    public enum ReferenceType: String, Codable {
        case quotation
        case allusion
        case parallel
        case fulfillment
        case typological
    }
    
    public init(
        id: String? = nil,
        fromBook: String,
        fromChapter: Int,
        fromVerse: Int,
        toBook: String,
        toChapter: Int,
        toVerse: Int,
        type: ReferenceType = .parallel
    ) {
        self.id = id ?? UUID().uuidString
        self.fromBook = fromBook
        self.fromChapter = fromChapter
        self.fromVerse = fromVerse
        self.toBook = toBook
        self.toChapter = toChapter
        self.toVerse = toVerse
        self.type = type
    }
}

public struct SearchResult: Identifiable, Equatable {
    public let id: String
    public let book: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let highlightRanges: [NSRange]
    public let context: String?
    
    public init(
        id: String? = nil,
        book: String,
        chapter: Int,
        verse: Int,
        text: String,
        highlightRanges: [NSRange] = [],
        context: String? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.highlightRanges = highlightRanges
        self.context = context
    }
}

public struct Voice: Identifiable, Equatable, Codable {
    public let id: String
    public let name: String
    public let language: String
    public let gender: Gender
    public let previewURL: URL?
    public let isPremium: Bool
    
    public enum Gender: String, Codable {
        case male
        case female
        case neutral
    }
    
    public init(
        id: String,
        name: String,
        language: String = "en",
        gender: Gender,
        previewURL: URL? = nil,
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.language = language
        self.gender = gender
        self.previewURL = previewURL
        self.isPremium = isPremium
    }
}

// MARK: - Community Models

public struct Activity: Identifiable, Equatable, Codable {
    public let id: String
    public let userId: String
    public let userName: String
    public let userAvatar: URL?
    public let type: ActivityType
    public let content: String
    public let timestamp: Date
    public let metadata: [String: String]
    
    public enum ActivityType: String, Codable {
        case prayer
        case note
        case highlight
        case groupJoined
        case readingCompleted
        case planStarted
    }
    
    public init(
        id: String? = nil,
        userId: String,
        userName: String,
        userAvatar: URL? = nil,
        type: ActivityType,
        content: String,
        timestamp: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id ?? UUID().uuidString
        self.userId = userId
        self.userName = userName
        self.userAvatar = userAvatar
        self.type = type
        self.content = content
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

public struct CreateGroupRequest: Codable {
    public let name: String
    public let description: String
    public let type: GroupType
    public let isPrivate: Bool
    public let tags: [String]
    
    public enum GroupType: String, Codable {
        case bibleStudy
        case prayer
        case topic
        case church
        case community
    }
    
    public init(
        name: String,
        description: String,
        type: GroupType,
        isPrivate: Bool = false,
        tags: [String] = []
    ) {
        self.name = name
        self.description = description
        self.type = type
        self.isPrivate = isPrivate
        self.tags = tags
    }
}

public struct CreatePrayerRequest: Codable {
    public let content: String
    public let category: PrayerCategory
    public let isAnonymous: Bool
    public let groupIds: [String]
    
    public enum PrayerCategory: String, Codable, CaseIterable {
        case personal = "Personal"
        case family = "Family"
        case health = "Health"
        case work = "Work"
        case community = "Community"
        case world = "World"
        case praise = "Praise"
        case other = "Other"
    }
    
    public init(
        content: String,
        category: PrayerCategory,
        isAnonymous: Bool = false,
        groupIds: [String] = []
    ) {
        self.content = content
        self.category = category
        self.isAnonymous = isAnonymous
        self.groupIds = groupIds
    }
}

// MARK: - Settings Models

public struct DataCategory: Identifiable {
    public let id: String
    public let name: String
    public let icon: String
    public let sizeInBytes: Int64
    public let itemCount: Int
    public let lastModified: Date?
    
    public init(
        id: String? = nil,
        name: String,
        icon: String,
        sizeInBytes: Int64,
        itemCount: Int,
        lastModified: Date? = nil
    ) {
        self.id = id ?? name.lowercased()
        self.name = name
        self.icon = icon
        self.sizeInBytes = sizeInBytes
        self.itemCount = itemCount
        self.lastModified = lastModified
    }
}