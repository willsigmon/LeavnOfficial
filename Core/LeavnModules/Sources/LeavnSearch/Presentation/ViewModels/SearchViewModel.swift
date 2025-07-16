import Foundation
import SwiftUI
import Combine

@MainActor
public final class SearchViewModel: StatefulViewModel<SearchViewState, SearchViewEvent> {
    private let networkService: NetworkServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let localStorage: UserDataManagerProtocol
    private let searchService: SearchServiceProtocol
    
    private let searchRepository: SearchRepository
    private let searchContentUseCase: SearchContentUseCase
    private let getSuggestionsUseCase: GetSearchSuggestionsUseCase
    private let getSearchHistoryUseCase: GetSearchHistoryUseCase
    private let saveSearchUseCase: SaveSearchUseCase
    private let trackClickUseCase: TrackSearchResultClickUseCase
    
    private var searchTask: Task<Void, Never>?
    private var suggestionsTask: Task<Void, Never>?
    
    public override init(initialState: SearchViewState = .init()) {
        let container = DIContainer.shared
        self.networkService = container.networkService
        self.analyticsService = container.analyticsService
        self.localStorage = container.userDataManager
        self.searchService = container.searchService
        
        self.searchRepository = DefaultSearchRepository(
            searchService: searchService,
            localStorage: localStorage
        )
        
        self.searchContentUseCase = SearchContentUseCase(
            searchRepository: searchRepository,
            analyticsService: analyticsService
        )
        
        self.getSuggestionsUseCase = GetSearchSuggestionsUseCase(
            searchRepository: searchRepository
        )
        
        self.getSearchHistoryUseCase = GetSearchHistoryUseCase(
            searchRepository: searchRepository
        )
        
        self.saveSearchUseCase = SaveSearchUseCase(
            searchRepository: searchRepository,
            analyticsService: analyticsService
        )
        
        self.trackClickUseCase = TrackSearchResultClickUseCase(
            searchRepository: searchRepository,
            analyticsService: analyticsService
        )
        
        super.init(initialState: initialState)
        
        // Load initial data
        Task {
            await loadSearchHistory()
            await loadTrendingSearches()
        }
    }
    
    deinit {
        searchTask?.cancel()
        suggestionsTask?.cancel()
    }
    
    public override func send(_ event: SearchViewEvent) {
        Task {
            await handle(event)
        }
    }
    
    private func handle(_ event: SearchViewEvent) async {
        switch event {
        case .search(let query):
            await performSearch(query: query)
            
        case .searchWithFilters(let query, let filters):
            await performSearchWithFilters(query: query, filters: filters)
            
        case .updateSearchText(let text):
            updateState { $0.searchText = text }
            await getSuggestions(for: text)
            
        case .selectSuggestion(let suggestion):
            updateState { $0.searchText = suggestion.text }
            await performSearch(query: suggestion.text)
            
        case .selectSearchHistory(let historyItem):
            updateState { $0.searchText = historyItem.query }
            await performSearch(query: historyItem.query)
            
        case .selectSearchResult(let result):
            await handleSearchResultSelection(result)
            
        case .applyFilter(let filterType, let value):
            await applyFilter(filterType: filterType, value: value)
            
        case .removeFilter(let filterType, let value):
            await removeFilter(filterType: filterType, value: value)
            
        case .clearFilters:
            await clearFilters()
            
        case .changeSorting(let sortBy, let order):
            await changeSorting(sortBy: sortBy, order: order)
            
        case .loadMore:
            await loadMoreResults()
            
        case .clearSearchHistory:
            await clearSearchHistory()
            
        case .saveCurrentSearch(let name):
            await saveCurrentSearch(name: name)
            
        case .showSearchInCategory(let category):
            await showSearchInCategory(category)
            
        case .getRelatedSearches:
            await getRelatedSearches()
        }
    }
    
    // MARK: - Search Operations
    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            updateState {
                $0.searchResults = []
                $0.isSearching = false
                $0.error = nil
            }
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        updateState {
            $0.isSearching = true
            $0.error = nil
            $0.currentPage = 1
        }
        
