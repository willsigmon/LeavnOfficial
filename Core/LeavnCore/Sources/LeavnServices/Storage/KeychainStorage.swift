import Foundation
import Security

// MARK: - Keychain Storage Implementation
public final class KeychainStorage: SecureStorage {
    private let service: String
    private let accessGroup: String?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(service: String = Bundle.main.bundleIdentifier ?? "com.leavn.app", accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
    
    public func save<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try encoder.encode(object)
        
        // Create query
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                return nil
            }
            return try decoder.decode(type, from: data)
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public func remove(forKey key: String) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    public func exists(forKey key: String) async -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

// MARK: - Keychain Error
public enum KeychainError: LocalizedError {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .noPassword:
            return "No password found in keychain"
        case .unexpectedPasswordData:
            return "Unexpected password data format"
        case .unhandledError(let status):
            return "Keychain error: \(status)"
        }
    }
}