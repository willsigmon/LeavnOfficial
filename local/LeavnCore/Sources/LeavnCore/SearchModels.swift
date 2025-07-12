import Foundation

// MARK: - Search Filter

public enum SearchFilter: String, CaseIterable, Codable, Sendable {
    case all = "All"
    case oldTestament = "Old Testament"
    case newTestament = "New Testament"
    case gospels = "Gospels"
    case psalms = "Psalms"
    case proverbs = "Proverbs"

    public var title: String {
        self.rawValue
    }
}

// MARK: - Search Options

public struct SearchOptions: Codable, Sendable {
    public let filter: SearchFilter
    public let limit: Int
    public let translation: String?
    
    public init(filter: SearchFilter = .all, limit: Int = 100, translation: String? = nil) {
        self.filter = filter
        self.limit = limit
        self.translation = translation
    }
}

// MARK: - Search Result Models

/// Network/API representation of a search result
public struct APISearchResult: Identifiable, Codable, Sendable {
    public let id: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let translation: String
    
    public init(id: String, bookId: String, bookName: String, chapter: Int, verse: Int, text: String, translation: String) {
        self.id = id
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.translation = translation
    }
}

// MARK: - Search Results

public struct SearchResults: Codable, Sendable {
    public let query: String
    public let results: [APISearchResult]
    public let totalCount: Int
    public let searchTime: TimeInterval
    
    public init(query: String, results: [APISearchResult], totalCount: Int, searchTime: TimeInterval) {
        self.query = query
        self.results = results
        self.totalCount = totalCount
        self.searchTime = searchTime
    }
}

// MARK: - Local Search Result Model

/// Local app representation of a search result
public struct SearchResult: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let translation: String
    public let highlights: [HighlightRange]
    
    public init(
        bookId: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        text: String,
        translation: String,
        highlights: [HighlightRange] = []
    ) {
        self.id = "\(bookId)_\(chapter)_\(verse)"
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.translation = translation
        self.highlights = highlights
    }
    
    public var reference: String {
        "\(bookName) \(chapter):\(verse)"
    }
}

public struct HighlightRange: Codable, Sendable, Equatable {
    public let start: Int
    public let length: Int
    
    public init(start: Int, length: Int) {
        self.start = start
        self.length = length
    }
}
