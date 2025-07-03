import Foundation
import Security

/// Helper class for securely storing API keys in the iOS Keychain
public struct KeychainHelper {
    
    private static let service = "com.leavn.api-keys"
    
    /// Store an API key in the keychain
    public static func setAPIKey(_ key: String, for identifier: String) {
        let data = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Failed to store API key in keychain: \(status)")
        }
    }
    
    /// Retrieve an API key from the keychain
    public static func getAPIKey(for identifier: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    /// Delete an API key from the keychain
    public static func deleteAPIKey(for identifier: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    /// Check if an API key exists in the keychain
    public static func hasAPIKey(for identifier: String) -> Bool {
        return getAPIKey(for: identifier) != nil
    }
} 