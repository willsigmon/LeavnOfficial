import Foundation
import LeavnCore
import NetworkingKit
import PersistenceKit

public final class DefaultSearchRepository: SearchRepository {
    private let networkService: NetworkService
    private let localStorage: Storage
    private let cacheStorage: Storage
    private let searchAPIClient: SearchAPIClient
    
    // Storage keys
    private let searchHistoryKey = "search_history"
    private let savedSearchesKey = "saved_searches"
    private let searchCacheKey = "search_cache"
    
    public init(
        networkService: NetworkService,
        localStorage: Storage,
        cacheStorage: Storage
    ) {
        self.networkService = networkService
        self.localStorage = localStorage
        self.cacheStorage = cacheStorage
        self.searchAPIClient = SearchAPIClient(networkService: networkService)
    }
    
    // MARK: - Core Search Operations
    public func search(query: SearchQuery) async throws -> SearchResponse {
        // Check cache first for exact same query
        let cacheKey = "\(searchCacheKey)_\(query.text.lowercased())_\(query.hashValue)"
        if let cachedResponse = try await cacheStorage.load(SearchResponse.self, forKey: cacheKey),
           !shouldRefreshCache(cachedResponse) {
            return cachedResponse
        }
        
        // Perform search via API
        let response = try await searchAPIClient.search(query: query)
        
        // Cache the response
        try await cacheStorage.save(response, forKey: cacheKey)
        
        return response
    }
    
    public func getSuggestions(for query: String, limit: Int) async throws -> [SearchSuggestion] {
        try await searchAPIClient.getSuggestions(query: query, limit: limit)
    }
    
    public func getTrendingSearches(limit: Int) async throws -> [String] {
        try await searchAPIClient.getTrendingSearches(limit: limit)
    }
    
    // MARK: - Search History Management
    public func getSearchHistory(limit: Int) async throws -> [SearchHistoryItem] {
        let history = try await localStorage.load([SearchHistoryItem].self, forKey: searchHistoryKey) ?? []
        return Array(history.prefix(limit))
    }
    
    public func saveSearchToHistory(_ query: String, resultCount: Int) async throws {
        var history = try await localStorage.load([SearchHistoryItem].self, forKey: searchHistoryKey) ?? []
        
        // Remove duplicate if exists
        history.removeAll { $0.query.lowercased() == query.lowercased() }
        
        // Add new item at the beginning
        let newItem = SearchHistoryItem(
            query: query,
            timestamp: Date(),
            resultCount: resultCount
        )
        history.insert(newItem, at: 0)
        
        // Keep only last 50 items
        if history.count > 50 {
            history = Array(history.prefix(50))
        }
        
        try await localStorage.save(history, forKey: searchHistoryKey)
    }
    
    public func clearSearchHistory() async throws {
        try await localStorage.delete(forKey: searchHistoryKey)
    }
    
    public func deleteSearchHistoryItem(id: String) async throws {
        var history = try await localStorage.load([SearchHistoryItem].self, forKey: searchHistoryKey) ?? []
        history.removeAll { $0.id == id }
        try await localStorage.save(history, forKey: searchHistoryKey)
    }
    
    // MARK: - Saved Searches
    public func getSavedSearches() async throws -> [SearchQuery] {
        try await localStorage.load([SearchQuery].self, forKey: savedSearchesKey) ?? []
    }
    
    public func saveSearch(_ query: SearchQuery, name: String) async throws {
        var savedSearches = try await getSavedSearches()
        
        // Create a new query with the name in metadata
        var queryWithName = query
        // Note: This would require adding a name field to SearchQuery or using metadata
        
        savedSearches.append(queryWithName)
        try await localStorage.save(savedSearches, forKey: savedSearchesKey)
    }
    
    public func deleteSavedSearch(id: String) async throws {
        var savedSearches = try await getSavedSearches()
        // Note: This would require adding an id field to SearchQuery
        // savedSearches.removeAll { $0.id == id }
        try await localStorage.save(savedSearches, forKey: savedSearchesKey)
    }
    
    // MARK: - Search Analytics
    public func trackSearchQuery(_ query: String, resultCount: Int) async throws {
        try await searchAPIClient.trackSearchQuery(query: query, resultCount: resultCount)
    }
    
    public func trackSearchResultClick(resultId: String, position: Int) async throws {
        try await searchAPIClient.trackSearchResultClick(resultId: resultId, position: position)
    }
    
    public func getPopularSearchTerms(timeframe: SearchTimeframe) async throws -> [FacetCount] {
        try await searchAPIClient.getPopularSearchTerms(timeframe: timeframe.rawValue)
    }
    
    // MARK: - Advanced Search Operations
    public func searchWithinResults(originalQuery: SearchQuery, refinement: String) async throws -> SearchResponse {
        // Combine original query with refinement
        let combinedQuery = SearchQuery(
            text: "\(originalQuery.text) \(refinement)",
            filters: originalQuery.filters,
            sortOptions: originalQuery.sortOptions,
            pagination: originalQuery.pagination
        )
        
        return try await search(query: combinedQuery)
    }
    
    public func getRelatedSearches(for query: String) async throws -> [String] {
        try await searchAPIClient.getRelatedSearches(query: query)
    }
    
    public func getSearchResultById(_ id: String) async throws -> SearchResult? {
        try await searchAPIClient.getSearchResultById(id)
    }
    
