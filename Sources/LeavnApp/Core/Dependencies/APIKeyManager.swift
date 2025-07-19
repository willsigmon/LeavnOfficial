import Dependencies
import Foundation
import Security

struct APIKeyManager {
    var saveESVKey: @Sendable (String) async throws -> Void
    var getESVKey: @Sendable () async throws -> String?
    var saveElevenLabsKey: @Sendable (String) async throws -> Void
    var getElevenLabsKey: @Sendable () async throws -> String?
    var deleteAllKeys: @Sendable () async throws -> Void
    
    // Computed properties for easier access
    var esvAPIKey: String? {
        get async {
            try? await getESVKey()
        }
    }
    
    var elevenLabsAPIKey: String? {
        get async {
            try? await getElevenLabsKey()
        }
    }
}

extension APIKeyManager: DependencyKey {
    static let liveValue = Self(
        saveESVKey: { key in
            try await KeychainHelper.save(key: key, for: "com.leavn.esv.apikey")
        },
        getESVKey: {
            try await KeychainHelper.load(for: "com.leavn.esv.apikey")
        },
        saveElevenLabsKey: { key in
            try await KeychainHelper.save(key: key, for: "com.leavn.elevenlabs.apikey")
        },
        getElevenLabsKey: {
            try await KeychainHelper.load(for: "com.leavn.elevenlabs.apikey")
        },
        deleteAllKeys: {
            try await KeychainHelper.delete(for: "com.leavn.esv.apikey")
            try await KeychainHelper.delete(for: "com.leavn.elevenlabs.apikey")
        }
    )
}

extension DependencyValues {
    var apiKeyManager: APIKeyManager {
        get { self[APIKeyManager.self] }
        set { self[APIKeyManager.self] = newValue }
    }
}

enum KeychainHelper {
    static func save(key: String, for account: String) async throws {
        let data = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave
        }
    }
    
    static func load(for account: String) async throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.unableToLoad
        }
        
        guard let data = dataTypeRef as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.unableToLoad
        }
        
        return key
    }
    
    static func delete(for account: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete
        }
    }
}

enum KeychainError: LocalizedError {
    case unableToSave
    case unableToLoad
    case unableToDelete
    
    var errorDescription: String? {
        switch self {
        case .unableToSave:
            return "Unable to save API key to keychain"
        case .unableToLoad:
            return "Unable to load API key from keychain"
        case .unableToDelete:
            return "Unable to delete API key from keychain"
        }
    }
}