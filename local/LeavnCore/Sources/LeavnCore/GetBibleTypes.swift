import Foundation

// MARK: - GetBible API Models
// These models are used by both GetBibleService and ProductionBibleService

public struct GetBibleChapter: Codable, Sendable {
    public let name: String
    public let chapter: [String: GetBibleVerse]  // Dictionary of verse number to verse data
}

public struct GetBibleVerse: Codable, Sendable {
    public let verse_nr: Int
    public let verse: String  // The actual text content
    
    enum CodingKeys: String, CodingKey {
        case verse_nr = "verse_nr"
        case verse = "verse"
    }
}

public struct GetBibleTranslationList: Codable, Sendable {
    public let translations: [String: GetBibleTranslation]
}

public struct GetBibleTranslation: Codable, Sendable {
    public let translation: String
    public let abbreviation: String
    public let language: String
    public let lang: String
    public let books: [GetBibleBook]
}

public struct GetBibleBook: Codable, Sendable {
    public let book: Int
    public let name: String
    public let chapters: Int
}
