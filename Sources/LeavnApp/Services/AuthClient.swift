import Foundation
import Dependencies

// MARK: - Auth Client
public struct AuthClient: Sendable {
    public var login: @Sendable (String, String) async throws -> User
    public var logout: @Sendable () async throws -> Void
    public var signUp: @Sendable (String, String, String) async throws -> User
    public var getAccessToken: @Sendable () async throws -> String?
    public var refreshToken: @Sendable () async throws -> String
    public var deleteAccount: @Sendable () async throws -> Void
    public var getCurrentUser: @Sendable () async throws -> User?
    public var updateProfile: @Sendable (String?, String?) async throws -> User
}

// MARK: - Dependency Implementation
extension AuthClient: DependencyKey {
    public static let liveValue = Self(
        login: { email, password in
            @Dependency(\.networkLayer) var networkLayer
            
            let parameters = [
                "email": email,
                "password": password
            ]
            
            let data = try await networkLayer.request("/auth/login", .post, parameters)
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            
            // Store tokens
            try Keychain.shared.set(response.accessToken, for: .accessToken)
            try Keychain.shared.set(response.refreshToken, for: .refreshToken)
            
            return response.user
        },
        logout: {
            @Dependency(\.networkLayer) var networkLayer
            
            _ = try await networkLayer.request("/auth/logout", .post, nil)
            
            // Clear tokens
            try Keychain.shared.delete(.accessToken)
            try Keychain.shared.delete(.refreshToken)
        },
        signUp: { email, password, name in
            @Dependency(\.networkLayer) var networkLayer
            
            let parameters = [
                "email": email,
                "password": password,
                "name": name
            ]
            
            let data = try await networkLayer.request("/auth/signup", .post, parameters)
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            
            // Store tokens
            try Keychain.shared.set(response.accessToken, for: .accessToken)
            try Keychain.shared.set(response.refreshToken, for: .refreshToken)
            
            return response.user
        },
        getAccessToken: {
            try Keychain.shared.get(.accessToken)
        },
        refreshToken: {
            @Dependency(\.networkLayer) var networkLayer
            
            guard let refreshToken = try Keychain.shared.get(.refreshToken) else {
                throw AuthError.noRefreshToken
            }
            
            let parameters = ["refreshToken": refreshToken]
            let data = try await networkLayer.request("/auth/refresh", .post, parameters)
            let response = try JSONDecoder().decode(TokenResponse.self, from: data)
            
            // Update access token
            try Keychain.shared.set(response.accessToken, for: .accessToken)
            
            return response.accessToken
        },
        deleteAccount: {
            @Dependency(\.networkLayer) var networkLayer
            
            _ = try await networkLayer.request("/auth/delete", .delete, nil)
            
            // Clear all data
            try Keychain.shared.delete(.accessToken)
            try Keychain.shared.delete(.refreshToken)
        },
        getCurrentUser: {
            @Dependency(\.networkLayer) var networkLayer
            
            let data = try await networkLayer.request("/auth/me", .get, nil)
            return try JSONDecoder().decode(User.self, from: data)
        },
        updateProfile: { name, email in
            @Dependency(\.networkLayer) var networkLayer
            
            var parameters: [String: Any] = [:]
            if let name = name { parameters["name"] = name }
            if let email = email { parameters["email"] = email }
            
            let data = try await networkLayer.request("/auth/profile", .patch, parameters)
            return try JSONDecoder().decode(User.self, from: data)
        }
    )
    
    public static let testValue = Self(
        login: { _, _ in TestFixtures.sampleUser },
        logout: { },
        signUp: { _, _, _ in TestFixtures.sampleUser },
        getAccessToken: { "test-token" },
        refreshToken: { "new-test-token" },
        deleteAccount: { },
        getCurrentUser: { TestFixtures.sampleUser },
        updateProfile: { _, _ in TestFixtures.sampleUser }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - Response Models
private struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

private struct TokenResponse: Codable {
    let accessToken: String
}

// MARK: - Auth Errors
public enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case noRefreshToken
    case tokenExpired
    case unauthorized
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .noRefreshToken:
            return "No refresh token available"
        case .tokenExpired:
            return "Your session has expired"
        case .unauthorized:
            return "You are not authorized to perform this action"
        }
    }
}

// MARK: - Keychain Helper
private struct Keychain {
    static let shared = Keychain()
    
    enum Key: String {
        case accessToken = "com.leavn.accessToken"
        case refreshToken = "com.leavn.refreshToken"
    }
    
    func set(_ value: String, for key: Key) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }
    
    func get(_ key: Key) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func delete(_ key: Key) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: Error {
    case unableToStore
}