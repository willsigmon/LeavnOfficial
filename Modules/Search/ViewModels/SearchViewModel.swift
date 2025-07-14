import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [BibleSearchResult] = []
    @Published var libraryResults: [LibrarySearchResult] = []
    @Published var recentSearches: [SearchQuery] = []
    @Published var isSearching = false
    @Published var selectedFilter = "All"
    @Published var searchScope: SearchScope = .bible
    @Published var error: Error?
    
    let filters = ["All", "Old Testament", "New Testament", "Gospels", "Letters"]
    
    private let searchRepository: SearchRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private var searchTask: Task<Void, Never>?
    
    enum SearchScope: String, CaseIterable {
        case bible = "Bible"
        case library = "Library"
        case all = "All"
    }
    
    init(
        searchRepository: SearchRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.searchRepository = searchRepository ?? container.searchRepository
        self.analyticsService = analyticsService ?? container.analyticsService
        
        Task {
            await loadRecentSearches()
        }
    }
    
    func loadRecentSearches() async {
        do {
            recentSearches = try await searchRepository.getRecentSearches(limit: 10)
        } catch {
            print("Failed to load recent searches: \(error)")
        }
    }
    
    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            libraryResults = []
            return
        }
        
        // Cancel any existing search
        searchTask?.cancel()
        
        searchTask = Task {
            isSearching = true
            error = nil
            
            do {
                switch searchScope {
                case .bible:
                    searchResults = try await searchRepository.searchBible(
                        query: searchText,
                        translation: nil,
                        books: getFilteredBooks()
                    )
                    libraryResults = []
                    
                case .library:
                    libraryResults = try await searchRepository.searchLibrary(query: searchText)
                    searchResults = []
                    
                case .all:
                    async let bibleResults = searchRepository.searchBible(
                        query: searchText,
                        translation: nil,
                        books: getFilteredBooks()
                    )
                    async let libResults = searchRepository.searchLibrary(query: searchText)
                    
                    searchResults = try await bibleResults
                    libraryResults = try await libResults
                }
                
                // Save search query
                let query = SearchQuery(
                    query: searchText,
                    resultCount: searchResults.count + libraryResults.count
                )
                try await searchRepository.saveSearch(query)
                
                // Update recent searches
                await loadRecentSearches()
                
                // Track analytics
                analyticsService.track(event: "search_performed", properties: [
                    "query": searchText,
                    "scope": searchScope.rawValue,
                    "filter": selectedFilter,
                    "bible_results": searchResults.count,
                    "library_results": libraryResults.count
                ])
                
            } catch {
                self.error = error
                print("Search failed: \(error)")
            }
            
            isSearching = false
        }
    }
    
    func selectRecentSearch(_ query: SearchQuery) {
        searchText = query.query
        performSearch()
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        libraryResults = []
        searchTask?.cancel()
    }
    
    func clearRecentSearches() async {
        do {
            try await searchRepository.clearSearchHistory()
            recentSearches = []
            
            analyticsService.track(event: "search_history_cleared", properties: nil)
        } catch {
            self.error = error
            print("Failed to clear search history: \(error)")
        }
    }
    
    private func getFilteredBooks() -> [String]? {
        switch selectedFilter {
        case "Old Testament":
            return ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi"]
        case "New Testament":
            return ["Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"]
        case "Gospels":
            return ["Matthew", "Mark", "Luke", "John"]
        case "Letters":
            return ["Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude"]
        default:
            return nil
        }
    }
}

struct SearchResult: Identifiable {
    let id: String
    let reference: String
    let text: String
    let book: String
}