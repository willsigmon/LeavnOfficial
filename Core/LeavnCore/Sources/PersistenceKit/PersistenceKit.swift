import Foundation

// MARK: - PersistenceKit
// This file serves as the main entry point for the PersistenceKit module.
// It re-exports the public API from other files in the module.

// MARK: - Cache Configuration
public struct CacheConfiguration {
    public let memoryCapacity: Int
    public let diskCapacity: Int
    public let diskPath: String?
    
    public init(
        memoryCapacity: Int = 50 * 1024 * 1024, // 50 MB
        diskCapacity: Int = 100 * 1024 * 1024, // 100 MB
        diskPath: String? = nil
    ) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.diskPath = diskPath
    }
}