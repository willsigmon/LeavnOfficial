import Foundation

// MARK: - Filter Types for Library Services

public struct NotesFilter: Equatable, Sendable {
    public let book: Book?
    public let tag: String?
    public let searchQuery: String?
    public let fromDate: Date?
    public let toDate: Date?
    public let sortBy: SortOption
    
    public enum SortOption: String, CaseIterable, Sendable {
        case createdDate = "Created Date"
        case updatedDate = "Updated Date"
        case reference = "Bible Reference"
        case title = "Title"
    }
    
    public init(
        book: Book? = nil,
        tag: String? = nil,
        searchQuery: String? = nil,
        fromDate: Date? = nil,
        toDate: Date? = nil,
        sortBy: SortOption = .updatedDate
    ) {
        self.book = book
        self.tag = tag
        self.searchQuery = searchQuery
        self.fromDate = fromDate
        self.toDate = toDate
        self.sortBy = sortBy
    }
}

public struct HighlightFilter: Equatable, Sendable {
    public let book: Book?
    public let color: HighlightColor?
    public let tag: String?
    public let fromDate: Date?
    public let toDate: Date?
    public let sortBy: SortOption
    
    public enum SortOption: String, CaseIterable, Sendable {
        case createdDate = "Created Date"
        case reference = "Bible Reference"
        case color = "Color"
    }
    
    public init(
        book: Book? = nil,
        color: HighlightColor? = nil,
        tag: String? = nil,
        fromDate: Date? = nil,
        toDate: Date? = nil,
        sortBy: SortOption = .createdDate
    ) {
        self.book = book
        self.color = color
        self.tag = tag
        self.fromDate = fromDate
        self.toDate = toDate
        self.sortBy = sortBy
    }
}

public struct BookmarkFilter: Equatable, Sendable {
    public let book: Book?
    public let tag: String?
    public let fromDate: Date?
    public let toDate: Date?
    public let sortBy: SortOption
    
    public enum SortOption: String, CaseIterable, Sendable {
        case createdDate = "Created Date"
        case reference = "Bible Reference"
    }
    
    public init(
        book: Book? = nil,
        tag: String? = nil,
        fromDate: Date? = nil,
        toDate: Date? = nil,
        sortBy: SortOption = .createdDate
    ) {
        self.book = book
        self.tag = tag
        self.fromDate = fromDate
        self.toDate = toDate
        self.sortBy = sortBy
    }
}