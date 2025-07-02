import Foundation
import LeavnCore

// MARK: - Production Bible Service Implementation

public actor ProductionBibleService: BibleServiceProtocol {
    
    // MARK: - Properties
    
    private let baseURL = "https://getbible.net/v2"
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
            // Allow initialization to succeed even if translations fail to load
            // We'll use default translations
            cachedTranslations = BibleTranslation.defaultTranslations
            isInitialized = true
            print("📚 ProductionBibleService initialized with default translations due to error: \(error)")
        }
    }
    
    // MARK: - BibleServiceProtocol Implementation
    
    public func getBooks() async throws -> [BibleBook] {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        return BibleBook.allCases
    }
    
    public func getVerse(book: String, chapter: Int, verse: Int, translation: BibleTranslation) async throws -> BibleVerse {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Convert book string to BibleBook
        guard let bibleBook = BibleBook.allCases.first(where: { $0.id == book || $0.name == book }) else {
            throw ServiceError.notFound
        }
        
        let translationCode = translation.getBibleCode
        let bookNumber = bibleBook.bookNumber
        let endpoint = "/\(translationCode)/\(bookNumber)/\(chapter)/\(verse).json"
        
        let chapterData: GetBibleChapter = try await fetchWithRetry(endpoint: endpoint)
        
        // Find the specific verse (verses are in dictionary format)
        guard let verseData = chapterData.chapter[String(verse)] else {
            throw ServiceError.notFound
        }
        
        return BibleVerse(
            id: "\(bibleBook.id)-\(chapter)-\(verse)-\(translation.abbreviation)",
            bookName: bibleBook.name,
            bookId: bibleBook.id,
            chapter: chapter,
            verse: verse,
            text: cleanVerseText(verseData.verse),
            translation: translation.abbreviation,
            isRedLetter: false // GetBible doesn't provide red letter markup
        )
    }
    
    public func getChapter(book: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Convert book string to BibleBook
        guard let bibleBook = BibleBook.allCases.first(where: { $0.id == book || $0.name == book }) else {
            throw ServiceError.notFound
        }
        
        let translationCode = translation.getBibleCode
        let bookNumber = bibleBook.bookNumber
        let endpoint = "/\(translationCode)/\(bookNumber)/\(chapter).json"
        
        let chapterData: GetBibleChapter = try await fetchWithRetry(endpoint: endpoint)
        
        // Convert dictionary to sorted array
        let sortedVerses = chapterData.chapter
            .sorted { Int($0.key) ?? 0 < Int($1.key) ?? 0 }
            .map { (key, verseData) in
                BibleVerse(
                    id: "\(bibleBook.id)-\(chapter)-\(verseData.verse_nr)-\(translation.abbreviation)",
                    bookName: bibleBook.name,
                    bookId: bibleBook.id,
                    chapter: chapter,
                    verse: verseData.verse_nr,
                    text: cleanVerseText(verseData.verse),
                    translation: translation.abbreviation,
                    isRedLetter: false
                )
            }
        
        return BibleChapter(
            bookName: bibleBook.name,
            bookId: bibleBook.id,
            chapterNumber: chapter,
            verses: sortedVerses
        )
    }
    
    public func getDailyVerse(translation: BibleTranslation) async throws -> BibleVerse {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Use a deterministic daily verse based on the day of year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        // Popular verses for daily reading
        let dailyVerses: [(BibleBook, Int, Int)] = [
            (.psalms, 23, 1),
            (.proverbs, 3, 5),
            (.proverbs, 3, 6),
            (.isaiah, 40, 31),
            (.matthew, 6, 33),
            (.matthew, 11, 28),
            (.john, 3, 16),
            (.john, 14, 6),
            (.romans, 8, 28),
            (.romans, 12, 2),
            (.philippians, 4, 13),
            (.philippians, 4, 19),
            (.ephesians, 2, 8),
            (.ephesians, 2, 9),
            (.james, 1, 5),
            (.firstPeter, 5, 7),
            (.firstJohn, 4, 19),
            (.revelation, 3, 20),
            (.psalms, 119, 105),
            (.proverbs, 16, 3),
            (.isaiah, 41, 10),
            (.matthew, 5, 16),
            (.luke, 6, 31),
            (.john, 15, 5),
            (.romans, 10, 9),
            (.firstCorinthians, 13, 13),
            (.galatians, 5, 22),
            (.colossians, 3, 23),
            (.hebrews, 11, 1),
            (.hebrews, 13, 8),
            (.psalms, 46, 1)
        ]
        
        let index = (dayOfYear - 1) % dailyVerses.count
        let (book, chapter, verse) = dailyVerses[index]
        
        return try await getVerse(book: book.id, chapter: chapter, verse: verse, translation: translation)
    }
    
    public func getTranslations() async throws -> [BibleTranslation] {
        return try await getAvailableTranslations()
    }
    
    public func getAvailableTranslations() async throws -> [BibleTranslation] {
        // Check cache first
        let cacheKey = "available_translations"
        if let cached = await cacheService.get(cacheKey, type: [BibleTranslation].self) {
            return cached
        }
        
        let endpoint = "/translations.json"
        let translationList: GetBibleTranslationList = try await fetchWithRetry(endpoint: endpoint)
        
        // Convert GetBible translations to our format
        let translations = translationList.translations.values.compactMap { getBibleTranslation -> BibleTranslation? in
            // Map to our translation format
            return BibleTranslation(
                id: getBibleTranslation.abbreviation.lowercased(),
                name: getBibleTranslation.translation,
                abbreviation: getBibleTranslation.abbreviation,
                language: getBibleTranslation.language,
                languageCode: getBibleTranslation.lang
            )
        }
        
        // Cache for 24 hours
        let expirationDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
        await cacheService.set(cacheKey, value: translations, expirationDate: expirationDate)
        
        return translations
    }
    
    public func searchVerses(query: String, translation: BibleTranslation, books: [BibleBook]? = nil) async throws -> [BibleVerse] {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // GetBible doesn't have a direct search API, so we'll implement a basic search
        // This is a simplified implementation - for production, consider using a dedicated search service
        
        var results: [BibleVerse] = []
        let searchBooks = books ?? Array(BibleBook.allCases.prefix(10)) // Limit for performance
        
        let searchTasks = searchBooks.map { book in
            Task {
                await searchInBook(book: book, query: query, translation: translation)
            }
        }
        
        for task in searchTasks {
            let bookResults = await task.value
            results.append(contentsOf: bookResults)
        }
        
        return results.sorted { $0.bookName < $1.bookName || ($0.bookName == $1.bookName && $0.chapter < $1.chapter) }
    }
    
    // MARK: - Private Helper Methods
    
    private func searchInBook(book: BibleBook, query: String, translation: BibleTranslation) async -> [BibleVerse] {
        var results: [BibleVerse] = []
        
        // Search in first few chapters of each book (for performance)
        let maxChapters = min(book.chapterCount, 5)
        
        for chapterNum in 1...maxChapters {
            do {
                let chapter = try await getChapter(book: book.id, chapter: chapterNum, translation: translation)
                let matchingVerses = chapter.verses.filter { verse in
                    verse.text.localizedCaseInsensitiveContains(query)
                }
                results.append(contentsOf: matchingVerses)
                
                // Limit results per book
                if results.count >= 20 {
                    break
                }
            } catch {
                // Skip chapters that fail
                continue
            }
        }
        
        return results
    }
    
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
            throw ServiceError.networkError("Invalid URL")
        }
        
        do {
            // Fetch data
            let (data, response) = try await session.data(from: url)
            
            // Check response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServiceError.networkError("Invalid response")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 404 {
                    throw ServiceError.notFound
                }
                if httpResponse.statusCode == 429 {
                    throw ServiceError.rateLimited
                }
                throw ServiceError.serverError(statusCode: httpResponse.statusCode, message: "HTTP error")
            }
            
            // Check if response is HTML (API down)
            if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
               contentType.contains("text/html") {
                throw ServiceError.networkError("API returned HTML instead of JSON - service may be down")
            }
            
            // Decode response
            let decoded = try JSONDecoder().decode(T.self, from: data)
            
            // Cache successful response (1 hour for chapter data, 24 hours for static data)
            let expirationHours = endpoint.contains("translations") ? 24 : 1
            let expirationDate = Calendar.current.date(byAdding: .hour, value: expirationHours, to: Date())
            await cacheService.set(cacheKey, value: data, expirationDate: expirationDate)
            
            return decoded
            
        } catch let error as ServiceError {
            throw error
        } catch let error as DecodingError {
            print("Decoding error for endpoint \(endpoint): \(error)")
            throw ServiceError.dataCorrupted
        } catch {
            // Retry logic
            if retryCount < maxRetries {
                let delay = retryDelay * Double(retryCount + 1)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await fetchWithRetry(endpoint: endpoint, retryCount: retryCount + 1)
            }
            
            throw ServiceError.networkError(error.localizedDescription)
        }
    }
    

    
    private func cleanVerseText(_ text: String) -> String {
        // Remove verse numbers from the beginning of the text
        let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Remove leading numbers and dots/colons
        let pattern = "^\\d+[:.\\s]*"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(location: 0, length: trimmed.utf16.count)
            let cleaned = regex.stringByReplacingMatches(in: trimmed, range: range, withTemplate: "")
            return cleaned.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        return trimmed
    }
}


