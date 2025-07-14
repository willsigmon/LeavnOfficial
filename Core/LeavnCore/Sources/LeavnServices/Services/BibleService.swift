import Foundation
import CoreData

// MARK: - Bible Service Protocol
public protocol BibleService {
    func fetchVerse(reference: String, translation: String?) async throws -> BibleVerse
    func fetchChapter(book: String, chapter: Int, translation: String?) async throws -> BibleChapter
    func fetchTranslations() async throws -> [BibleTranslation]
    func search(query: String, translation: String?) async throws -> [BibleSearchResult]
    func getBooks(includeApocrypha: Bool) async throws -> [BibleBook]
    func fetchPassage(reference: String, translation: String?) async throws -> BiblePassage
}

// MARK: - Bible Models
public struct BibleVerse: Codable, Identifiable {
    public let id: String
    public let reference: String
    public let text: String
    public let translation: String
    public let book: String
    public let chapter: Int
    public let verse: Int
    
    public init(
        id: String,
        reference: String,
        text: String,
        translation: String,
        book: String,
        chapter: Int,
        verse: Int
    ) {
        self.id = id
        self.reference = reference
        self.text = text
        self.translation = translation
        self.book = book
        self.chapter = chapter
        self.verse = verse
    }
}

public struct BibleChapter: Codable {
    public let book: String
    public let chapter: Int
    public let verses: [BibleVerse]
    public let translation: String
    
    public init(book: String, chapter: Int, verses: [BibleVerse], translation: String) {
        self.book = book
        self.chapter = chapter
        self.verses = verses
        self.translation = translation
    }
}

public struct BibleTranslation: Codable, Identifiable {
    public let id: String
    public let name: String
    public let abbreviation: String
    public let language: String
    public let description: String?
    public let includesApocrypha: Bool
    public let apiSource: APISource
    
    public enum APISource: String, Codable {
        case esv = "esv"
        case bibleCom = "bible_com"
        case local = "local"
    }
    
    public init(
        id: String,
        name: String,
        abbreviation: String,
        language: String,
        description: String? = nil,
        includesApocrypha: Bool = false,
        apiSource: APISource = .local
    ) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.language = language
        self.description = description
        self.includesApocrypha = includesApocrypha
        self.apiSource = apiSource
    }
}

public struct BibleBook: Codable, Identifiable {
    public let id: String
    public let name: String
    public let abbreviation: String
    public let testament: Testament
    public let bookNumber: Int
    public let chapterCount: Int
    public let isApocrypha: Bool
    public let category: BookCategory
    
    public enum Testament: String, Codable {
        case oldTestament = "old"
        case newTestament = "new"
        case apocrypha = "apocrypha"
    }
    
    public enum BookCategory: String, Codable {
        case law, history, wisdom, prophets, gospels, epistles, apocalyptic
        case deuterocanonical // For Apocrypha
    }
    
    public init(
        id: String,
        name: String,
        abbreviation: String,
        testament: Testament,
        bookNumber: Int,
        chapterCount: Int,
        isApocrypha: Bool = false,
        category: BookCategory
    ) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.testament = testament
        self.bookNumber = bookNumber
        self.chapterCount = chapterCount
        self.isApocrypha = isApocrypha
        self.category = category
    }
}

public struct BiblePassage: Codable {
    public let reference: String
    public let canonical: String
    public let parsed: [[Int]]
    public let passage_meta: [PassageMeta]
    public let passages: [String]
    
    public struct PassageMeta: Codable {
        public let canonical: String
        public let chapter_start: [Int]
        public let chapter_end: [Int]
        public let prev_verse: Int?
        public let next_verse: Int?
        public let prev_chapter: [Int]?
        public let next_chapter: [Int]?
    }
    
    public init(
        reference: String,
        canonical: String,
        parsed: [[Int]],
        passage_meta: [PassageMeta],
        passages: [String]
    ) {
        self.reference = reference
        self.canonical = canonical
        self.parsed = parsed
        self.passage_meta = passage_meta
        self.passages = passages
    }
}

public struct BibleSearchResult: Codable, Identifiable {
    public let id: String
    public let verse: BibleVerse
    public let highlights: [Range<String.Index>]
    public let relevanceScore: Double
    
    public init(
        id: String,
        verse: BibleVerse,
        highlights: [Range<String.Index>] = [],
        relevanceScore: Double = 1.0
    ) {
        self.id = id
        self.verse = verse
        self.highlights = highlights
        self.relevanceScore = relevanceScore
    }
}

// MARK: - Bible Service Implementation
public final class DefaultBibleService: BibleService {
    private let networkService: NetworkService
    private let esvClient: ESVAPIClient
    private let bibleComClient: BibleComAPIClient
    private let cacheManager: BibleCacheManager
    private let bookCatalog: BibleBookCatalog
    
    private let esvAPIKey: String
    private let bibleComAPIKey: String
    
