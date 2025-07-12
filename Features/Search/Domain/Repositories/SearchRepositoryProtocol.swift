import Foundation

public protocol SearchRepositoryProtocol {
    func search(query: SearchQuery) async throws -> [SearchResult]
    func getRecentSearches() async throws -> [String]
    func addRecentSearch(_ query: String) async throws
    func clearRecentSearches() async throws
    func getPopularSearches() async throws -> [String]
}