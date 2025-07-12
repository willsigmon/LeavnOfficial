import Foundation
import LeavnCore

// MARK: - Bible Book
// Note: BibleBook is defined in LeavnCore/BibleModels.swift

// MARK: - Bible Verse
// Note: BibleVerse is defined in LeavnCore/BibleModels.swift

// MARK: - Bible Chapter
// Note: BibleChapter is defined in LeavnCore/BibleModels.swift

// MARK: - Supporting Types
// Note: Testament is defined in LeavnCore/BibleModels.swift

public enum BookGenre: String, Codable, CaseIterable {
    case law = "Law"
    case history = "History"
    case wisdom = "Wisdom"
    case prophecy = "Prophecy"
    case gospel = "Gospel"
    case epistle = "Epistle"
    case apocalyptic = "Apocalyptic"
}

// Note: BibleTranslation is defined in LeavnCore/BibleModels.swift

// MARK: - Reading Configuration
public struct BibleReadingConfig: Codable, Equatable {
    public var fontSize: Double
    public var lineSpacing: Double
    public var paragraphSpacing: Double
    public var theme: String
    public var showVerseNumbers: Bool
    public var showRedLetters: Bool
    
    public init(
        fontSize: Double = 16,
        lineSpacing: Double = 1.5,
        paragraphSpacing: Double = 1.0,
        theme: String = "system",
        showVerseNumbers: Bool = true,
        showRedLetters: Bool = true
    ) {
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.paragraphSpacing = paragraphSpacing
        self.theme = theme
        self.showVerseNumbers = showVerseNumbers
        self.showRedLetters = showRedLetters
    }
    
    public static let `default` = BibleReadingConfig()
}

// MARK: - Verse Annotation
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

// MARK: - AI Insights
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