        searchTask = Task {
            do {
                let searchQuery = SearchQuery(
                    text: query,
                    filters: state.activeFilters,
                    sortOptions: state.sortOptions,
                    pagination: SearchPagination(page: 1)
                )
                
                let input = SearchContentInput(query: searchQuery, saveToHistory: true)
                let response = try await searchContentUseCase.execute(input)
                
                if !Task.isCancelled {
                    updateState {
                        $0.searchResults = response.results
                        $0.totalResults = response.totalCount
                        $0.searchTime = response.searchTime
                        $0.suggestions = response.suggestions.map { SearchSuggestion(text: $0, type: .completion) }
                        $0.facets = response.facets
                        $0.hasMoreResults = response.pagination.hasNextPage
                        $0.isSearching = false
                        $0.lastSearchQuery = query
                        $0.error = nil
                    }
                    
                    // Refresh search history
                    await loadSearchHistory()
                }
            } catch {
                if !Task.isCancelled {
                    updateState {
                        $0.isSearching = false
                        $0.error = error
                        $0.searchResults = []
                    }
                }
            }
        }
    }
    
    private func performSearchWithFilters(query: String, filters: SearchFilters) async {
        updateState { $0.activeFilters = filters }
        await performSearch(query: query)
    }
    
    private func getSuggestions(for query: String) async {
        guard !query.isEmpty else {
            updateState { $0.suggestions = [] }
            return
        }
        
        // Cancel previous suggestions request
        suggestionsTask?.cancel()
        
        suggestionsTask = Task {
            do {
                let input = GetSearchSuggestionsInput(query: query, limit: 8)
                let suggestions = try await getSuggestionsUseCase.execute(input)
                
                if !Task.isCancelled {
                    updateState { $0.suggestions = suggestions }
                }
            } catch {
                // Silently handle suggestions errors
            }
        }
    }
    
    // MARK: - Result Handling
    private func handleSearchResultSelection(_ result: SearchResult) async {
        // Track click analytics
        if let position = state.searchResults.firstIndex(where: { $0.id == result.id }) {
            let input = TrackSearchResultClickInput(
                resultId: result.id,
                position: position,
                query: state.lastSearchQuery,
                contentType: result.contentType.rawValue
            )
            
            try? await trackClickUseCase.execute(input)
        }
        
        updateState { $0.selectedResult = result }
        
        analyticsService.track(event: CommonAnalyticsEvent.search(
            query: state.lastSearchQuery,
            category: result.contentType.rawValue
        ))
    }
    
    // MARK: - Filter Management
    private func applyFilter(filterType: SearchFilterType, value: String) async {
        updateState {
            switch filterType {
            case .contentType:
                if let contentType = SearchContentType(rawValue: value) {
                    var contentTypes = $0.activeFilters.contentTypes
                    if !contentTypes.contains(contentType) {
                        contentTypes.append(contentType)
                        $0.activeFilters = SearchFilters(
                            contentTypes: contentTypes,
                            dateRange: $0.activeFilters.dateRange,
                            categories: $0.activeFilters.categories,
                            tags: $0.activeFilters.tags,
                            sources: $0.activeFilters.sources
                        )
                    }
                }
                
            case .category:
                var categories = $0.activeFilters.categories
                if !categories.contains(value) {
                    categories.append(value)
                    $0.activeFilters = SearchFilters(
                        contentTypes: $0.activeFilters.contentTypes,
                        dateRange: $0.activeFilters.dateRange,
                        categories: categories,
                        tags: $0.activeFilters.tags,
                        sources: $0.activeFilters.sources
                    )
                }
                
            case .tag:
                var tags = $0.activeFilters.tags
                if !tags.contains(value) {
                    tags.append(value)
                    $0.activeFilters = SearchFilters(
                        contentTypes: $0.activeFilters.contentTypes,
                        dateRange: $0.activeFilters.dateRange,
                        categories: $0.activeFilters.categories,
                        tags: tags,
                        sources: $0.activeFilters.sources
                    )
                }
                
            case .source:
                var sources = $0.activeFilters.sources
                if !sources.contains(value) {
                    sources.append(value)
                    $0.activeFilters = SearchFilters(
                        contentTypes: $0.activeFilters.contentTypes,
                        dateRange: $0.activeFilters.dateRange,
                        categories: $0.activeFilters.categories,
                        tags: $0.activeFilters.tags,
                        sources: sources
                    )
                }
            }
        }
        
        if !state.lastSearchQuery.isEmpty {
            await performSearch(query: state.lastSearchQuery)
        }
        
        analyticsService.track(event: SearchAnalyticsEvent.searchFilterApplied(
            filterType: filterType.rawValue,
            filterValue: value
        ))
    }
    
    private func removeFilter(filterType: SearchFilterType, value: String) async {
        updateState {
            switch filterType {
            case .contentType:
                let contentTypes = $0.activeFilters.contentTypes.filter { $0.rawValue != value }
                $0.activeFilters = SearchFilters(
                    contentTypes: contentTypes,
                    dateRange: $0.activeFilters.dateRange,
                    categories: $0.activeFilters.categories,
                    tags: $0.activeFilters.tags,
                    sources: $0.activeFilters.sources
                )
                
            case .category:
                let categories = $0.activeFilters.categories.filter { $0 != value }
                $0.activeFilters = SearchFilters(
                    contentTypes: $0.activeFilters.contentTypes,
                    dateRange: $0.activeFilters.dateRange,
                    categories: categories,
                    tags: $0.activeFilters.tags,
                    sources: $0.activeFilters.sources
                )
                
            case .tag:
                let tags = $0.activeFilters.tags.filter { $0 != value }
                $0.activeFilters = SearchFilters(
                    contentTypes: $0.activeFilters.contentTypes,
                    dateRange: $0.activeFilters.dateRange,
                    categories: $0.activeFilters.categories,
                    tags: tags,
                    sources: $0.activeFilters.sources
                )
                
            case .source:
                let sources = $0.activeFilters.sources.filter { $0 != value }
                $0.activeFilters = SearchFilters(
                    contentTypes: $0.activeFilters.contentTypes,
                    dateRange: $0.activeFilters.dateRange,
                    categories: $0.activeFilters.categories,
                    tags: $0.activeFilters.tags,
                    sources: sources
                )
            }
        }
        
        if !state.lastSearchQuery.isEmpty {
            await performSearch(query: state.lastSearchQuery)
        }
    }
    
    private func clearFilters() async {
        updateState { $0.activeFilters = SearchFilters() }
        
        if !state.lastSearchQuery.isEmpty {
            await performSearch(query: state.lastSearchQuery)
        }
    }
    
    // MARK: - Sorting
    private func changeSorting(sortBy: SearchSortBy, order: SortOrder) async {
        updateState {
            $0.sortOptions = SearchSortOptions(sortBy: sortBy, order: order)
        }
        
        if !state.lastSearchQuery.isEmpty {
            await performSearch(query: state.lastSearchQuery)
        }
        
        analyticsService.track(event: SearchAnalyticsEvent.searchSorted(
            sortBy: sortBy.rawValue,
            order: order.rawValue
        ))
    }
    
    // MARK: - Pagination
    private func loadMoreResults() async {
        guard state.hasMoreResults && !state.isLoadingMore else { return }
        
        updateState { 
            $0.isLoadingMore = true
            $0.currentPage += 1
        }
        
        do {
            let searchQuery = SearchQuery(
                text: state.lastSearchQuery,
                filters: state.activeFilters,
                sortOptions: state.sortOptions,
                pagination: SearchPagination(page: state.currentPage)
            )
            
            let input = SearchContentInput(query: searchQuery, saveToHistory: false)
            let response = try await searchContentUseCase.execute(input)
            
            updateState {
                $0.searchResults.append(contentsOf: response.results)
                $0.hasMoreResults = response.pagination.hasNextPage
                $0.isLoadingMore = false
            }
        } catch {
            updateState {
                $0.isLoadingMore = false
                $0.currentPage -= 1 // Revert page increment
            }
        }
    }
    
    // MARK: - History Management
    private func loadSearchHistory() async {
        do {
            let history = try await getSearchHistoryUseCase.execute(20)
            updateState { $0.searchHistory = history }
        } catch {
            // Silently handle history loading errors
        }
    }
    
    private func clearSearchHistory() async {
        do {
            try await searchRepository.clearSearchHistory()
            updateState { $0.searchHistory = [] }
            
            analyticsService.track(event: SearchAnalyticsEvent.searchHistoryCleared)
        } catch {
            updateState { $0.error = error }
        }
    }
    
    // MARK: - Save Search
    private func saveCurrentSearch(name: String) async {
        guard !state.lastSearchQuery.isEmpty else { return }
        
        let searchQuery = SearchQuery(
            text: state.lastSearchQuery,
            filters: state.activeFilters,
            sortOptions: state.sortOptions
        )
        
        let input = SaveSearchInput(query: searchQuery, name: name)
        
        do {
            try await saveSearchUseCase.execute(input)
            updateState { $0.searchSaved = true }
        } catch {
            updateState { $0.error = error }
        }
    }
    
    // MARK: - Category Search
    private func showSearchInCategory(_ category: SearchContentType) async {
        let filters = SearchFilters(contentTypes: [category])
        updateState { $0.activeFilters = filters }
        
        if !state.lastSearchQuery.isEmpty {
            await performSearch(query: state.lastSearchQuery)
        }
    }
    
    // MARK: - Related Searches
    private func getRelatedSearches() async {
        guard !state.lastSearchQuery.isEmpty else { return }
        
        do {
            let related = try await searchRepository.getRelatedSearches(for: state.lastSearchQuery)
            updateState { $0.relatedSearches = related }
        } catch {
            // Silently handle related searches errors
        }
    }
    
    private func loadTrendingSearches() async {
        do {
            let trending = try await searchRepository.getTrendingSearches(limit: 10)
            updateState { $0.trendingSearches = trending }
        } catch {
            // Silently handle trending searches errors
        }
    }
}

