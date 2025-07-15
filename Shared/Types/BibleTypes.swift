import Foundation

// MARK: - Basic Bible Types
public struct BibleBook: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let shortName: String
    public let testament: Testament
    public let chapterCount: Int
    public let order: Int
    
    public init(id: String, name: String, shortName: String, testament: Testament, chapterCount: Int, order: Int) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.testament = testament
        self.chapterCount = chapterCount
        self.order = order
    }
}

public enum Testament: String, Codable, CaseIterable {
    case old = "Old Testament"
    case new = "New Testament"
}

public struct BibleVerse: Codable, Identifiable, Hashable {
    public let id: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let translation: String
    
    public init(id: String, bookId: String, bookName: String, chapter: Int, verse: Int, text: String, translation: String = "ESV") {
        self.id = id
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.translation = translation
    }
    
    public var reference: String {
        return "\(bookName) \(chapter):\(verse)"
    }
}

public struct BibleChapter: Codable, Identifiable, Hashable {
    public let id: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verses: [BibleVerse]
    public let translation: String
    
    public init(id: String, bookId: String, bookName: String, chapter: Int, verses: [BibleVerse], translation: String = "ESV") {
        self.id = id
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verses = verses
        self.translation = translation
    }
}

// MARK: - Other Bible Types
public struct BibleTranslation: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let shortName: String
    public let description: String
    public let language: String
    
    public init(id: String, name: String, shortName: String, description: String, language: String = "en") {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.description = description
        self.language = language
    }
}

// MARK: - Search Types
public struct BibleSearchResult: Codable, Identifiable, Hashable {
    public let id: String
    public let verse: BibleVerse
    public let relevanceScore: Double
    public let highlightedText: String?
    
    public init(id: String, verse: BibleVerse, relevanceScore: Double, highlightedText: String? = nil) {
        self.id = id
        self.verse = verse
        self.relevanceScore = relevanceScore
        self.highlightedText = highlightedText
    }
}

public struct LibrarySearchResult: Codable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let type: String
    public let snippet: String
    public let url: String?
    
    public init(id: String, title: String, type: String, snippet: String, url: String? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.snippet = snippet
        self.url = url
    }
}

public struct SearchQuery: Codable, Identifiable, Hashable {
    public let id: String
    public let query: String
    public let timestamp: Date
    public let filters: [String]
    
    public init(id: String, query: String, timestamp: Date = Date(), filters: [String] = []) {
        self.id = id
        self.query = query
        self.timestamp = timestamp
        self.filters = filters
    }
}

public enum SearchScope: String, Codable, CaseIterable {
    case bible = "bible"
    case library = "library"
    case both = "both"
}

// MARK: - Library Types
public struct LibraryItem: Codable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let author: String
    public let type: LibraryItemType
    public let content: String
    public let dateAdded: Date
    public let tags: [String]
    
    public init(id: String, title: String, author: String, type: LibraryItemType, content: String, dateAdded: Date = Date(), tags: [String] = []) {
        self.id = id
        self.title = title
        self.author = author
        self.type = type
        self.content = content
        self.dateAdded = dateAdded
        self.tags = tags
    }
}

public enum LibraryItemType: String, Codable, CaseIterable {
    case sermon = "sermon"
    case commentary = "commentary"
    case devotional = "devotional"
    case study = "study"
    case article = "article"
    case book = "book"
}

// MARK: - Community Types
public struct CommunityPost: Codable, Identifiable, Hashable {
    public let id: String
    public let authorId: String
    public let authorName: String
    public let content: String
    public let verse: BibleVerse?
    public let timestamp: Date
    public let likes: Int
    public let comments: [CommunityComment]
    
    public init(id: String, authorId: String, authorName: String, content: String, verse: BibleVerse? = nil, timestamp: Date = Date(), likes: Int = 0, comments: [CommunityComment] = []) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.verse = verse
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
    }
}

public struct CommunityComment: Codable, Identifiable, Hashable {
    public let id: String
    public let authorId: String
    public let authorName: String
    public let content: String
    public let timestamp: Date
    
    public init(id: String, authorId: String, authorName: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.timestamp = timestamp
    }
}

public struct CommunityGroup: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let memberCount: Int
    public let isPrivate: Bool
    
    public init(id: String, name: String, description: String, memberCount: Int, isPrivate: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.memberCount = memberCount
        self.isPrivate = isPrivate
    }
}

// MARK: - Audio Types
public struct AudioChapter: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let bookId: String
    public let chapterNumber: Int
    public let audioURL: URL
    public let duration: TimeInterval
    public let narratorName: String
    
    public init(id: String, bookId: String, chapterNumber: Int, audioURL: URL, duration: TimeInterval, narratorName: String) {
        self.id = id
        self.bookId = bookId
        self.chapterNumber = chapterNumber
        self.audioURL = audioURL
        self.duration = duration
        self.narratorName = narratorName
    }
}

// MARK: - Voice Configuration Types
public struct Voice: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let language: String
    public let gender: String
    
    public init(id: String, name: String, language: String, gender: String) {
        self.id = id
        self.name = name
        self.language = language
        self.gender = gender
    }
}

public struct VoicePreferences: Codable, Hashable, Sendable {
    public let selectedVoice: Voice
    public let speed: Double
    public let pitch: Double
    
    public init(selectedVoice: Voice, speed: Double = 1.0, pitch: Double = 1.0) {
        self.selectedVoice = selectedVoice
        self.speed = speed
        self.pitch = pitch
    }
}

public struct VoiceConfiguration: Codable, Hashable {
    public let voice: Voice
    public let speed: Double
    public let pitch: Double
    public let volume: Double
    
    public init(voice: Voice, speed: Double = 1.0, pitch: Double = 1.0, volume: Double = 1.0) {
        self.voice = voice
        self.speed = speed
        self.pitch = pitch
        self.volume = volume
    }
}

// MARK: - Biblical Passage Types
public struct BiblePassage: Codable, Identifiable, Hashable {
    public let id: String
    public let reference: String
    public let text: String
    public let verses: [BibleVerse]
    
    public init(id: String, reference: String, text: String, verses: [BibleVerse]) {
        self.id = id
        self.reference = reference
        self.text = text
        self.verses = verses
    }
}

// MARK: - Audio Player Types
public enum AudioPlayerState: String, Codable, CaseIterable {
    case idle = "idle"
    case loading = "loading"
    case playing = "playing"
    case paused = "paused"
    case stopped = "stopped"
    case error = "error"
}

public struct ChapterInfo: Codable, Identifiable, Hashable {
    public let id: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verseCount: Int
    public let audioURL: URL?
    
    public init(id: String, bookId: String, bookName: String, chapter: Int, verseCount: Int, audioURL: URL? = nil) {
        self.id = id
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verseCount = verseCount
        self.audioURL = audioURL
    }
}

public enum PlaybackSpeed: Double, Codable, CaseIterable {
    case slow = 0.5
    case normal = 1.0
    case fast = 1.5
    case faster = 2.0
    
    public var displayName: String {
        switch self {
        case .slow: return "0.5x"
        case .normal: return "1.0x"
        case .fast: return "1.5x"
        case .faster: return "2.0x"
        }
    }
}