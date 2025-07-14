import Foundation
import LeavnCore

// MARK: - Search Repository Protocol
public protocol SearchRepository: Repository {
    // Core Search Operations
    func search(query: SearchQuery) async throws -> SearchResponse
    func getSuggestions(for query: String, limit: Int) async throws -> [SearchSuggestion]
    func getTrendingSearches(limit: Int) async throws -> [String]
    
    // Search History Management
    func getSearchHistory(limit: Int) async throws -> [SearchHistoryItem]
    func saveSearchToHistory(_ query: String, resultCount: Int) async throws
    func clearSearchHistory() async throws
    func deleteSearchHistoryItem(id: String) async throws
    
    // Saved Searches
    func getSavedSearches() async throws -> [SearchQuery]
    func saveSearch(_ query: SearchQuery, name: String) async throws
    func deleteSavedSearch(id: String) async throws
    
    // Search Analytics
    func trackSearchQuery(_ query: String, resultCount: Int) async throws
    func trackSearchResultClick(resultId: String, position: Int) async throws
    func getPopularSearchTerms(timeframe: SearchTimeframe) async throws -> [FacetCount]
    
    // Advanced Search Operations
    func searchWithinResults(originalQuery: SearchQuery, refinement: String) async throws -> SearchResponse
    func getRelatedSearches(for query: String) async throws -> [String]
    func getSearchResultById(_ id: String) async throws -> SearchResult?
    
    // Content-Specific Search
    func searchBibleVerses(query: String, translation: String?) async throws -> [SearchResult]
    func searchPrayers(query: String, category: String?) async throws -> [SearchResult]
    func searchLifeSituations(query: String) async throws -> [SearchResult]
    func searchCommunityContent(query: String, contentType: String?) async throws -> [SearchResult]
}

// MARK: - Supporting Types
public enum SearchTimeframe: String, CaseIterable {
    case today = "today"
    case thisWeek = "this_week"
    case thisMonth = "this_month"
    case thisYear = "this_year"
    case allTime = "all_time"
    
    public var displayName: String {
        switch self {
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .thisYear: return "This Year"
        case .allTime: return "All Time"
        }
    }
    
    public var dateRange: DateRange? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return DateRange(start: startOfDay, end: now)
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return DateRange(start: startOfWeek, end: now)
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return DateRange(start: startOfMonth, end: now)
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return DateRange(start: startOfYear, end: now)
        case .allTime:
            return nil
        }
    }
}