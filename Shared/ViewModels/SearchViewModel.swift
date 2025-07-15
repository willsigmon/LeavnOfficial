import Foundation
import SwiftUI
import Combine

@MainActor
public final class SearchViewModel: BaseViewModel {
    @Published public var searchText: String = ""
    @Published public var searchResults: [BibleSearchResult] = []
    @Published public var isSearching: Bool = false
    @Published public var recentSearches: [String] = []
    
    private let searchService: SearchServiceProtocol
    private let bibleService: BibleServiceProtocol
    
    public init(searchService: SearchServiceProtocol, bibleService: BibleServiceProtocol, analyticsService: AnalyticsServiceProtocol? = nil) {
        self.searchService = searchService
        self.bibleService = bibleService
        super.init(analyticsService: analyticsService)
        
        setupSearchBinding()
    }
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if !searchText.isEmpty {
                    Task {
                        await self?.performSearch(searchText)
                    }
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
    }
    
    public func performSearch(_ query: String) async {
        guard !query.isEmpty else { return }
        
        isSearching = true
        
        do {
            let results = try await searchService.searchBible(query: query, translation: "ESV", limit: 50)
            searchResults = results
            
            // Add to recent searches
            if !recentSearches.contains(query) {
                recentSearches.insert(query, at: 0)
                if recentSearches.count > 10 {
                    recentSearches.removeLast()
                }
            }
        } catch {
            handleError(error)
        }
        
        isSearching = false
    }
    
    public func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    public func clearRecentSearches() {
        recentSearches.removeAll()
    }
}