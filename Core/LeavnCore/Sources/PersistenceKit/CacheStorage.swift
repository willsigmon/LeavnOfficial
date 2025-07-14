import Foundation

// MARK: - Cache Storage
public final class CacheStorage: Storage {
    private let memoryCache: NSCache<NSString, NSData>
    private let diskCache: FileStorage
    private let configuration: CacheConfiguration
    
    public init(configuration: CacheConfiguration) throws {
        self.configuration = configuration
        
        // Setup memory cache
        self.memoryCache = NSCache<NSString, NSData>()
        self.memoryCache.totalCostLimit = configuration.memoryCapacity
        
        // Setup disk cache
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let diskCacheURL = cacheDirectory.appendingPathComponent(configuration.diskPath ?? "com.leavn.cache")
        self.diskCache = FileStorage(directory: diskCacheURL)
    }
    
    public func save<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        
        // Save to memory cache
        memoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        
        // Save to disk cache
        try await diskCache.save(object, forKey: key)
    }
    
    public func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        // Check memory cache first
        if let data = memoryCache.object(forKey: key as NSString) as Data? {
            return try JSONDecoder().decode(type, from: data)
        }
        
        // Check disk cache
        if let object = try await diskCache.load(type, forKey: key) {
            // Update memory cache
            let data = try JSONEncoder().encode(object)
            memoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
            return object
        }
        
        return nil
    }
    
    public func remove(forKey key: String) async throws {
        memoryCache.removeObject(forKey: key as NSString)
        try await diskCache.remove(forKey: key)
    }
    
    public func exists(forKey key: String) async throws -> Bool {
        if memoryCache.object(forKey: key as NSString) != nil {
            return true
        }
        return try await diskCache.exists(forKey: key)
    }
    
    public func clear() async throws {
        memoryCache.removeAllObjects()
        try await diskCache.clear()
    }
}