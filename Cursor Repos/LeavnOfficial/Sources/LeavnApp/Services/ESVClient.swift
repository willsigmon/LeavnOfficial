import Foundation
import Dependencies

// MARK: - ESV API Client
public struct ESVClient: Sendable {
    public var getPassage: @Sendable (Book, Int, Int?) async throws -> ESVResponse
    public var search: @Sendable (String) async throws -> [SearchResult]
}

// MARK: - ESV Response
public struct ESVResponse: Equatable, Codable, Sendable {
    public let query: String
    public let text: String
    public let verseNumbers: Bool
    
    public init(query: String, text: String, verseNumbers: Bool = true) {
        self.query = query
        self.text = text
        self.verseNumbers = verseNumbers
    }
}

// MARK: - Dependency Implementation
extension ESVClient: DependencyKey {
    public static let liveValue = Self(
        getPassage: { book, chapter, verse in
            @Dependency(\.apiKeyManager) var apiKeyManager
            
            guard let apiKey = apiKeyManager.esvAPIKey else {
                throw ESVError.missingAPIKey
            }
            
            let baseURL = URL(string: "https://api.esv.org/v3/passage/text/")!
            
            var query = "\(book.name) \(chapter)"
            if let verse = verse {
                query += ":\(verse)"
            }
            
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "include-passage-references", value: "false"),
                URLQueryItem(name: "include-verse-numbers", value: "true"),
                URLQueryItem(name: "include-footnotes", value: "false"),
                URLQueryItem(name: "include-headings", value: "true"),
                URLQueryItem(name: "include-short-copyright", value: "false")
            ]
            
            var request = URLRequest(url: components.url!)
            request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ESVError.invalidResponse
            }
            
            let esvResponse = try JSONDecoder().decode(ESVAPIResponse.self, from: data)
            
            return ESVResponse(
                query: query,
                text: esvResponse.passages.joined(separator: "\n\n"),
                verseNumbers: true
            )
        },
        search: { query in
            @Dependency(\.apiKeyManager) var apiKeyManager
            
            guard let apiKey = apiKeyManager.esvAPIKey else {
                throw ESVError.missingAPIKey
            }
            
            let baseURL = URL(string: "https://api.esv.org/v3/passage/search/")!
            
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page-size", value: "20")
            ]
            
            var request = URLRequest(url: components.url!)
            request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ESVError.invalidResponse
            }
            
            let searchResponse = try JSONDecoder().decode(ESVSearchResponse.self, from: data)
            
            return searchResponse.results.map { result in
                SearchResult(
                    reference: parseReference(from: result.reference),
                    text: result.content,
                    context: result.reference
                )
            }
        }
    )
    
    public static let testValue = Self(
        getPassage: { _, _, _ in
            ESVResponse(
                query: "Test",
                text: "[1] Test verse content",
                verseNumbers: true
            )
        },
        search: { _ in [] }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var esvClient: ESVClient {
        get { self[ESVClient.self] }
        set { self[ESVClient.self] = newValue }
    }
}

// MARK: - API Response Models
private struct ESVAPIResponse: Codable {
    let passages: [String]
}

private struct ESVSearchResponse: Codable {
    let results: [ESVSearchResult]
}

private struct ESVSearchResult: Codable {
    let reference: String
    let content: String
}

// MARK: - Errors
public enum ESVError: Error {
    case missingAPIKey
    case invalidResponse
    case parsingError
}

// MARK: - Helper Functions
private func parseReference(from text: String) -> BibleReference {
    // Simple reference parsing - in production this would be more robust
    // Example: "John 3:16" -> BibleReference(book: .john, chapter: 3, verse: 16)
    
    // Default fallback
    return BibleReference(book: .genesis, chapter: 1, verse: 1)
}