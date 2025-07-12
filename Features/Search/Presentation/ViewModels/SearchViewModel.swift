import SwiftUI
import Combine

@MainActor
public final class SearchViewModel: ObservableObject {
    @Published private(set) var state = SearchState()
    
    private let searchBibleUseCase: SearchBibleUseCaseProtocol
    private let recentSearchesUseCase: ManageRecentSearchesUseCaseProtocol
    private let coordinator: SearchCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    public init(
        searchBibleUseCase: SearchBibleUseCaseProtocol,
        recentSearchesUseCase: ManageRecentSearchesUseCaseProtocol,
        coordinator: SearchCoordinator
    ) {
        self.searchBibleUseCase = searchBibleUseCase
        self.recentSearchesUseCase = recentSearchesUseCase
        self.coordinator = coordinator
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Debounce search query changes
        $state
            .map(\.query)
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Actions
    
    public func onAppear() async {
        await loadRecentSearches()
    }
    
    public func updateQuery(_ query: String) {
        state.query = query
    }
    
    public func selectFilter(_ filter: SearchFilter) {
        state.selectedFilter = filter
        if !state.query.isEmpty {
            performSearch(query: state.query)
        }
    }
    
    public func selectSearchResult(_ result: SearchResult) {
        coordinator.navigateToSearchResult(result)
    }
    
    public func selectRecentSearch(_ search: String) {
        state.query = search
        performSearch(query: search)
    }
    
    public func selectPopularSearch(_ search: String) {
        state.query = search
        performSearch(query: search)
    }
    
    public func clearRecentSearches() async {
        do {
            try await recentSearchesUseCase.clearRecentSearches()
            state.recentSearches = []
        } catch {
            state.error = error
        }
    }
    
    public func clearSearch() {
        state.query = ""
        state.searchResults = []
    }
    
    // MARK: - Private Methods
    
    private func performSearch(query: String) {
        // Cancel any existing search
        searchTask?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            state.searchResults = []
            state.isSearching = false
            return
        }
        
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            self.state.isSearching = true
            self.state.error = nil
            
            do {
                let searchQuery = SearchQuery(
                    text: trimmedQuery,
                    filter: self.state.selectedFilter
                )
                
                let results = try await self.searchBibleUseCase.execute(query: searchQuery)
                
                // Check if task was cancelled
                if !Task.isCancelled {
                    self.state.searchResults = results
                    self.state.isSearching = false
                }
            } catch {
                if !Task.isCancelled {
                    self.state.error = error
                    self.state.isSearching = false
                }
            }
        }
    }
    
    private func loadRecentSearches() async {
        do {
            let searches = try await recentSearchesUseCase.getRecentSearches()
            state.recentSearches = searches
        } catch {
            // Silently fail for recent searches
            state.recentSearches = []
        }
    }
}