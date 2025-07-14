import Foundation

// MARK: - Search Domain Models
public struct SearchQuery: Codable {
    public let text: String
    public let filters: SearchFilters
    public let sortOptions: SearchSortOptions
    public let pagination: SearchPagination
    
    public init(
        text: String,
        filters: SearchFilters = SearchFilters(),
        sortOptions: SearchSortOptions = SearchSortOptions(),
        pagination: SearchPagination = SearchPagination()
    ) {
        self.text = text
        self.filters = filters
        self.sortOptions = sortOptions
        self.pagination = pagination
    }
    
    public var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

public struct SearchFilters: Codable {
    public let contentTypes: [SearchContentType]
    public let dateRange: DateRange?
    public let categories: [String]
    public let tags: [String]
    public let sources: [String]
    
    public init(
        contentTypes: [SearchContentType] = SearchContentType.allCases,
        dateRange: DateRange? = nil,
        categories: [String] = [],
        tags: [String] = [],
        sources: [String] = []
    ) {
        self.contentTypes = contentTypes
        self.dateRange = dateRange
        self.categories = categories
        self.tags = tags
        self.sources = sources
    }
    
    public var isEmpty: Bool {
        contentTypes.isEmpty && 
        dateRange == nil && 
        categories.isEmpty && 
        tags.isEmpty && 
        sources.isEmpty
    }
}

public struct SearchSortOptions: Codable {
    public let sortBy: SearchSortBy
    public let order: SortOrder
    
    public init(sortBy: SearchSortBy = .relevance, order: SortOrder = .descending) {
        self.sortBy = sortBy
        self.order = order
    }
}

public enum SearchSortBy: String, Codable, CaseIterable {
    case relevance = "relevance"
    case date = "date"
    case title = "title"
    case popularity = "popularity"
    
    public var displayName: String {
        switch self {
        case .relevance: return "Relevance"
        case .date: return "Date"
        case .title: return "Title"
        case .popularity: return "Popularity"
        }
    }
}

public enum SortOrder: String, Codable, CaseIterable {
    case ascending = "asc"
    case descending = "desc"
    
    public var displayName: String {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
}

public struct SearchPagination: Codable {
    public let page: Int
    public let limit: Int
    public let offset: Int
    
    public init(page: Int = 1, limit: Int = 20) {
        self.page = page
        self.limit = limit
        self.offset = (page - 1) * limit
    }
}

public struct DateRange: Codable {
    public let start: Date
    public let end: Date
    
    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
    
    public static func lastWeek() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: end) ?? end
        return DateRange(start: start, end: end)
    }
    
    public static func lastMonth() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .month, value: -1, to: end) ?? end
        return DateRange(start: start, end: end)
    }
    
    public static func lastYear() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .year, value: -1, to: end) ?? end
        return DateRange(start: start, end: end)
    }
}

// MARK: - Search Results
public struct SearchResult: Codable, Identifiable {
    public let id: String
    public let title: String
    public let snippet: String
    public let contentType: SearchContentType
    public let source: String
    public let url: URL?
    public let imageURL: URL?
    public let createdAt: Date
    public let relevanceScore: Double
    public let highlights: [SearchHighlight]
    public let metadata: [String: AnyCodable]
    
    public init(
        id: String,
        title: String,
        snippet: String,
        contentType: SearchContentType,
        source: String,
        url: URL? = nil,
        imageURL: URL? = nil,
        createdAt: Date = Date(),
        relevanceScore: Double = 0.0,
        highlights: [SearchHighlight] = [],
        metadata: [String: AnyCodable] = [:]
    ) {
        self.id = id
        self.title = title
        self.snippet = snippet
        self.contentType = contentType
        self.source = source
        self.url = url
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.relevanceScore = relevanceScore
        self.highlights = highlights
        self.metadata = metadata
    }
}

public struct SearchHighlight: Codable {
    public let field: String
    public let fragments: [String]
    
