import Foundation

public struct SearchState: Equatable {
    public var query: String = ""
    public var selectedFilter: SearchFilter = .all
    public var searchResults: [SearchResult] = []
    public var recentSearches: [String] = []
    public var popularSearches: [String] = ["Love", "Faith", "Peace", "Hope", "Grace", "Prayer"]
    public var isSearching: Bool = false
    public var error: Error?
    
    public static func == (lhs: SearchState, rhs: SearchState) -> Bool {
        lhs.query == rhs.query &&
        lhs.selectedFilter == rhs.selectedFilter &&
        lhs.searchResults == rhs.searchResults &&
        lhs.recentSearches == rhs.recentSearches &&
        lhs.popularSearches == rhs.popularSearches &&
        lhs.isSearching == rhs.isSearching &&
        (lhs.error == nil && rhs.error == nil || lhs.error != nil && rhs.error != nil)
    }
    
    public var hasResults: Bool {
        !searchResults.isEmpty
    }
    
    public var showEmptyState: Bool {
        !isSearching && query.isEmpty && searchResults.isEmpty
    }
    
    public var showNoResults: Bool {
        !isSearching && !query.isEmpty && searchResults.isEmpty
    }
}