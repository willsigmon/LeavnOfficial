import Foundation

/// Simple in-memory cache service for fallback when disk cache fails
public actor InMemoryCacheService: CacheServiceProtocol {
    private var cache: [String: (data: Data, expiration: Date?)] = [:]
    private var isInitialized = false
    
    public init() {}
    
    public func initialize() async throws {
        isInitialized = true
        print("📦 InMemoryCacheService initialized")
    }
    
    public func set<T: Codable & Sendable>(_ key: String, value: T, expirationDate: Date?) async {
        guard let data = try? JSONEncoder().encode(value) else { return }
        cache[key] = (data, expirationDate)
    }
    
    public func get<T: Codable & Sendable>(_ key: String, type: T.Type) async -> T? {
        guard let cached = cache[key] else { return nil }
        
        // Check expiration
        if let expiration = cached.expiration, expiration < Date() {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return try? JSONDecoder().decode(type, from: cached.data)
    }
    
    public func remove(_ key: String) async {
        cache.removeValue(forKey: key)
    }
    
    public func clear() async {
        cache.removeAll()
    }
    
    public func getCacheSize() async -> Int64 {
        return cache.values.reduce(0) { $0 + Int64($1.data.count) }
    }
    
    public func clearExpiredItems() async {
        let now = Date()
        cache = cache.filter { _, value in
            if let expiration = value.expiration, expiration < now {
                return false
            }
            return true
        }
    }
}