// MARK: - View State
public struct SearchViewState: ViewState {
    public var searchText: String = ""
    public var lastSearchQuery: String = ""
    public var searchResults: [SearchResult] = []
    public var suggestions: [SearchSuggestion] = []
    public var searchHistory: [SearchHistoryItem] = []
    public var trendingSearches: [String] = []
    public var relatedSearches: [String] = []
    
    // Filtering and Sorting
    public var activeFilters: SearchFilters = SearchFilters()
    public var sortOptions: SearchSortOptions = SearchSortOptions()
    public var facets: SearchFacets = SearchFacets()
    
    // Pagination
    public var currentPage: Int = 1
    public var totalResults: Int = 0
    public var hasMoreResults: Bool = false
    
    // Loading states
    public var isSearching: Bool = false
    public var isLoadingMore: Bool = false
    public var error: Error?
    
    // Results
    public var selectedResult: SearchResult?
    public var searchTime: TimeInterval = 0
    public var searchSaved: Bool = false
    
    public init() {}
}

// MARK: - View Events
public enum SearchViewEvent {
    case search(query: String)
    case searchWithFilters(query: String, filters: SearchFilters)
    case updateSearchText(String)
    case selectSuggestion(SearchSuggestion)
    case selectSearchHistory(SearchHistoryItem)
    case selectSearchResult(SearchResult)
    case applyFilter(SearchFilterType, value: String)
    case removeFilter(SearchFilterType, value: String)
    case clearFilters
    case changeSorting(SearchSortBy, SortOrder)
    case loadMore
    case clearSearchHistory
    case saveCurrentSearch(name: String)
    case showSearchInCategory(SearchContentType)
    case getRelatedSearches
}

// MARK: - Supporting Types
public enum SearchFilterType: String {
    case contentType = "content_type"
    case category = "category"
    case tag = "tag"
    case source = "source"
}