import Foundation
import LeavnCore
import NetworkingKit
import PersistenceKit

public final class DefaultLifeSituationRepository: LifeSituationRepository {
    private let networkService: NetworkService
    private let localStorage: Storage
    private let cacheStorage: Storage
    
    private let recentlyViewedKey = "recently_viewed_situations"
    private let favoritesKey = "favorite_situations"
    private let cacheKey = "life_situations_cache"
    
    public init(
        networkService: NetworkService,
        localStorage: Storage,
        cacheStorage: Storage
    ) {
        self.networkService = networkService
        self.localStorage = localStorage
        self.cacheStorage = cacheStorage
    }
    
    public func getLifeSituations() async throws -> [LifeSituation] {
        // Try cache first
        if let cached = try await cacheStorage.load([LifeSituation].self, forKey: cacheKey) {
            return cached
        }
        
        // Fetch from network
        let endpoint = Endpoint(path: "/life-situations")
        let response: APIResponse<[LifeSituation]> = try await networkService.request(endpoint)
        
        // Cache the result
        try await cacheStorage.save(response.data, forKey: cacheKey)
        
        return response.data
    }
    
    public func getLifeSituation(by id: String) async throws -> LifeSituation? {
        let situations = try await getLifeSituations()
        return situations.first { $0.id == id }
    }
    
    public func searchLifeSituations(query: String) async throws -> [LifeSituation] {
        let endpoint = Endpoint(
            path: "/life-situations/search",
            parameters: ["q": query]
        )
        let response: APIResponse<[LifeSituation]> = try await networkService.request(endpoint)
        return response.data
    }
    
    public func getRecentlyViewed() async throws -> [LifeSituation] {
        let viewedIds = try await localStorage.load([String].self, forKey: recentlyViewedKey) ?? []
        let allSituations = try await getLifeSituations()
        
        return viewedIds.compactMap { id in
            allSituations.first { $0.id == id }
        }
    }
    
    public func markAsViewed(_ situation: LifeSituation) async throws {
        var viewedIds = try await localStorage.load([String].self, forKey: recentlyViewedKey) ?? []
        
        // Remove if already exists to move to front
        viewedIds.removeAll { $0 == situation.id }
        viewedIds.insert(situation.id, at: 0)
        
        // Keep only last 10
        if viewedIds.count > 10 {
            viewedIds = Array(viewedIds.prefix(10))
        }
        
        try await localStorage.save(viewedIds, forKey: recentlyViewedKey)
    }
    
    public func getFavorites() async throws -> [LifeSituation] {
        let favoriteIds = try await localStorage.load([String].self, forKey: favoritesKey) ?? []
        let allSituations = try await getLifeSituations()
        
        return favoriteIds.compactMap { id in
            allSituations.first { $0.id == id }
        }
    }
    
    public func toggleFavorite(_ situation: LifeSituation) async throws {
        var favoriteIds = try await localStorage.load([String].self, forKey: favoritesKey) ?? []
        
        if favoriteIds.contains(situation.id) {
            favoriteIds.removeAll { $0 == situation.id }
        } else {
            favoriteIds.append(situation.id)
        }
        
        try await localStorage.save(favoriteIds, forKey: favoritesKey)
    }
}