    public init(field: String, fragments: [String]) {
        self.field = field
        self.fragments = fragments
    }
}

public enum SearchContentType: String, Codable, CaseIterable {
    case bibleVerse = "bible_verse"
    case prayer = "prayer"
    case devotional = "devotional"
    case article = "article"
    case video = "video"
    case podcast = "podcast"
    case lifeSituation = "life_situation"
    case community = "community"
    case book = "book"
    case sermon = "sermon"
    
    public var displayName: String {
        switch self {
        case .bibleVerse: return "Bible Verses"
        case .prayer: return "Prayers"
        case .devotional: return "Devotionals"
        case .article: return "Articles"
        case .video: return "Videos"
        case .podcast: return "Podcasts"
        case .lifeSituation: return "Life Situations"
        case .community: return "Community"
        case .book: return "Books"
        case .sermon: return "Sermons"
        }
    }
    
    public var iconName: String {
        switch self {
        case .bibleVerse: return "book.closed"
        case .prayer: return "hands.clap"
        case .devotional: return "heart.text.square"
        case .article: return "doc.text"
        case .video: return "play.rectangle"
        case .podcast: return "mic"
        case .lifeSituation: return "person.fill.questionmark"
        case .community: return "person.3"
        case .book: return "books.vertical"
        case .sermon: return "speaker.wave.2"
        }
    }
}

// MARK: - Search Response
public struct SearchResponse: Codable {
    public let results: [SearchResult]
    public let totalCount: Int
    public let query: String
    public let searchTime: TimeInterval
    public let suggestions: [String]
    public let facets: SearchFacets
    public let pagination: PaginationInfo
    
    public init(
        results: [SearchResult],
        totalCount: Int,
        query: String,
        searchTime: TimeInterval,
        suggestions: [String] = [],
        facets: SearchFacets = SearchFacets(),
        pagination: PaginationInfo
    ) {
        self.results = results
        self.totalCount = totalCount
        self.query = query
        self.searchTime = searchTime
        self.suggestions = suggestions
        self.facets = facets
        self.pagination = pagination
    }
    
    public var hasResults: Bool {
        !results.isEmpty
    }
}

public struct SearchFacets: Codable {
    public let contentTypes: [FacetCount]
    public let sources: [FacetCount]
    public let categories: [FacetCount]
    public let tags: [FacetCount]
    
    public init(
        contentTypes: [FacetCount] = [],
        sources: [FacetCount] = [],
        categories: [FacetCount] = [],
        tags: [FacetCount] = []
    ) {
        self.contentTypes = contentTypes
        self.sources = sources
        self.categories = categories
        self.tags = tags
    }
}

public struct FacetCount: Codable {
    public let name: String
    public let count: Int
    
    public init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

public struct PaginationInfo: Codable {
    public let currentPage: Int
    public let totalPages: Int
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool
    
    public init(currentPage: Int, totalPages: Int) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.hasNextPage = currentPage < totalPages
        self.hasPreviousPage = currentPage > 1
    }
}

// MARK: - Search History
public struct SearchHistoryItem: Codable, Identifiable {
    public let id: String
    public let query: String
    public let timestamp: Date
    public let resultCount: Int
    
    public init(id: String = UUID().uuidString, query: String, timestamp: Date = Date(), resultCount: Int = 0) {
        self.id = id
        self.query = query
        self.timestamp = timestamp
        self.resultCount = resultCount
    }
}

// MARK: - Search Suggestions
public struct SearchSuggestion: Codable, Identifiable {
    public let id: String
    public let text: String
    public let type: SuggestionType
    public let score: Double
    
    public init(id: String = UUID().uuidString, text: String, type: SuggestionType, score: Double = 0.0) {
        self.id = id
        self.text = text
        self.type = type
        self.score = score
    }
}

public enum SuggestionType: String, Codable {
    case query = "query"
    case completion = "completion"
    case trending = "trending"
    case recent = "recent"
}