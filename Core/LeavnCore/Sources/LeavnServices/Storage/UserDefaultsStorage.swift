import Foundation

// MARK: - Storage Protocol
public protocol Storage {
    func save<T: Codable>(_ object: T, forKey key: String) async throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
    func exists(forKey key: String) async -> Bool
}

// MARK: - UserDefaults Storage Implementation
public final class UserDefaultsStorage: Storage {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func save<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try encoder.encode(object)
        userDefaults.set(data, forKey: key)
    }
    
    public func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try decoder.decode(type, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        userDefaults.removeObject(forKey: key)
    }
    
    public func exists(forKey key: String) async -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
}

// MARK: - Secure Storage Protocol
public protocol SecureStorage {
    func save<T: Codable>(_ object: T, forKey key: String) async throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
    func exists(forKey key: String) async -> Bool
}