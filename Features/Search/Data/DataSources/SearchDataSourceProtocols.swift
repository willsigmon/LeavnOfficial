import Foundation
import LeavnCore

public protocol SearchRemoteDataSourceProtocol {
    func search(query: SearchQuery) async throws -> [SearchResult]
    func getPopularSearches() async throws -> [String]
}

public protocol SearchLocalDataSourceProtocol {
    func search(query: SearchQuery) async throws -> [SearchResult]
    func getRecentSearches() async throws -> [String]
    func addRecentSearch(_ query: String) async throws
    func clearRecentSearches() async throws
}

// Note: CacheServiceProtocol is defined in LeavnCore/ServiceProtocols.swift