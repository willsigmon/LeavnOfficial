import Foundation

// MARK: - Concrete Bible Service Implementation

public actor BibleServiceImpl: BibleServiceProtocol {
    private let apiConfiguration: APIConfiguration
    private let cache = Cache<String, CacheEntry<ESVResponse>>()
    private let session: URLSession
    
    public init(
        apiConfiguration: APIConfiguration,
        session: URLSession = .shared
    ) {
        self.apiConfiguration = apiConfiguration
        self.session = session
    }
    
    public func fetchPassage(_ request: ESVRequest) async throws -> ESVResponse {
        // Check cache first
        let cacheKey = "passage:\(request.query)"
        if let cached = cache[cacheKey], !cached.isExpired {
            return cached.value
        }
        
        guard let apiKey = apiConfiguration.esvAPIKey else {
            throw AppError.apiKeyMissing("ESV")
        }
        
        let url = URL(string: "https://api.esv.org/v3/passage/text/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: request.query),
            URLQueryItem(name: "include-passage-references", value: String(request.includePassageReferences)),
            URLQueryItem(name: "include-verse-numbers", value: String(request.includeVerseNumbers)),
            URLQueryItem(name: "include-footnotes", value: String(request.includeFootnotes)),
            URLQueryItem(name: "include-headings", value: String(request.includeHeadings))
        ]
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidURL
        }
        
        switch httpResponse.statusCode {
        case 200:
            let esvResponse = try JSONDecoder().decode(ESVResponse.self, from: data)
            cache[cacheKey] = CacheEntry(value: esvResponse, ttl: 3600)
            return esvResponse
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.serverError(httpResponse.statusCode, nil)
        }
    }
    
    public func searchBible(query: String, translation: String) async throws -> [SearchResult] {
        let request = ESVRequest(query: query)
        let response = try await fetchPassage(request)
        
        return response.passages.enumerated().compactMap { index, passage in
            guard let meta = response.passageMeta[safe: index] else { return nil }
            
            let components = meta.canonical.components(separatedBy: " ")
            guard components.count >= 2 else { return nil }
            
            let bookName = components.dropLast().joined(separator: " ")
            let chapterVerse = components.last!.components(separatedBy: ":")
            guard chapterVerse.count == 2,
                  let chapter = Int(chapterVerse[0]),
                  let verse = Int(chapterVerse[1].components(separatedBy: "-")[0]) else {
                return nil
            }
            
            return SearchResult(
                book: bookName,
                chapter: chapter,
                verse: verse,
                text: passage,
                context: passage
            )
        }
    }
    
    public func getCrossReferences(for verse: Verse) async throws -> [CrossReference] {
        // In a real implementation, this would call a cross-reference API
        // For now, return empty array
        return []
    }
}

// MARK: - Simple Cache Implementation

private class Cache<Key: Hashable, Value> {
    private var storage: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.leavn.cache", attributes: .concurrent)
    
    subscript(key: Key) -> Value? {
        get {
            queue.sync { storage[key] }
        }
        set {
            queue.async(flags: .barrier) {
                self.storage[key] = newValue
            }
        }
    }
    
    func removeAll() {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }
}

// MARK: - Helper Extensions

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}