    // MARK: - Content-Specific Search
    public func searchBibleVerses(query: String, translation: String?) async throws -> [SearchResult] {
        let searchQuery = SearchQuery(
            text: query,
            filters: SearchFilters(contentTypes: [.bibleVerse])
        )
        
        let response = try await search(query: searchQuery)
        return response.results.filter { $0.contentType == .bibleVerse }
    }
    
    public func searchPrayers(query: String, category: String?) async throws -> [SearchResult] {
        var filters = SearchFilters(contentTypes: [.prayer])
        if let category = category {
            filters = SearchFilters(
                contentTypes: [.prayer],
                categories: [category]
            )
        }
        
        let searchQuery = SearchQuery(text: query, filters: filters)
        let response = try await search(query: searchQuery)
        return response.results.filter { $0.contentType == .prayer }
    }
    
    public func searchLifeSituations(query: String) async throws -> [SearchResult] {
        let searchQuery = SearchQuery(
            text: query,
            filters: SearchFilters(contentTypes: [.lifeSituation])
        )
        
        let response = try await search(query: searchQuery)
        return response.results.filter { $0.contentType == .lifeSituation }
    }
    
    public func searchCommunityContent(query: String, contentType: String?) async throws -> [SearchResult] {
        let searchQuery = SearchQuery(
            text: query,
            filters: SearchFilters(contentTypes: [.community])
        )
        
        let response = try await search(query: searchQuery)
        return response.results.filter { $0.contentType == .community }
    }
    
    // MARK: - Private Helpers
    private func shouldRefreshCache(_ response: SearchResponse) -> Bool {
        // Cache for 5 minutes
        let cacheTimeout: TimeInterval = 5 * 60
        // Note: This would require adding a timestamp to SearchResponse
        // return Date().timeIntervalSince(response.timestamp) > cacheTimeout
        return false // For now, don't refresh cache
    }
}

// MARK: - Search API Client
private final class SearchAPIClient: BaseAPIClient {
    
    func search(query: SearchQuery) async throws -> SearchResponse {
        var parameters: [String: Any] = [
            "q": query.text,
            "page": query.pagination.page,
            "limit": query.pagination.limit
        ]
        
        // Add filters
        if !query.filters.contentTypes.isEmpty {
            parameters["content_types"] = query.filters.contentTypes.map { $0.rawValue }
        }
        
        if !query.filters.categories.isEmpty {
            parameters["categories"] = query.filters.categories
        }
        
        if !query.filters.tags.isEmpty {
            parameters["tags"] = query.filters.tags
        }
        
        if !query.filters.sources.isEmpty {
            parameters["sources"] = query.filters.sources
        }
        
        if let dateRange = query.filters.dateRange {
            parameters["start_date"] = ISO8601DateFormatter().string(from: dateRange.start)
            parameters["end_date"] = ISO8601DateFormatter().string(from: dateRange.end)
        }
        
        // Add sorting
        parameters["sort_by"] = query.sortOptions.sortBy.rawValue
        parameters["sort_order"] = query.sortOptions.order.rawValue
        
        let endpoint = Endpoint(
            path: "/search",
            parameters: parameters
        )
        
        return try await networkService.request(endpoint)
    }
    
    func getSuggestions(query: String, limit: Int) async throws -> [SearchSuggestion] {
        let endpoint = Endpoint(
            path: "/search/suggestions",
            parameters: [
                "q": query,
                "limit": limit
            ]
        )
        
        let response: SuggestionsResponseDTO = try await networkService.request(endpoint)
        return response.suggestions
    }
    
    func getTrendingSearches(limit: Int) async throws -> [String] {
        let endpoint = Endpoint(
            path: "/search/trending",
            parameters: ["limit": limit]
        )
        
        let response: TrendingSearchesResponseDTO = try await networkService.request(endpoint)
        return response.queries
    }
    
    func trackSearchQuery(query: String, resultCount: Int) async throws {
        let endpoint = Endpoint(
            path: "/search/analytics/query",
            method: .post,
            parameters: [
                "query": query,
                "result_count": resultCount,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func trackSearchResultClick(resultId: String, position: Int) async throws {
        let endpoint = Endpoint(
            path: "/search/analytics/click",
            method: .post,
            parameters: [
                "result_id": resultId,
                "position": position,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func getPopularSearchTerms(timeframe: String) async throws -> [FacetCount] {
        let endpoint = Endpoint(
            path: "/search/analytics/popular",
            parameters: ["timeframe": timeframe]
        )
        
        let response: PopularSearchTermsResponseDTO = try await networkService.request(endpoint)
        return response.terms
    }
    
    func getRelatedSearches(query: String) async throws -> [String] {
        let endpoint = Endpoint(
            path: "/search/related",
            parameters: ["q": query]
        )
        
        let response: RelatedSearchesResponseDTO = try await networkService.request(endpoint)
        return response.related
    }
    
    func getSearchResultById(_ id: String) async throws -> SearchResult? {
        let endpoint = Endpoint(path: "/search/result/\(id)")
        
        do {
            return try await networkService.request(endpoint)
        } catch {
            if case LeavnError.notFound = error {
                return nil
            }
            throw error
        }
    }
}

// MARK: - Response DTOs
private struct SuggestionsResponseDTO: Codable {
    let suggestions: [SearchSuggestion]
}

private struct TrendingSearchesResponseDTO: Codable {
    let queries: [String]
}

private struct PopularSearchTermsResponseDTO: Codable {
    let terms: [FacetCount]
}

private struct RelatedSearchesResponseDTO: Codable {
    let related: [String]
}