import Foundation
import LeavnCore

// MARK: - Production Cache Service Implementation

public actor ProductionCacheService: CacheServiceProtocol {
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxCacheSize: Int64 = 100 * 1024 * 1024 // 100 MB
    private let defaultExpirationInterval: TimeInterval = 3600 // 1 hour
    
    private var isInitialized = false
    
    // MARK: - Initialization
    
    public init() throws {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ServiceError.unknown(NSError(domain: "LeavnCache", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not access documents directory"]))
        }
        
        self.cacheDirectory = documentsDirectory.appendingPathComponent("LeavnCache", isDirectory: true)
    }
    
    public func initialize() async throws {
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Clean up expired items on initialization
        await clearExpiredItems()
        
        // Ensure cache size is within limits
        await enforceCacheSize()
        
        isInitialized = true
        print("💾 ProductionCacheService initialized at \(cacheDirectory.path)")
    }
    
    // MARK: - CacheServiceProtocol Implementation
    
    public func get<T: Codable & Sendable>(_ key: String, type: T.Type) async -> T? {
        guard isInitialized else { return nil }
        
        let url = cacheFileURL(for: key)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let cacheItem = try JSONDecoder().decode(CacheItem<T>.self, from: data)
            
            // Check if expired
            if let expirationDate = cacheItem.expirationDate, expirationDate < Date() {
                await remove(key)
                return nil
            }
            
            // Update access date for LRU
            await updateAccessDate(for: key)
            
            return cacheItem.value
        } catch {
            // Remove corrupted cache file
            try? fileManager.removeItem(at: url)
            return nil
        }
    }
    
    public func set<T: Codable & Sendable>(_ key: String, value: T, expirationDate: Date? = nil) async {
        guard isInitialized else { return }
        
        let finalExpirationDate = expirationDate ?? Date().addingTimeInterval(defaultExpirationInterval)
        let cacheItem = CacheItem(
            value: value,
            createdDate: Date(),
            accessDate: Date(),
            expirationDate: finalExpirationDate
        )
        
        do {
            let data = try JSONEncoder().encode(cacheItem)
            let url = cacheFileURL(for: key)
            try data.write(to: url)
            
            // Enforce cache size limits
            await enforceCacheSize()
        } catch {
            print("Cache write error for key \(key): \(error)")
        }
    }
    
    public func remove(_ key: String) async {
        guard isInitialized else { return }
        
        let url = cacheFileURL(for: key)
        try? fileManager.removeItem(at: url)
    }
    
    public func clear() async {
        guard isInitialized else { return }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for url in contents {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Cache clear error: \(error)")
        }
    }
    
    public func getCacheSize() async -> Int64 {
        guard isInitialized else { return 0 }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            var totalSize: Int64 = 0
            
            for url in contents {
                let resources = try url.resourceValues(forKeys: [.fileSizeKey])
                totalSize += Int64(resources.fileSize ?? 0)
            }
            
            return totalSize
        } catch {
            return 0
        }
    }
    
    public func clearExpiredItems() async {
        guard isInitialized else { return }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            let now = Date()
            
            for url in contents {
                do {
                    let data = try Data(contentsOf: url)
                    let metadata = try JSONDecoder().decode(CacheMetadata.self, from: data)
                    
                    if let expirationDate = metadata.expirationDate, expirationDate < now {
                        try fileManager.removeItem(at: url)
                    }
                } catch {
                    // Remove corrupted files
                    try? fileManager.removeItem(at: url)
                }
            }
        } catch {
            print("Clear expired items error: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func cacheFileURL(for key: String) -> URL {
        let sanitizedKey = key.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return cacheDirectory.appendingPathComponent("\(sanitizedKey).cache")
    }
    
    private func updateAccessDate(for key: String) async {
        let url = cacheFileURL(for: key)
        
        do {
            let data = try Data(contentsOf: url)
            var metadata = try JSONDecoder().decode(CacheMetadata.self, from: data)
            metadata.accessDate = Date()
            
            // Note: In a full implementation, you might want to update just the metadata
            // rather than rewriting the entire file
        } catch {
            // Ignore errors for access date updates
        }
    }
    
    private func enforceCacheSize() async {
        let currentSize = await getCacheSize()
        
        if currentSize > maxCacheSize {
            await removeLeastRecentlyUsedItems(targetSize: maxCacheSize * 3 / 4) // Reduce to 75% of max
        }
    }
    
    private func removeLeastRecentlyUsedItems(targetSize: Int64) async {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            
            // Get file info with access dates
            var fileInfos: [(url: URL, accessDate: Date, size: Int64)] = []
            
            for url in contents {
                do {
                    let data = try Data(contentsOf: url)
                    let metadata = try JSONDecoder().decode(CacheMetadata.self, from: data)
                    let resources = try url.resourceValues(forKeys: [.fileSizeKey])
                    let size = Int64(resources.fileSize ?? 0)
                    
                    fileInfos.append((url: url, accessDate: metadata.accessDate, size: size))
                } catch {
                    // Remove corrupted files
                    try? fileManager.removeItem(at: url)
                }
            }
            
            // Sort by access date (oldest first)
            fileInfos.sort { $0.accessDate < $1.accessDate }
            
            // Remove files until we reach target size
            var currentSize = fileInfos.reduce(0) { $0 + $1.size }
            
            for fileInfo in fileInfos {
                if currentSize <= targetSize {
                    break
                }
                
                try? fileManager.removeItem(at: fileInfo.url)
                currentSize -= fileInfo.size
            }
        } catch {
            print("LRU cleanup error: \(error)")
        }
    }
}

// MARK: - Cache Item Model

// Added `Sendable` to conform to Swift 6 concurrency requirements for generic parameters.
// This ensures CacheItem is concurrency-safe when used across actors.
private struct CacheItem<T: Codable & Sendable>: Codable {
    let value: T
    let createdDate: Date
    var accessDate: Date
    let expirationDate: Date?
}

private struct CacheMetadata: Codable {
    let createdDate: Date
    var accessDate: Date
    let expirationDate: Date?
}

// MARK: - Static Cache Manager (Legacy Support)

// Marked as @MainActor to ensure thread-safe usage for static/shared cache manager (Swift 6 concurrency compliance).
@MainActor
public class CacheManager {
    private static let shared = CacheManager()
    private let userDefaults = UserDefaults.standard
    private let memoryCache = NSCache<NSString, NSData>()
    
    public init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
        nonisolated public static func cacheKey(for endpoint: String) -> String {
        return "cache_" + endpoint.replacingOccurrences(of: "/", with: "_")
    }
    
    public func get(key: String) async -> Data? {
        // Check memory cache first
        if let data = memoryCache.object(forKey: key as NSString) {
            return data as Data
        }
        
        // Check UserDefaults
        return userDefaults.data(forKey: key)
    }
    
    public func set(key: String, data: Data) async {
        // Store in memory cache
        memoryCache.setObject(data as NSData, forKey: key as NSString)
        
        // Store in UserDefaults (for persistence)
        userDefaults.set(data, forKey: key)
    }
    
    public func remove(key: String) async {
        memoryCache.removeObject(forKey: key as NSString)
        userDefaults.removeObject(forKey: key)
    }
    
    public func clear() async {
        memoryCache.removeAllObjects()
        
        // Clear all cache keys from UserDefaults
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix("cache_") {
            userDefaults.removeObject(forKey: key)
        }
    }
}

