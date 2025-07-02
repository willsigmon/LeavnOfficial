import Foundation
import LeavnCore
import Combine

// MARK: - Search Error

public enum SearchError: Error, LocalizedError, Equatable {
    case networkError(message: String)
    case decodingError(message: String)
    case serviceError(message: String)
    case invalidQuery
    case invalidBook
    case invalidChapter
    case invalidTranslation
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Data Error: \(message)"
        case .serviceError(let message):
            return "Service Error: \(message)"
        case .invalidQuery:
            return "Invalid search query"
        case .invalidBook:
            return "Invalid book specified"
        case .invalidChapter:
            return "Invalid chapter specified"
        case .invalidTranslation:
            return "Invalid translation specified"
        }
    }
    
    public static func == (lhs: SearchError, rhs: SearchError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let lMsg), .networkError(let rMsg)):
            return lMsg == rMsg
        case (.decodingError(let lMsg), .decodingError(let rMsg)):
            return lMsg == rMsg
        case (.serviceError(let lMsg), .serviceError(let rMsg)):
            return lMsg == rMsg
        case (.invalidQuery, .invalidQuery),
             (.invalidBook, .invalidBook),
             (.invalidChapter, .invalidChapter),
             (.invalidTranslation, .invalidTranslation):
            return true
        default:
            return false
        }
    }
}

// MARK: - Production Search Service Implementation

