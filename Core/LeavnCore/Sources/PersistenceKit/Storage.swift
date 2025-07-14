import Foundation

// MARK: - Storage Protocol
public protocol Storage {
    func save<T: Codable>(_ object: T, forKey key: String) async throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
    func exists(forKey key: String) async throws -> Bool
    func clear() async throws
    
    // Deprecated methods for backward compatibility
    func delete(forKey key: String) async throws
    func deleteAll() async throws
}

// MARK: - Default implementations for deprecated methods
public extension Storage {
    func delete(forKey key: String) async throws {
        try await remove(forKey: key)
    }
    
    func deleteAll() async throws {
        try await clear()
    }
}

// MARK: - In-Memory Storage
public final class InMemoryStorage: Storage {
    private var storage: [String: Data] = [:]
    private let queue = DispatchQueue(label: "com.leavn.inmemory.storage", attributes: .concurrent)
    
    public init() {}
    
    public func save<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        queue.async(flags: .barrier) {
            self.storage[key] = data
        }
    }
    
    public func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        return queue.sync {
            guard let data = storage[key] else { return nil }
            return try? JSONDecoder().decode(type, from: data)
        }
    }
    
    public func remove(forKey key: String) async throws {
        queue.async(flags: .barrier) {
            self.storage.removeValue(forKey: key)
        }
    }
    
    public func exists(forKey key: String) async throws -> Bool {
        return queue.sync {
            storage[key] != nil
        }
    }
    
    public func clear() async throws {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }
}

// MARK: - File Storage
public final class FileStorage: Storage {
    private let documentsDirectory: URL
    private let fileManager = FileManager.default
    
    public init(directory: URL? = nil) {
        if let directory = directory {
            self.documentsDirectory = directory
        } else {
            self.documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
        // Create directory if needed
        try? fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
    }
    
    private func fileURL(for key: String) -> URL {
        documentsDirectory.appendingPathComponent("\(key).json")
    }
    
    public func save<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        let url = fileURL(for: key)
        try data.write(to: url)
    }
    
    public func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        let url = fileURL(for: key)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        let url = fileURL(for: key)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    public func exists(forKey key: String) async throws -> Bool {
        let url = fileURL(for: key)
        return fileManager.fileExists(atPath: url.path)
    }
    
    public func clear() async throws {
        let contents = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
        for url in contents where url.pathExtension == "json" {
            try fileManager.removeItem(at: url)
        }
    }
}

// MARK: - UserDefaults Storage
public final class UserDefaultsStorage: Storage {
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func save<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        userDefaults.set(data, forKey: key)
    }
    
    public func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        userDefaults.removeObject(forKey: key)
    }
    
    public func exists(forKey key: String) async throws -> Bool {
        userDefaults.object(forKey: key) != nil
    }
    
    public func clear() async throws {
        if let bundleId = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleId)
        }
    }
}