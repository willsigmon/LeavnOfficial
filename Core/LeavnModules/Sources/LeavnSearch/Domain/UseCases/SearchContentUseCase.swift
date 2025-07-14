import Foundation
import LeavnCore

// MARK: - Search Content Use Case
public struct SearchContentUseCase: UseCase {
    public typealias Input = SearchContentInput
    public typealias Output = SearchResponse
    
    private let searchRepository: SearchRepository
    private let analyticsService: AnalyticsService?
    
    public init(searchRepository: SearchRepository, analyticsService: AnalyticsService? = nil) {
        self.searchRepository = searchRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: SearchContentInput) async throws -> SearchResponse {
        // Validate input
        guard !input.query.isEmpty else {
            throw LeavnError.validationError(message: "Search query cannot be empty")
        }
        
        // Track search attempt
        analyticsService?.track(event: SearchAnalyticsEvent.searchAttempt(
            query: input.query.text,
            filters: input.query.filters,
            contentTypes: input.query.filters.contentTypes.map { $0.rawValue }
        ))
        
        do {
            // Perform search
            let response = try await searchRepository.search(query: input.query)
            
            // Save to search history if enabled
            if input.saveToHistory {
                try await searchRepository.saveSearchToHistory(
                    input.query.text,
                    resultCount: response.totalCount
                )
            }
            
            // Track successful search
            analyticsService?.track(event: SearchAnalyticsEvent.searchSuccess(
                query: input.query.text,
                resultCount: response.totalCount,
                searchTime: response.searchTime
            ))
            
            return response
        } catch {
            // Track search failure
            analyticsService?.track(event: SearchAnalyticsEvent.searchFailure(
                query: input.query.text,
                error: error.localizedDescription
            ))
            
            throw error
        }
    }
}

// MARK: - Get Search Suggestions Use Case
public struct GetSearchSuggestionsUseCase: UseCase {
    public typealias Input = GetSearchSuggestionsInput
    public typealias Output = [SearchSuggestion]
    
    private let searchRepository: SearchRepository
    
    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }
    
    public func execute(_ input: GetSearchSuggestionsInput) async throws -> [SearchSuggestion] {
        guard input.query.count >= input.minimumQueryLength else {
            return []
        }
        
        return try await searchRepository.getSuggestions(
            for: input.query,
            limit: input.limit
        )
    }
}

// MARK: - Get Search History Use Case
public struct GetSearchHistoryUseCase: UseCase {
    public typealias Input = Int // limit
    public typealias Output = [SearchHistoryItem]
    
    private let searchRepository: SearchRepository
    
    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }
    
    public func execute(_ input: Int) async throws -> [SearchHistoryItem] {
        try await searchRepository.getSearchHistory(limit: input)
    }
}

// MARK: - Save Search Use Case
public struct SaveSearchUseCase: UseCase {
    public typealias Input = SaveSearchInput
    public typealias Output = Void
    
    private let searchRepository: SearchRepository
    private let analyticsService: AnalyticsService?
    
    public init(searchRepository: SearchRepository, analyticsService: AnalyticsService? = nil) {
        self.searchRepository = searchRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: SaveSearchInput) async throws {
        try await searchRepository.saveSearch(input.query, name: input.name)
        
        analyticsService?.track(event: SearchAnalyticsEvent.searchSaved(
            query: input.query.text,
            name: input.name
        ))
    }
}

// MARK: - Track Search Result Click Use Case
public struct TrackSearchResultClickUseCase: UseCase {
    public typealias Input = TrackSearchResultClickInput
    public typealias Output = Void
    
    private let searchRepository: SearchRepository
    private let analyticsService: AnalyticsService?
    
    public init(searchRepository: SearchRepository, analyticsService: AnalyticsService? = nil) {
        self.searchRepository = searchRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: TrackSearchResultClickInput) async throws {
        try await searchRepository.trackSearchResultClick(
            resultId: input.resultId,
            position: input.position
        )
        
        analyticsService?.track(event: SearchAnalyticsEvent.searchResultClicked(
            resultId: input.resultId,
            position: input.position,
            query: input.query,
            contentType: input.contentType
        ))
    }
}

// MARK: - Input Models
public struct SearchContentInput {
    public let query: SearchQuery
    public let saveToHistory: Bool
    
    public init(query: SearchQuery, saveToHistory: Bool = true) {
        self.query = query
        self.saveToHistory = saveToHistory
    }
}

public struct GetSearchSuggestionsInput {
    public let query: String
    public let limit: Int
    public let minimumQueryLength: Int
    
    public init(query: String, limit: Int = 10, minimumQueryLength: Int = 2) {
        self.query = query
        self.limit = limit
        self.minimumQueryLength = minimumQueryLength
    }
}

public struct SaveSearchInput {
    public let query: SearchQuery
    public let name: String
    
    public init(query: SearchQuery, name: String) {
        self.query = query
        self.name = name
    }
}

public struct TrackSearchResultClickInput {
    public let resultId: String
    public let position: Int
    public let query: String
    public let contentType: String
    
    public init(resultId: String, position: Int, query: String, contentType: String) {
        self.resultId = resultId
        self.position = position
        self.query = query
        self.contentType = contentType
    }
}

// MARK: - Search Analytics Events
enum SearchAnalyticsEvent: AnalyticsEvent {
    case searchAttempt(query: String, filters: SearchFilters, contentTypes: [String])
    case searchSuccess(query: String, resultCount: Int, searchTime: TimeInterval)
    case searchFailure(query: String, error: String)
    case searchResultClicked(resultId: String, position: Int, query: String, contentType: String)
    case searchSaved(query: String, name: String)
    case searchHistoryCleared
    case searchFilterApplied(filterType: String, filterValue: String)
    case searchSorted(sortBy: String, order: String)
    
    var name: String {
        switch self {
        case .searchAttempt: return "search_attempt"
        case .searchSuccess: return "search_success"
        case .searchFailure: return "search_failure"
        case .searchResultClicked: return "search_result_clicked"
        case .searchSaved: return "search_saved"
        case .searchHistoryCleared: return "search_history_cleared"
        case .searchFilterApplied: return "search_filter_applied"
        case .searchSorted: return "search_sorted"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchAttempt(let query, let filters, let contentTypes):
            return [
                "query": query,
                "has_filters": !filters.isEmpty,
                "content_types": contentTypes,
                "filter_count": filters.categories.count + filters.tags.count + filters.sources.count
            ]
            
        case .searchSuccess(let query, let resultCount, let searchTime):
            return [
                "query": query,
                "result_count": resultCount,
                "search_time_ms": Int(searchTime * 1000)
            ]
            
        case .searchFailure(let query, let error):
            return [
                "query": query,
                "error": error
            ]
            
        case .searchResultClicked(let resultId, let position, let query, let contentType):
            return [
                "result_id": resultId,
                "position": position,
                "query": query,
                "content_type": contentType
            ]
            
        case .searchSaved(let query, let name):
            return [
                "query": query,
                "search_name": name
            ]
            
        case .searchHistoryCleared:
            return nil
            
        case .searchFilterApplied(let filterType, let filterValue):
            return [
                "filter_type": filterType,
                "filter_value": filterValue
            ]
            
        case .searchSorted(let sortBy, let order):
            return [
                "sort_by": sortBy,
                "sort_order": order
            ]
        }
    }
}