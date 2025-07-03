import Foundation
import LeavnCore

public enum LibraryCategory: String, CaseIterable, Identifiable {
    case bookmarks, notes, highlights, readingPlans, favorites, collections

    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .bookmarks: return "Bookmarks"
        case .notes: return "Notes"
        case .highlights: return "Highlights"  
        case .readingPlans: return "Reading Plans"
        case .favorites: return "Favorites"
        case .collections: return "Collections"
        }
    }
}

public struct LibraryVerse: Identifiable {
    public let id: String = UUID().uuidString
    public let number: Int
    public let text: String
    public let reference: String
    
    public init(number: Int, text: String, reference: String) {
        self.number = number
        self.text = text
        self.reference = reference
    }
}

public struct LibraryItem: Identifiable {
    public let id: String
    public let sourceId: String
    public let title: String
    public let icon: String
    public let category: LibraryCategory
    public let date: Date
    public let itemCount: Int
    public let colorIndex: Int
    public let verses: [LibraryVerse]
    
    public init(
        id: String = UUID().uuidString,
        sourceId: String,
        title: String,
        icon: String,
        category: LibraryCategory,
        date: Date,
        itemCount: Int,
        colorIndex: Int = 0,
        verses: [LibraryVerse] = []
    ) {
        self.id = id
        self.sourceId = sourceId
        self.title = title
        self.icon = icon
        self.category = category
        self.date = date
        self.itemCount = itemCount
        self.colorIndex = colorIndex
        self.verses = verses
    }
}
