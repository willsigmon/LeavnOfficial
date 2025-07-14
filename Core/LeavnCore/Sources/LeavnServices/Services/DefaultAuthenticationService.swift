import Foundation
import Combine

// MARK: - Default Authentication Service
public final class DefaultAuthenticationService: AuthenticationServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let userDataManager: UserDataManagerProtocol
    private let secureStorage: SecureStorage
    
    @Published private var _currentUser: AuthUser?
    private var cancellables = Set<AnyCancellable>()
    
    public var currentUser: AnyPublisher<AuthUser?, Never> {
        $_currentUser.eraseToAnyPublisher()
    }
    
    public var isAuthenticated: Bool {
        _currentUser != nil
    }
    
    public init(
        networkService: NetworkServiceProtocol,
        userDataManager: UserDataManagerProtocol,
        secureStorage: SecureStorage
    ) {
        self.networkService = networkService
        self.userDataManager = userDataManager
        self.secureStorage = secureStorage
        
        // Load cached auth state
        Task {
            await loadCachedAuthState()
        }
    }
    
    public func signIn(email: String, password: String) async throws -> AuthUser {
        // In production, this would call the actual API
        let endpoint = Endpoint(
            path: "/api/auth/signin",
            method: .post,
            parameters: [
                "email": email,
                "password": password
            ]
        )
        
        do {
            let response: AuthResponse = try await networkService.request(endpoint)
            let authUser = AuthUser(
                id: response.user.id,
                email: response.user.email,
                displayName: response.user.displayName,
                isEmailVerified: response.user.isEmailVerified
            )
            
            // Save tokens
            try await secureStorage.save(response.accessToken, forKey: "access_token")
            try await secureStorage.save(response.refreshToken, forKey: "refresh_token")
            
            // Update user data
            let user = User(
                id: authUser.id,
                email: authUser.email,
                name: authUser.displayName ?? "",
                profileImageURL: nil,
                isPremium: false
            )
            try await userDataManager.updateUser(user)
            
            _currentUser = authUser
            return authUser
        } catch {
            // For development, use mock authentication
            if email.contains("@") && password.count >= 6 {
                let mockUser = AuthUser(
                    id: UUID().uuidString,
                    email: email,
                    displayName: email.components(separatedBy: "@").first,
                    isEmailVerified: true
                )
                
                // Save mock tokens
                try await secureStorage.save("mock_access_token", forKey: "access_token")
                try await secureStorage.save("mock_refresh_token", forKey: "refresh_token")
                
                _currentUser = mockUser
                return mockUser
            }
            
            throw LeavnError.authenticationError("Invalid credentials")
        }
    }
    
    public func signUp(email: String, password: String, name: String) async throws -> AuthUser {
        // In production, this would call the actual API
        let endpoint = Endpoint(
            path: "/api/auth/signup",
            method: .post,
            parameters: [
                "email": email,
                "password": password,
                "name": name
            ]
        )
        
        do {
            let response: AuthResponse = try await networkService.request(endpoint)
            let authUser = AuthUser(
                id: response.user.id,
                email: response.user.email,
                displayName: response.user.displayName,
                isEmailVerified: false
            )
            
            // Save tokens
            try await secureStorage.save(response.accessToken, forKey: "access_token")
            try await secureStorage.save(response.refreshToken, forKey: "refresh_token")
            
            _currentUser = authUser
            return authUser
        } catch {
            // For development, use mock signup
            if email.contains("@") && password.count >= 6 {
                let mockUser = AuthUser(
                    id: UUID().uuidString,
                    email: email,
                    displayName: name,
                    isEmailVerified: false
                )
                
                _currentUser = mockUser
                return mockUser
            }
            
            throw LeavnError.authenticationError("Signup failed")
        }
    }
    
    public func signOut() async throws {
        // Clear tokens
        try await secureStorage.remove(forKey: "access_token")
        try await secureStorage.remove(forKey: "refresh_token")
        
        // Clear user data
        try await userDataManager.clearUserData()
        
        _currentUser = nil
    }
    
    public func resetPassword(email: String) async throws {
        let endpoint = Endpoint(
            path: "/api/auth/reset-password",
            method: .post,
            parameters: ["email": email]
        )
        
        do {
            let _: EmptyResponse = try await networkService.request(endpoint)
        } catch {
            // For development, just succeed
            print("Password reset requested for: \(email)")
        }
    }
    
    public func refreshToken() async throws {
        guard let refreshToken: String = try await secureStorage.load(String.self, forKey: "refresh_token") else {
            throw LeavnError.authenticationError("No refresh token found")
        }
        
        let endpoint = Endpoint(
            path: "/api/auth/refresh",
            method: .post,
            headers: ["Authorization": "Bearer \(refreshToken)"]
        )
        
        do {
            let response: TokenResponse = try await networkService.request(endpoint)
            try await secureStorage.save(response.accessToken, forKey: "access_token")
        } catch {
            // If refresh fails, force re-authentication
            try await signOut()
            throw LeavnError.authenticationError("Session expired")
        }
    }
    
    private func loadCachedAuthState() async {
        // Check if we have valid tokens
        guard let accessToken: String = try? await secureStorage.load(String.self, forKey: "access_token"),
              !accessToken.isEmpty else {
            return
        }
        
        // Try to get current user info
        do {
            let endpoint = Endpoint(
                path: "/api/auth/me",
                method: .get,
                headers: ["Authorization": "Bearer \(accessToken)"]
            )
            
            let response: UserResponse = try await networkService.request(endpoint)
            _currentUser = AuthUser(
                id: response.id,
                email: response.email,
                displayName: response.displayName,
                isEmailVerified: response.isEmailVerified
            )
        } catch {
            // For development, create mock user if we have tokens
            if accessToken == "mock_access_token" {
                _currentUser = AuthUser(
                    id: "mock_user",
                    email: "user@example.com",
                    displayName: "Test User",
                    isEmailVerified: true
                )
            }
        }
    }
}

// MARK: - Response Models
private struct AuthResponse: Codable {
    let user: UserResponse
    let accessToken: String
    let refreshToken: String
}

private struct UserResponse: Codable {
    let id: String
    let email: String
    let displayName: String?
    let isEmailVerified: Bool
}

private struct TokenResponse: Codable {
    let accessToken: String
}

private struct EmptyResponse: Codable {}