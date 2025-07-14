import Foundation

// MARK: - Authentication Service Protocol
public protocol AuthenticationService {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, displayName: String) async throws -> User
    func signInWithApple(identityToken: Data, nonce: String) async throws -> User
    func signOut() async throws
    func refreshToken() async throws
    func resetPassword(email: String) async throws
    func updateProfile(displayName: String?, photoURL: URL?) async throws -> User
}

// MARK: - Auth Models
public struct AuthTokens: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: TimeInterval
    
    public init(accessToken: String, refreshToken: String, expiresIn: TimeInterval) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
}

public struct SignInRequest: Codable {
    public let email: String
    public let password: String
}

public struct SignUpRequest: Codable {
    public let email: String
    public let password: String
    public let displayName: String
}

public struct AppleSignInRequest: Codable {
    public let identityToken: String
    public let nonce: String
}

// MARK: - Authentication Service Implementation
public final class DefaultAuthenticationService: AuthenticationService {
    private let networkService: NetworkService
    private let keychainStorage: SecureStorage
    private let userStorage: Storage
    private let apiClient: AuthAPIClient
    
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let currentUserKey = "current_user"
    
    @Published private var _currentUser: User?
    
    public var isAuthenticated: Bool {
        currentUser != nil
    }
    
    public var currentUser: User? {
        _currentUser
    }
    
    public init(
        networkService: NetworkService,
        keychainStorage: SecureStorage,
        userStorage: Storage
    ) {
        self.networkService = networkService
        self.keychainStorage = keychainStorage
        self.userStorage = userStorage
        self.apiClient = AuthAPIClient(networkService: networkService)
        
        Task {
            await loadCurrentUser()
        }
    }
    
    public func signIn(email: String, password: String) async throws -> User {
        let request = SignInRequest(email: email, password: password)
        let response = try await apiClient.signIn(request: request)
        
        try await saveTokens(response.tokens)
        try await saveUser(response.user)
        
        return response.user
    }
    
    public func signUp(email: String, password: String, displayName: String) async throws -> User {
        let request = SignUpRequest(email: email, password: password, displayName: displayName)
        let response = try await apiClient.signUp(request: request)
        
        try await saveTokens(response.tokens)
        try await saveUser(response.user)
        
        return response.user
    }
    
    public func signInWithApple(identityToken: Data, nonce: String) async throws -> User {
        let tokenString = String(data: identityToken, encoding: .utf8) ?? ""
        let request = AppleSignInRequest(identityToken: tokenString, nonce: nonce)
        let response = try await apiClient.signInWithApple(request: request)
        
        try await saveTokens(response.tokens)
        try await saveUser(response.user)
        
        return response.user
    }
    
    public func signOut() async throws {
        try await apiClient.signOut()
        try await clearAuthData()
    }
    
    public func refreshToken() async throws {
        guard let refreshToken = try await keychainStorage.loadSecure(forKey: refreshTokenKey),
              let refreshTokenString = String(data: refreshToken, encoding: .utf8) else {
            throw LeavnError.unauthorized
        }
        
        let tokens = try await apiClient.refreshToken(refreshToken: refreshTokenString)
        try await saveTokens(tokens)
    }
    
    public func resetPassword(email: String) async throws {
        try await apiClient.resetPassword(email: email)
    }
    
    public func updateProfile(displayName: String?, photoURL: URL?) async throws -> User {
        let user = try await apiClient.updateProfile(displayName: displayName, photoURL: photoURL)
        try await saveUser(user)
        return user
    }
    
    // MARK: - Private Methods
    private func saveTokens(_ tokens: AuthTokens) async throws {
        try await keychainStorage.saveSecure(
            tokens.accessToken.data(using: .utf8)!,
            forKey: accessTokenKey
        )
        try await keychainStorage.saveSecure(
            tokens.refreshToken.data(using: .utf8)!,
            forKey: refreshTokenKey
        )
    }
    
    private func saveUser(_ user: User) async throws {
        try await userStorage.save(user, forKey: currentUserKey)
        await MainActor.run {
            self._currentUser = user
        }
    }
    
    private func loadCurrentUser() async {
        if let user = try? await userStorage.load(User.self, forKey: currentUserKey) {
            await MainActor.run {
                self._currentUser = user
            }
        }
    }
    
    private func clearAuthData() async throws {
        try await keychainStorage.delete(forKey: accessTokenKey)
        try await keychainStorage.delete(forKey: refreshTokenKey)
        try await userStorage.delete(forKey: currentUserKey)
        
        await MainActor.run {
            self._currentUser = nil
        }
    }
}

// MARK: - Auth API Client
private final class AuthAPIClient: BaseAPIClient {
    struct AuthResponse: Codable {
        let user: User
        let tokens: AuthTokens
    }
    
    func signIn(request: SignInRequest) async throws -> AuthResponse {
        let endpoint = Endpoint(
            path: "/auth/signin",
            method: .post,
            parameters: [
                "email": request.email,
                "password": request.password
            ],
            encoding: JSONEncoding.default
        )
        return try await networkService.request(endpoint)
    }
    
    func signUp(request: SignUpRequest) async throws -> AuthResponse {
        let endpoint = Endpoint(
            path: "/auth/signup",
            method: .post,
            parameters: [
                "email": request.email,
                "password": request.password,
                "displayName": request.displayName
            ],
            encoding: JSONEncoding.default
        )
        return try await networkService.request(endpoint)
    }
    
    func signInWithApple(request: AppleSignInRequest) async throws -> AuthResponse {
        let endpoint = Endpoint(
            path: "/auth/apple",
            method: .post,
            parameters: [
                "identityToken": request.identityToken,
                "nonce": request.nonce
            ],
            encoding: JSONEncoding.default
        )
        return try await networkService.request(endpoint)
    }
    
    func signOut() async throws {
        let endpoint = Endpoint(
            path: "/auth/signout",
            method: .post
        )
        _ = try await networkService.request(endpoint)
    }
    
    func refreshToken(refreshToken: String) async throws -> AuthTokens {
        let endpoint = Endpoint(
            path: "/auth/refresh",
            method: .post,
            parameters: ["refreshToken": refreshToken],
            encoding: JSONEncoding.default
        )
        return try await networkService.request(endpoint)
    }
    
    func resetPassword(email: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/reset-password",
            method: .post,
            parameters: ["email": email],
            encoding: JSONEncoding.default
        )
        _ = try await networkService.request(endpoint)
    }
    
    func updateProfile(displayName: String?, photoURL: URL?) async throws -> User {
        var parameters: [String: Any] = [:]
        if let displayName = displayName {
            parameters["displayName"] = displayName
        }
        if let photoURL = photoURL {
            parameters["photoURL"] = photoURL.absoluteString
        }
        
        let endpoint = Endpoint(
            path: "/auth/profile",
            method: .patch,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        return try await networkService.request(endpoint)
    }
}