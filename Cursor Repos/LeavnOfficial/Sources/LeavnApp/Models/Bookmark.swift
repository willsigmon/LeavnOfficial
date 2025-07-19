import Foundation
import Tagged
import IdentifiedCollections

// MARK: - Type-Safe IDs
public typealias BookmarkID = Tagged<Bookmark, UUID>

// MARK: - Bookmark Model
public struct Bookmark: Identifiable, Equatable, Codable, Sendable {
    public let id: BookmarkID
    public let reference: BibleReference
    public let createdAt: Date
    public var title: String?
    public var color: BookmarkColor
    public var note: String?
    public var folder: BookmarkFolder?
    
    public init(
        id: BookmarkID = BookmarkID(UUID()),
        reference: BibleReference,
        createdAt: Date = Date(),
        title: String? = nil,
        color: BookmarkColor = .default,
        note: String? = nil,
        folder: BookmarkFolder? = nil
    ) {
        self.id = id
        self.reference = reference
        self.createdAt = createdAt
        self.title = title
        self.color = color
        self.note = note
        self.folder = folder
    }
}

// MARK: - Bookmark Color
public enum BookmarkColor: String, CaseIterable, Codable, Sendable {
    case `default` = "default"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case pink = "pink"
    
    public var colorName: String {
        switch self {
        case .default: return "systemGray"
        case .red: return "systemRed"
        case .orange: return "systemOrange"
        case .yellow: return "systemYellow"
        case .green: return "systemGreen"
        case .blue: return "systemBlue"
        case .purple: return "systemPurple"
        case .pink: return "systemPink"
        }
    }
}

// MARK: - Bookmark Folder
public struct BookmarkFolder: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let icon: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        icon: String = "folder.fill",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.createdAt = createdAt
    }
    
    public static let defaultFolders: [BookmarkFolder] = [
        BookmarkFolder(name: "Favorites", icon: "star.fill"),
        BookmarkFolder(name: "Study", icon: "book.fill"),
        BookmarkFolder(name: "Prayer", icon: "hands.sparkles.fill"),
        BookmarkFolder(name: "Memory", icon: "brain")
    ]
}