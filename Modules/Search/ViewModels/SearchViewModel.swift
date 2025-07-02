import Foundation
import LeavnCore
import LeavnServices
import SwiftUI
import OSLog

// MARK: - Type Aliases & Extensions

public typealias SearchResult = LeavnCore.SearchResult
private typealias APISearchResult = LeavnCore.APISearchResult
private typealias SearchOptions = LeavnCore.SearchOptions

private extension os.Logger {
    static let search = Logger(subsystem: "com.leavn.search", category: "ViewModel")
}

// MARK: - DIContainer Protocol for Testability

@MainActor
internal protocol DIContainerProtocol: AnyObject {
    var searchService: SearchServiceProtocol? { get }
    var bibleService: BibleServiceProtocol? { get }
    var analyticsService: AnalyticsServiceProtocol? { get }
}

extension DIContainer: DIContainerProtocol {}

// MARK: - Search View Model

@MainActor
public final class SearchViewModel: ObservableObject {

    // MARK: - Types

    public enum SearchError: Error, LocalizedError {
        case invalidSearchQuery
        case serviceUnavailable
        case unknown(Error)

        public var errorDescription: String? {
            switch self {
            case .invalidSearchQuery:
                return "Please enter a valid search query to begin."
            case .serviceUnavailable:
                return "The search service is currently unavailable. Please try again later."
            case .unknown(let error):
                return error.localizedDescription
            }
        }
    }

    // MARK: - Published Properties

    @Published public private(set) var searchResults: [SearchResult] = []
    @Published public private(set) var recentSearches: [String] = []
    @Published public private(set) var isSearching = false
    @Published public private(set) var error: Error?

    // MARK: - Services

    private let searchService: SearchServiceProtocol
    private let bibleService: BibleServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Private Properties

    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    internal init(
        container: DIContainerProtocol = DIContainer.shared,
        analytics: AnalyticsServiceProtocol? = nil
    ) {
        guard let searchService = container.searchService,
              let bibleService = container.bibleService else {
            fatalError("SearchService and BibleService are required.")
        }

        self.searchService = searchService
        self.bibleService = bibleService
        self.analyticsService = analytics

        Task {
            await loadRecentSearches()
        }
    }

    // MARK: - Public API

    public func search(query: String, filter: SearchFilter = .all) {
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            self.searchResults = []
            self.error = nil // Not an error, just clearing
            return
        }

        isSearching = true
        error = nil

        searchTask = Task {
            do {
                let options = SearchOptions(filter: filter)
                let apiResults = try await searchService.search(query: trimmedQuery, options: options)
                let mappedResults = mapResults(apiResults)
                
                self.searchResults = mappedResults
                self.addToRecentSearches(trimmedQuery)

                let event = AnalyticsEvent(
                    name: "search_performed",
                    parameters: [
                        "query": trimmedQuery,
                        "filter": filter.rawValue,
                        "result_count": String(mappedResults.count)
                    ]
                )
                await analyticsService?.track(event: event)

            } catch is CancellationError {
                Logger.search.info("Search for '\(trimmedQuery)' was cancelled.")
            } catch {
                Logger.search.error("Search failed for query '\(trimmedQuery)': \(error.localizedDescription)")
                self.error = SearchError.unknown(error)
            }
            
            self.isSearching = false
        }
    }

    public func clearSearch() {
        searchTask?.cancel()
        searchResults = []
        isSearching = false
        error = nil
    }

    public func clearRecentSearches() async {
        await searchService.clearRecentSearches()
        self.recentSearches = []
    }
    
    // MARK: - Private Helpers

    private func loadRecentSearches() async {
        let searches = await searchService.getRecentSearches()
        self.recentSearches = searches
    }

    private func addToRecentSearches(_ query: String) {
        // This should be handled by the SearchService to persist it
        // For now, just updating local state
        if let index = recentSearches.firstIndex(of: query) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }
    
    private func mapResults(_ apiResults: [APISearchResult]) -> [SearchResult] {
        return apiResults.map { result in
            SearchResult(
                id: UUID(), // The local model uses UUID, API uses String. We generate a new one.
                bookId: result.bookId,
                bookName: result.bookName,
                chapter: result.chapter,
                verse: result.verse,
                text: result.text,
                translation: result.translation
            )
        }
    }
}
