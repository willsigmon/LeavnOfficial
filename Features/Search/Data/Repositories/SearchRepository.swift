import Foundation

public final class SearchRepository: SearchRepositoryProtocol {
    private let remoteDataSource: SearchRemoteDataSourceProtocol
    private let localDataSource: SearchLocalDataSourceProtocol
    private let cacheService: CacheServiceProtocol?
    
    public init(
        remoteDataSource: SearchRemoteDataSourceProtocol,
        localDataSource: SearchLocalDataSourceProtocol,
        cacheService: CacheServiceProtocol? = nil
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.cacheService = cacheService
    }
    
    public func search(query: SearchQuery) async throws -> [SearchResult] {
        // Check cache first
        let cacheKey = "\(query.text)_\(query.filter.rawValue)_\(query.translation ?? "default")"
        if let cachedResults = try? await cacheService?.get(cacheKey, type: [SearchResult].self) {
            return cachedResults
        }
        
        do {
            // Try remote search
            let results = try await remoteDataSource.search(query: query)
            
            // Cache results
            try? await cacheService?.set(cacheKey, value: results, ttl: 300) // 5 minutes
            
            return results
        } catch {
            // Fallback to local search
            return try await localDataSource.search(query: query)
        }
    }
    
    public func getRecentSearches() async throws -> [String] {
        try await localDataSource.getRecentSearches()
    }
    
    public func addRecentSearch(_ query: String) async throws {
        try await localDataSource.addRecentSearch(query)
    }
    
    public func clearRecentSearches() async throws {
        try await localDataSource.clearRecentSearches()
    }
    
    public func getPopularSearches() async throws -> [String] {
        do {
            return try await remoteDataSource.getPopularSearches()
        } catch {
            // Return default popular searches
            return ["Love", "Faith", "Peace", "Hope", "Grace", "Prayer"]
        }
    }
}