import Foundation

public struct LifeSituation: Identifiable, Codable, Hashable, Equatable {
    public let id: String
    public let title: String
    public let description: String
    public let category: Category
    public let verses: [VerseReference]
    public let prayers: [String]
    public let createdAt: Date
    public let updatedAt: Date
    
    public enum Category: String, Codable, CaseIterable {
        case anxiety = "Anxiety"
        case grief = "Grief"
        case joy = "Joy"
        case fear = "Fear"
        case anger = "Anger"
        case love = "Love"
        case hope = "Hope"
        case peace = "Peace"
        case faith = "Faith"
        case forgiveness = "Forgiveness"
        case healing = "Healing"
        case guidance = "Guidance"
        case strength = "Strength"
        case wisdom = "Wisdom"
        case gratitude = "Gratitude"
        case other = "Other"
    }
    
    public init(
        id: String? = nil,
        title: String,
        description: String,
        category: Category,
        verses: [VerseReference] = [],
        prayers: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id ?? UUID().uuidString
        self.title = title
        self.description = description
        self.category = category
        self.verses = verses
        self.prayers = prayers
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct VerseReference: Codable, Hashable, Equatable {
    public let book: String
    public let chapter: Int
    public let startVerse: Int
    public let endVerse: Int?
    
    public var reference: String {
        if let endVerse = endVerse, endVerse != startVerse {
            return "\(book) \(chapter):\(startVerse)-\(endVerse)"
        } else {
            return "\(book) \(chapter):\(startVerse)"
        }
    }
    
    public init(book: String, chapter: Int, startVerse: Int, endVerse: Int? = nil) {
        self.book = book
        self.chapter = chapter
        self.startVerse = startVerse
        self.endVerse = endVerse
    }
}