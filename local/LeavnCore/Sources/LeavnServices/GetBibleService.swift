import Foundation
import LeavnCore

// MARK: - GetBible API Service

public actor GetBibleService: BibleServiceProtocol {
    
    // MARK: - Properties
    
    private let baseURL = "https://bible-api.com"
    private let session: URLSession
    private let cacheManager: any CacheServiceProtocol
    private var isInitialized = false
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0

    // MARK: - Initialization
    
    public init(cacheManager: any CacheServiceProtocol) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: configuration)
        self.cacheManager = cacheManager
    }
    
    public func initialize() async {
        isInitialized = true
        print("📚 GetBibleService initialized")
    }
    
    // MARK: - BibleServiceProtocol Implementation

    public func getBooks() async throws -> [BibleBook] {
        guard isInitialized else { throw ServiceError.system(.notInitialized) }
        return BibleBook.allCases
    }

    public func getVerse(book: String, chapter: Int, verse: Int, translation: BibleTranslation) async throws -> BibleVerse {
        guard isInitialized else { throw ServiceError.system(.notInitialized) }
        guard let bibleBook = BibleBook(from: book) else { throw ServiceError.user(.invalidInput(field: "book")) }
        
        let translationCode = translation.getBibleCode
        let bookNumber = bibleBook.bookNumber
        let endpoint = "/\(translationCode)/\(bookNumber)/\(chapter)/\(verse).json"
        
        let chapterData: GetBibleChapter = try await fetchWithRetry(endpoint: endpoint)
        
        guard let verseData = chapterData.chapter[String(verse)] else {
            throw ServiceError.data(.notFound)
        }
        
        return BibleVerse(
            id: "\(bibleBook.id)-\(chapter)-\(verse)-\(translation.abbreviation)",
            bookName: bibleBook.name,
            bookId: bibleBook.id,
            chapter: chapter,
            verse: verse,
            text: cleanVerseText(verseData.verse),
            translation: translation.abbreviation
        )
    }
    
    public func getChapter(book: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter {
        guard isInitialized else { throw ServiceError.system(.notInitialized) }
        guard let bibleBook = BibleBook(from: book) else { throw ServiceError.user(.invalidInput(field: "book")) }

        let translationCode = translation.getBibleCode
        let bookNumber = bibleBook.bookNumber
        let endpoint = "/\(translationCode)/\(bookNumber)/\(chapter).json"
        
        let chapterData: GetBibleChapter = try await fetchWithRetry(endpoint: endpoint)
        
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
                    translation: translation.abbreviation
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
        guard isInitialized else { throw ServiceError.system(.notInitialized) }
        
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        let dailyVerses: [(book: BibleBook, chapter: Int, verse: Int)] = [
            (.john, 3, 16), (.romans, 8, 28), (.philippians, 4, 13), (.jeremiah, 29, 11), (.proverbs, 3, 5),
            (.isaiah, 40, 31), (.psalms, 23, 1), (.isaiah, 41, 10), (.matthew, 6, 33), (.joshua, 1, 9),
            (.romans, 12, 2), (.galatians, 5, 22), (.colossians, 3, 23), (.hebrews, 11, 1), (.hebrews, 13, 8), (.psalms, 46, 1)
        ]
        
        let index = (dayOfYear - 1) % dailyVerses.count
        let (book, chapter, verse) = dailyVerses[index]
        
        return try await getVerse(book: book.id, chapter: chapter, verse: verse, translation: translation)
    }
    
    public func getTranslations() async throws -> [BibleTranslation] {
        guard isInitialized else { throw ServiceError.system(.notInitialized) }
        return [
            BibleTranslation(abbreviation: "KJV", name: "King James Version", language: "English", languageCode: "en"),
            BibleTranslation(abbreviation: "ASV", name: "American Standard Version", language: "English", languageCode: "en"),
            BibleTranslation(abbreviation: "BBE", name: "Bible in Basic English", language: "English", languageCode: "en"),
            BibleTranslation(abbreviation: "DARBY", name: "Darby", language: "English", languageCode: "en"),
            BibleTranslation(abbreviation: "WEB", name: "World English Bible", language: "English", languageCode: "en"),
            BibleTranslation(abbreviation: "YLT", name: "Young's Literal Translation", language: "English", languageCode: "en")
        ]
    }
    
    public func searchVerses(query: String, translation: BibleTranslation, books: [BibleBook]?) async throws -> [BibleVerse] {
        guard isInitialized else { throw ServiceError.system(.notInitialized) }
        
        var results: [BibleVerse] = []
        let searchBooks = books ?? BibleBook.allCases
        
        await withTaskGroup(of: [BibleVerse].self) { group in
            for book in searchBooks {
                group.addTask {
                    return await self.searchInBook(book: book, query: query, translation: translation)
                }
            }
            
            for await bookResults in group {
                results.append(contentsOf: bookResults)
            }
        }
        
        return results.sorted { $0.bookName < $1.bookName || ($0.bookName == $1.bookName && $0.chapter < $1.chapter) }
    }
    
    // MARK: - Private Methods
    
    private func searchInBook(book: BibleBook, query: String, translation: BibleTranslation) async -> [BibleVerse] {
        var results: [BibleVerse] = []
        let chaptersToSearch = min(book.chapterCount, 5)
        
        for chapter in 1...chaptersToSearch {
            do {
                let chapterData = try await getChapter(book: book.id, chapter: chapter, translation: translation)
                let matchingVerses = chapterData.verses.filter { $0.text.localizedCaseInsensitiveContains(query) }
                results.append(contentsOf: matchingVerses)
                
                if results.count >= 20 { break }
            } catch _ {
                continue
            }
        }
        return results
    }

    private func fetchWithRetry<T: Codable & Sendable>(endpoint: String, retryCount: Int = 0) async throws -> T {
        let cacheKey = "cache_" + endpoint.replacingOccurrences(of: "/", with: "_")
        
        if let cachedValue = await cacheManager.get(cacheKey, type: T.self) {
            return cachedValue
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw ServiceError.user(.invalidParameters)
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { throw ServiceError.data(.invalidResponse) }
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 404 { throw ServiceError.data(.notFound) }
                throw ServiceError.network(.serverError(statusCode: httpResponse.statusCode, message: "Server error"))
            }
            
            if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"), contentType.contains("text/html") {
                throw ServiceError.data(.invalidResponse)
            }
            
            let decoded = try JSONDecoder().decode(T.self, from: data)
            await cacheManager.set(cacheKey, value: decoded, expirationDate: Date().addingTimeInterval(3600))
            return decoded
            
        } catch let error as ServiceError { throw error
        } catch let error as DecodingError { throw ServiceError.data(.decodingError(error))
        } catch {
            if retryCount < maxRetries {
                try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(retryCount + 1) * 1_000_000_000))
                return try await fetchWithRetry(endpoint: endpoint, retryCount: retryCount + 1)
            }
            throw ServiceError.system(.unknown(error))
        }
    }
    
    private func cleanVerseText(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = "^\\d+[:.\\s]*"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(location: 0, length: trimmed.utf16.count)
            return regex.stringByReplacingMatches(in: trimmed, range: range, withTemplate: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return trimmed
    }
}