    public init(
        networkService: NetworkService,
        esvAPIKey: String = "",
        bibleComAPIKey: String = "",
        cacheManager: BibleCacheManager
    ) {
        self.networkService = networkService
        self.esvAPIKey = esvAPIKey
        self.bibleComAPIKey = bibleComAPIKey
        self.cacheManager = cacheManager
        self.bookCatalog = BibleBookCatalog()
        
        self.esvClient = ESVAPIClient(
            networkService: networkService,
            apiKey: esvAPIKey
        )
        self.bibleComClient = BibleComAPIClient(
            networkService: networkService,
            apiKey: bibleComAPIKey
        )
    }
    
    public func fetchVerse(reference: String, translation: String? = nil) async throws -> BibleVerse {
        let translation = translation ?? "ESV"
        
        // Check cache first
        if let cachedVerse = try await cacheManager.getCachedVerse(reference: reference, translation: translation) {
            return cachedVerse
        }
        
        // Fetch from appropriate API
        let verse: BibleVerse
        if translation.uppercased() == "ESV" {
            verse = try await esvClient.getVerse(reference: reference)
        } else {
            verse = try await bibleComClient.getVerse(reference: reference, translation: translation)
        }
        
        // Cache the result
        try await cacheManager.cacheVerse(verse)
        return verse
    }
    
    public func fetchChapter(book: String, chapter: Int, translation: String? = nil) async throws -> BibleChapter {
        let translation = translation ?? "ESV"
        
        // Check cache first
        if let cachedChapter = try await cacheManager.getCachedChapter(book: book, chapter: chapter, translation: translation) {
            return cachedChapter
        }
        
        // Fetch from appropriate API
        let chapter: BibleChapter
        if translation.uppercased() == "ESV" {
            chapter = try await esvClient.getChapter(book: book, chapter: chapter)
        } else {
            chapter = try await bibleComClient.getChapter(book: book, chapter: chapter, translation: translation)
        }
        
        // Cache the result
        try await cacheManager.cacheChapter(chapter)
        return chapter
    }
    
    public func fetchPassage(reference: String, translation: String? = nil) async throws -> BiblePassage {
        let translation = translation ?? "ESV"
        
        if translation.uppercased() == "ESV" {
            return try await esvClient.getPassage(reference: reference)
        } else {
            return try await bibleComClient.getPassage(reference: reference, translation: translation)
        }
    }
    
    public func fetchTranslations() async throws -> [BibleTranslation] {
        return bookCatalog.getSupportedTranslations()
    }
    
    public func getBooks(includeApocrypha: Bool = false) async throws -> [BibleBook] {
        return bookCatalog.getBooks(includeApocrypha: includeApocrypha)
    }
    
    public func search(query: String, translation: String? = nil) async throws -> [BibleSearchResult] {
        let translation = translation ?? "ESV"
        
        if translation.uppercased() == "ESV" {
            return try await esvClient.search(query: query)
        } else {
            return try await bibleComClient.search(query: query, translation: translation)
        }
    }
}

// MARK: - ESV API Client
final class ESVAPIClient {
    private let networkService: NetworkService
    private let apiKey: String
    private let baseURL = "https://api.esv.org"
    
    init(networkService: NetworkService, apiKey: String) {
        self.networkService = networkService
        self.apiKey = apiKey
    }
    
    func getVerse(reference: String) async throws -> BibleVerse {
        let passage = try await getPassage(reference: reference)
        guard let firstPassage = passage.passages.first else {
            throw LeavnError.notFound
        }
        
        let components = reference.split(separator: ":")
        guard components.count >= 2,
              let chapterVerse = components.last?.split(separator: ":"),
              chapterVerse.count >= 2,
              let chapter = Int(chapterVerse[0]),
              let verse = Int(chapterVerse[1]) else {
            throw LeavnError.invalidInput("Invalid verse reference format")
        }
        
        let book = String(components.dropLast().joined(separator: " "))
        
        return BibleVerse(
            id: "\(reference)-ESV",
            reference: reference,
            text: firstPassage,
            translation: "ESV",
            book: book,
            chapter: chapter,
            verse: verse
        )
    }
    
    func getChapter(book: String, chapter: Int) async throws -> BibleChapter {
        let reference = "\(book) \(chapter)"
        let passage = try await getPassage(reference: reference)
        
        // Parse verses from the passage
        let verses = parseVersesFromPassage(passage.passages.first ?? "", book: book, chapter: chapter)
        
        return BibleChapter(
            book: book,
            chapter: chapter,
            verses: verses,
            translation: "ESV"
        )
    }
    
    func getPassage(reference: String) async throws -> BiblePassage {
        let customNetworkService = ESVNetworkService(apiKey: apiKey)
        
        let endpoint = Endpoint(
            path: "/v3/passage/text/",
            parameters: [
                "q": reference,
                "include-headings": "false",
                "include-footnotes": "false",
                "include-verse-numbers": "true",
                "include-short-copyright": "false",
                "include-passage-references": "false"
            ]
        )
        
        let response: ESVPassageResponse = try await customNetworkService.request(endpoint)
        
        return BiblePassage(
            reference: response.query,
            canonical: response.canonical,
            parsed: response.parsed,
            passage_meta: response.passage_meta.map { meta in
                BiblePassage.PassageMeta(
                    canonical: meta.canonical,
                    chapter_start: meta.chapter_start,
                    chapter_end: meta.chapter_end,
                    prev_verse: meta.prev_verse,
                    next_verse: meta.next_verse,
                    prev_chapter: meta.prev_chapter,
                    next_chapter: meta.next_chapter
                )
            },
            passages: response.passages
        )
    }
    
