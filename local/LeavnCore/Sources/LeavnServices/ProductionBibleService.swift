import Foundation
import LeavnCore

// MARK: - Production Bible Service Implementation

public actor ProductionBibleService: BibleServiceProtocol {
    
    // MARK: - Properties
    
    private let baseURL = "https://bible-api.com"
    private let session: URLSession
    private let cacheService: CacheServiceProtocol
    private var isInitialized = false
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0
    
    // Cached translations for performance
    private var cachedTranslations: [BibleTranslation] = []
    
    // MARK: - Initialization
    
    public init(cacheService: CacheServiceProtocol) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: configuration)
        self.cacheService = cacheService
    }
    
    public func initialize() async throws {
        // Load available translations on initialization
        do {
            cachedTranslations = try await getAvailableTranslations()
            isInitialized = true
            print("📚 ProductionBibleService initialized with \(cachedTranslations.count) translations")
        } catch {
            // Allow initialization to succeed with offline data
            cachedTranslations = BibleTranslation.defaultTranslations
            isInitialized = true
            print("📚 ProductionBibleService initialized with offline data")
        }
    }
    
    // MARK: - BibleServiceProtocol Implementation
    
    public func getBooks() async throws -> [BibleBook] {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        return BibleBook.allCases
    }
    
    public func getVerse(book: String, chapter: Int, verse: Int, translation: BibleTranslation) async throws -> BibleVerse {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        // Try offline first for plane mode
        if let offlineVerse = OfflineBibleData.getOfflineVerse(bookId: book, chapter: chapter, verse: verse) {
            return offlineVerse
        }
        
        // Try online API
        do {
            let endpoint = "/\(book)+\(chapter):\(verse)"
            let response: BibleAPIResponse = try await fetchWithRetry(endpoint: endpoint)
            
            guard let verseData = response.verses.first else {
                throw ServiceError.data(.notFound)
            }
            
            return BibleVerse(
                id: "\(book)-\(chapter)-\(verse)-\(translation.abbreviation)",
                bookName: verseData.bookName,
                bookId: book,
                chapter: chapter,
                verse: verse,
                text: verseData.text.trimmingCharacters(in: .whitespacesAndNewlines),
                translation: translation.abbreviation
            )
        } catch {
            // Fallback to offline data if available
            if let offlineVerse = OfflineBibleData.getOfflineVerse(bookId: book, chapter: chapter, verse: verse) {
                return offlineVerse
            }
            throw error
        }
    }
    
    public func getChapter(book: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        // Try offline first for plane mode
        if let offlineChapter = OfflineBibleData.getOfflineChapter(bookId: book, chapter: chapter) {
            return offlineChapter
        }
        
        // Try online API
        do {
            let endpoint = "/\(book)+\(chapter)"
            let response: BibleAPIResponse = try await fetchWithRetry(endpoint: endpoint)
            
            let verses = response.verses.map { verseData in
                BibleVerse(
                    id: "\(book)-\(chapter)-\(verseData.verse)-\(translation.abbreviation)",
                    bookName: verseData.bookName,
                    bookId: book,
                    chapter: chapter,
                    verse: verseData.verse,
                    text: verseData.text.trimmingCharacters(in: .whitespacesAndNewlines),
                    translation: translation.abbreviation
                )
            }
            
            return BibleChapter(
                bookName: response.verses.first?.bookName ?? book.capitalized,
                bookId: book,
                chapterNumber: chapter,
                verses: verses
            )
        } catch {
            // Fallback to offline data if available
            if let offlineChapter = OfflineBibleData.getOfflineChapter(bookId: book, chapter: chapter) {
                return offlineChapter
            }
            throw error
        }
    }
    
    public func getDailyVerse(translation: BibleTranslation) async throws -> BibleVerse {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        // Always use offline data for daily verse to ensure consistency
        return OfflineBibleData.getDailyOfflineVerse()
    }
    
    public func getTranslations() async throws -> [BibleTranslation] {
        return BibleTranslation.defaultTranslations
    }
    
    public func getAvailableTranslations() async throws -> [BibleTranslation] {
        return BibleTranslation.defaultTranslations
    }
    
    public func searchVerses(query: String, translation: BibleTranslation, books: [BibleBook]? = nil) async throws -> [BibleVerse] {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        // Use offline search for plane mode
        return OfflineBibleData.searchOfflineVerses(query: query)
    }
    
    // MARK: - Private Helper Methods
    
    private func fetchWithRetry<T: Decodable>(endpoint: String, retryCount: Int = 0) async throws -> T {
        let cacheKey = "bible_api_" + endpoint.replacingOccurrences(of: "/", with: "_")
        
        // Check cache first
        if let cachedData = await cacheService.get(cacheKey, type: Data.self) {
            do {
                let decoded = try JSONDecoder().decode(T.self, from: cachedData)
                return decoded
            } catch {
                // Cache corrupted, remove and continue to fetch
                await cacheService.remove(cacheKey)
            }
        }
        
        // Build URL
        guard let url = URL(string: baseURL + endpoint) else {
            throw ServiceError.user(.invalidParameters)
        }
        
        do {
            // Fetch data
            let (data, response) = try await session.data(from: url)
            
            // Check response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServiceError.data(.invalidResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 404 {
                    throw ServiceError.data(.notFound)
                }
                throw ServiceError.network(.serverError(statusCode: httpResponse.statusCode, message: "HTTP error"))
            }
            
            // Decode response
            let decoded = try JSONDecoder().decode(T.self, from: data)
            
            // Cache successful response (1 hour for chapter data)
            let expirationDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
            await cacheService.set(cacheKey, value: data, expirationDate: expirationDate)
            
            return decoded
            
        } catch let error as DecodingError {
            print("Decoding error for endpoint \(endpoint): \(error)")
            throw ServiceError.data(.decodingError(error))
        } catch {
            // Retry logic
            if retryCount < maxRetries {
                let delay = retryDelay * Double(retryCount + 1)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await fetchWithRetry(endpoint: endpoint, retryCount: retryCount + 1)
            }
            throw ServiceError.system(.unknown(error))
        }
    }
}

// MARK: - Bible API Response Models

private struct BibleAPIResponse: Codable {
    let reference: String
    let verses: [BibleAPIVerse]
    let text: String
    let translationId: String
    let translationName: String
    
    enum CodingKeys: String, CodingKey {
        case reference, verses, text
        case translationId = "translation_id"
        case translationName = "translation_name"
    }
}

private struct BibleAPIVerse: Codable {
    let bookId: String
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case chapter, verse, text
        case bookId = "book_id"
        case bookName = "book_name"
    }
}


