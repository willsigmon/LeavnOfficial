import Foundation

// MARK: - Repository Protocols

public protocol SearchRepositoryProtocol {
    func search(query: SearchQuery) async throws -> [SearchResult]
    func getRecentSearches() async throws -> [String]
    func addRecentSearch(_ query: String) async throws
    func clearRecentSearches() async throws
    func getPopularSearches() async throws -> [String]
}

// MARK: - Use Case Protocols

public protocol SearchBibleUseCaseProtocol {
    func execute(query: SearchQuery) async throws -> [SearchResult]
}

public protocol ManageRecentSearchesUseCaseProtocol {
    func getRecentSearches() async throws -> [String]
    func clearRecentSearches() async throws
}

// MARK: - Data Source Protocols

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

// MARK: - Models
// Note: SearchFilter and SearchResult are defined in LeavnCore/SearchModels.swift
// SearchQuery is defined here for protocol usage

public struct SearchQuery: Equatable {
    public let text: String
    public let filter: SearchFilter
    public let translation: String?
    
    public init(text: String, filter: SearchFilter = .all, translation: String? = nil) {
        self.text = text
        self.filter = filter
        self.translation = translation
    }
}