    func search(query: String) async throws -> [BibleSearchResult] {
        let customNetworkService = ESVNetworkService(apiKey: apiKey)
        
        let endpoint = Endpoint(
            path: "/v3/passage/search/",
            parameters: [
                "q": query,
                "page-size": "20"
            ]
        )
        
        let response: ESVSearchResponse = try await customNetworkService.request(endpoint)
        
        return response.results.map { result in
            let verse = BibleVerse(
                id: "\(result.reference)-ESV",
                reference: result.reference,
                text: result.content,
                translation: "ESV",
                book: extractBook(from: result.reference),
                chapter: extractChapter(from: result.reference),
                verse: extractVerse(from: result.reference)
            )
            
            return BibleSearchResult(
                id: "search-\(result.reference)-ESV",
                verse: verse,
                highlights: [],
                relevanceScore: 1.0
            )
        }
    }
    
    private func parseVersesFromPassage(_ passage: String, book: String, chapter: Int) -> [BibleVerse] {
        // Simple verse parsing - in production, use more sophisticated parsing
        let lines = passage.components(separatedBy: .newlines)
        var verses: [BibleVerse] = []
        
        for (index, line) in lines.enumerated() {
            let verseNumber = index + 1
            let cleanedText = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleanedText.isEmpty {
                let verse = BibleVerse(
                    id: "\(book)-\(chapter)-\(verseNumber)-ESV",
                    reference: "\(book) \(chapter):\(verseNumber)",
                    text: cleanedText,
                    translation: "ESV",
                    book: book,
                    chapter: chapter,
                    verse: verseNumber
                )
                verses.append(verse)
            }
        }
        
        return verses
    }
    
    private func extractBook(from reference: String) -> String {
        let components = reference.split(separator: " ")
        return String(components.dropLast().joined(separator: " "))
    }
    
    private func extractChapter(from reference: String) -> Int {
        let components = reference.split(separator: ":")
        if components.count >= 2,
           let chapterVerse = components.last?.split(separator: ":"),
           let chapter = Int(chapterVerse[0]) {
            return chapter
        }
        return 1
    }
    
    private func extractVerse(from reference: String) -> Int {
        let components = reference.split(separator: ":")
        if let verseString = components.last,
           let verse = Int(verseString) {
            return verse
        }
        return 1
    }
}

// MARK: - Bible.com API Client
final class BibleComAPIClient {
    private let networkService: NetworkService
    private let apiKey: String
    private let baseURL = "https://api.scripture.api.bible"
    
    init(networkService: NetworkService, apiKey: String) {
        self.networkService = networkService
        self.apiKey = apiKey
    }
    
    func getVerse(reference: String, translation: String) async throws -> BibleVerse {
        // Implementation for Bible.com API
        // This would require specific Bible ID mapping
        throw LeavnError.notImplemented("Bible.com API implementation pending")
    }
    
    func getChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter {
        // Implementation for Bible.com API
        throw LeavnError.notImplemented("Bible.com API implementation pending")
    }
    
    func getPassage(reference: String, translation: String) async throws -> BiblePassage {
        // Implementation for Bible.com API
        throw LeavnError.notImplemented("Bible.com API implementation pending")
    }
    
    func search(query: String, translation: String) async throws -> [BibleSearchResult] {
        // Implementation for Bible.com API
        throw LeavnError.notImplemented("Bible.com API search pending")
    }
}

// MARK: - ESV Network Service
final class ESVNetworkService {
    private let apiKey: String
    private let session: URLSession
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.session = URLSession.shared
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let url = URL(string: "https://api.esv.org")!
            .appendingPathComponent(endpoint.path)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let parameters = endpoint.parameters {
            components.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        var request = URLRequest(url: components.url!)
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LeavnError.networkError(underlying: nil)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - ESV API Response Models
struct ESVPassageResponse: Codable {
    let query: String
    let canonical: String
    let parsed: [[Int]]
    let passage_meta: [ESVPassageMeta]
    let passages: [String]
}

struct ESVPassageMeta: Codable {
    let canonical: String
    let chapter_start: [Int]
    let chapter_end: [Int]
    let prev_verse: Int?
    let next_verse: Int?
    let prev_chapter: [Int]?
    let next_chapter: [Int]?
}

struct ESVSearchResponse: Codable {
    let page: Int
    let total_results: Int
    let results: [ESVSearchResult]
    let total_pages: Int
}

struct ESVSearchResult: Codable {
    let reference: String
    let content: String
}