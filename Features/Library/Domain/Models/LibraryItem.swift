import Foundation

public enum LibraryItemType: String, Codable, CaseIterable {
    case bookmark = "bookmark"
    case note = "note"
    case highlight = "highlight"
    case readingPlan = "readingPlan"
    case devotion = "devotion"
    case prayerRequest = "prayerRequest"
}

public struct LibraryItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: LibraryItemType
    public let title: String
    public let content: String?
    public let verse: LibraryVerse?
    public let createdAt: Date
    public let updatedAt: Date
    public let tags: [String]
    public let color: String?
    
    public init(
        id: UUID = UUID(),
        type: LibraryItemType,
        title: String,
        content: String? = nil,
        verse: LibraryVerse? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        color: String? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.verse = verse
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.color = color
    }
}

public struct LibraryVerse: Codable, Equatable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let translation: String
    
    public init(
        bookId: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        text: String,
        translation: String
    ) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.translation = translation
    }
    
    public var reference: String {
        "\(bookName) \(chapter):\(verse)"
    }
}