public actor ProductionSearchService: SearchServiceProtocol {
    
    // MARK: - Properties
    
    private let bibleService: BibleServiceProtocol
    private let cacheService: CacheServiceProtocol
    private var isInitialized = false

    // Search history management
    private let maxSearchHistory = 50
    private let searchHistoryKey = "search_history"

    // Search performance optimization
    private let maxConcurrentBookSearches = 5
    private let searchTimeoutSeconds: TimeInterval = 30

    // MARK: - Initialization

    public init(bibleService: BibleServiceProtocol, cacheService: CacheServiceProtocol) {
        self.bibleService = bibleService
        self.cacheService = cacheService
    }
    
    // MARK: - SearchServiceProtocol Implementation
    
    public func initialize() async throws {
        isInitialized = true
        // Initialize any required resources here
        print("🔍 ProductionSearchService initialized")
    }
    
    // MARK: - SearchServiceProtocol Implementation
    
    public func search(query: String, options: LeavnCore.SearchOptions) async throws -> [LeavnCore.APISearchResult] {
        guard !query.isEmpty else {
            return []
        }
        
        // Generate cache key
        let cacheKey = "search_\(options.filter.rawValue)_\(options.limit)_\(query)"
        
        // Check cache first
        if let cachedResults: [APISearchResult] = await cacheService.get(cacheKey, type: [APISearchResult].self) {
            // Update search history in the background
            Task {
                await addToSearchHistory(query: query)
            }
            return cachedResults
        }
        
        // Add to search history
        await addToSearchHistory(query: query)
        
        // Get books to search based on filter
        let allBooks = try await bibleService.getBooks()
        let booksToSearch = getBooks(for: options.filter, allBooks: allBooks)
        
        // Search each book and collect results
        var results: [APISearchResult] = []
        
        for book in booksToSearch {
            let bookResults = try await searchInBook(book: book, query: query, options: options)
            results.append(contentsOf: bookResults)
            
            // Limit results if needed
            if results.count >= options.limit {
                let limitedResults = Array(results.prefix(options.limit))
                // Cache the results for 1 hour
                let expirationDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
                await cacheService.set(cacheKey, value: limitedResults, expirationDate: expirationDate)
                return limitedResults
            }
        }
        
        // Cache the final results for 1 hour
        let expirationDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        await cacheService.set(cacheKey, value: results, expirationDate: expirationDate)
        return results
    }
    
    public func getRecentSearches() async -> [String] {
        await withCheckedContinuation { continuation in
            let searches = UserDefaults.standard.stringArray(forKey: searchHistoryKey) ?? []
            continuation.resume(returning: searches)
        }
    }
    
    public func clearRecentSearches() async {
        await withCheckedContinuation { continuation in
            UserDefaults.standard.removeObject(forKey: searchHistoryKey)
            continuation.resume()
        }
    }
    
    // MARK: - Private Methods
    
    private func normalizeQuery(_ query: String) -> String {
        return query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private func searchCacheKey(query: String, options: SearchOptions) -> String {
        "search_\(query)_\(options.filter.rawValue)_\(options.limit)"
    }
    
    private func saveSearch(_ query: String) async {
        var searches = await getRecentSearches()
        
        // Remove if already exists
        searches.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
        
        // Add to beginning
        searches.insert(query, at: 0)
        
        // Trim if needed
        if searches.count > maxSearchHistory {
            searches = Array(searches.prefix(maxSearchHistory))
        }
        
        await cacheService.set(searchHistoryKey, value: searches, expirationDate: nil)
    }
    
    private func getBooks(for filter: LeavnCore.SearchFilter, allBooks: [BibleBook]) -> [BibleBook] {
        switch filter {
        case .all:
            return allBooks
        case .oldTestament:
            return allBooks.filter { $0.testament == .old }
        case .newTestament:
            return allBooks.filter { $0.testament == .new }
        case .gospels:
            return allBooks.filter { ["mat", "mrk", "luk", "jhn"].contains($0.id) }
        case .psalms:
            return allBooks.filter { $0.id == "psa" }
        case .proverbs:
            return allBooks.filter { $0.id == "pro" }
        }
    }
    
    // MARK: - Search Implementation
    
    private func performSearch(
        query: String,
        books: [BibleBook],
        options: LeavnCore.SearchOptions
    ) async throws -> [LeavnCore.APISearchResult] {
        var results: [APISearchResult] = []
        
        // Process books in batches to avoid too many concurrent tasks
        for bookBatch in books.chunked(into: maxConcurrentBookSearches) {
            let batchResults = try await withThrowingTaskGroup(of: [APISearchResult].self) { group in
                for book in bookBatch {
                    group.addTask {
                        try await self.searchInBook(book: book, query: query, options: options)
                    }
                }
                
                var batchResults: [APISearchResult] = []
                for try await bookResults in group {
                    batchResults.append(contentsOf: bookResults)
                }
                return batchResults
            }
            
            results.append(contentsOf: batchResults)
            
            // Early exit if we've reached the limit
            if results.count >= options.limit {
                results = Array(results.prefix(options.limit))
                break
            }
        }
        
        return results
    }
    

    
    private nonisolated func searchInChapter(
        book: BibleBook,
        chapter: Int,
        query: String,
        options: LeavnCore.SearchOptions
    ) async throws -> [LeavnCore.APISearchResult] {
        guard !query.isEmpty else {
            return []
        }
        
        // Get the chapter content from the Bible service
        let translationId = options.translation ?? "NIV"
        
        // Create a BibleTranslation with required parameters
        let translation = BibleTranslation(
            id: translationId.lowercased(),
            name: translationId,  // Using ID as name for simplicity
            abbreviation: String(translationId.prefix(3)).uppercased(),
            language: "English",  // Default language
            languageCode: "en"    // Default language code
        )
        
        do {
            let chapterContent = try await bibleService.getChapter(
                book: book.name,
                chapter: chapter,
                translation: translation
            )
            
            // Search through the verses
            var results: [APISearchResult] = []
            let queryLowercased = query.lowercased()
            
            for verse in chapterContent.verses {
                let verseText = verse.text.lowercased()
                
                // Simple contains check - could be enhanced with more sophisticated matching
                if verseText.contains(queryLowercased) {
                    let result = APISearchResult(
                        id: "\(book.id)_\(chapter)_\(verse.verse)",
                        bookId: book.id,
                        bookName: book.name,
                        chapter: chapter,
                        verse: verse.verse,
                        text: verse.text,
                        translation: translationId
                    )
                    results.append(result)
                }
            }
            
            return results
            
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw SearchError.networkError(message: "No internet connection. Please check your network and try again.")
        } catch is DecodingError {
            throw SearchError.decodingError(message: "Failed to parse the Bible chapter data.")
        } catch {
            throw SearchError.serviceError(message: "An error occurred while searching: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Search Methods
    
    // MARK: - Private Methods
    
    private func addToSearchHistory(query: String) async {
        await withCheckedContinuation { continuation in
            // Use a dedicated queue for thread safety
            let searchHistoryQueue = DispatchQueue(label: "com.leavn.searchHistory")
            
            searchHistoryQueue.async {
                var searches = UserDefaults.standard.stringArray(forKey: self.searchHistoryKey) ?? []
                
                // Remove if already exists (case-insensitive check)
                searches.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
                
                // Add to beginning
                searches.insert(query, at: 0)
                
                // Limit the history size
                let maxHistorySize = 20
                if searches.count > maxHistorySize {
                    searches = Array(searches.prefix(maxHistorySize))
                }
                
                // Save to UserDefaults
                UserDefaults.standard.set(searches, forKey: self.searchHistoryKey)
                
                // Call the continuation to resume the task
                continuation.resume()
            }
        }
    }
    
    private func searchInBook(
        book: BibleBook,
        query: String,
        options: LeavnCore.SearchOptions
    ) async throws -> [LeavnCore.APISearchResult] {
        var results: [APISearchResult] = []
        let translation = options.translation ?? "NIV" // Default to NIV if none specified
        
        // Create a BibleTranslation with required parameters
        let translationObject = BibleTranslation(
            id: translation.lowercased(),
            name: translation,  // Using ID as name for simplicity
            abbreviation: String(translation.prefix(3)).uppercased(),
            language: "English",  // Default language
            languageCode: "en"    // Default language code
        )
        
        // Search chapter by chapter
        for chapter in 1...book.chapterCount {
            do {
                let chapterContent = try await bibleService.getChapter(
                    book: book.id,
                    chapter: chapter,
                    translation: translationObject
                )
                
                // Search in verses
                for verse in chapterContent.verses {
                    if verse.text.localizedCaseInsensitiveContains(query) {
                        let result = APISearchResult(
                            id: "\(book.id)-\(chapter)-\(verse.verse)",
                            bookId: book.id,
                            bookName: book.name,
                            chapter: chapter,
                            verse: verse.verse,
                            text: verse.text,
                            translation: translation
                        )
                        results.append(result)
                        
                        // Limit results if needed
                        if results.count >= options.limit {
                            return results
                        }
                    }
                }
            } catch {
                // Log error but continue with next chapter
                print("Error searching chapter \(chapter) of \(book.name): \(error)")
            }
        }
        
        return results
    }
}

