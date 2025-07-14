import Foundation
import LeavnCore
import NetworkingKit
import PersistenceKit

public final class DefaultAuthRepository: AuthRepository {
    private let networkService: NetworkService
    private let secureStorage: SecureStorage
    private let localStorage: Storage
    private let authAPIClient: AuthAPIClient
    
    // Storage keys
    private let currentUserKey = "current_auth_user"
    private let sessionKey = "auth_session"
    private let refreshTokenKey = "refresh_token"
    
    // State management
    private let authStateSubject = AsyncChannel<AuthState>()
    private var _currentUser: AuthUser?
    private var _currentSession: AuthSession?
    
    public var authState: AsyncStream<AuthState> {
        authStateSubject.stream
    }
    
    public var currentUser: AuthUser? {
        get async {
            if _currentUser == nil {
                await loadCurrentUser()
            }
            return _currentUser
        }
    }
    
    public var isAuthenticated: Bool {
        get async {
            await currentUser != nil
        }
    }
    
    public init(
        networkService: NetworkService,
        secureStorage: SecureStorage,
        localStorage: Storage
    ) {
        self.networkService = networkService
        self.secureStorage = secureStorage
        self.localStorage = localStorage
        self.authAPIClient = AuthAPIClient(networkService: networkService)
        
        Task {
            await loadCurrentUser()
            await loadCurrentSession()
        }
    }
    
    // MARK: - Sign In Methods
    public func signIn(credentials: AuthCredentials) async throws -> AuthUser {
        await updateAuthState(.authenticating)
        
        do {
            let response = try await authAPIClient.signIn(
                email: credentials.email,
                password: credentials.password
            )
            
            let user = response.user.toDomainModel()
            let session = response.session.toDomainModel(user: user)
            
            await saveUser(user)
            await saveSession(session)
            await updateAuthState(.authenticated(user))
            
            return user
        } catch {
            let authError = mapError(error)
            await updateAuthState(.error(authError))
            throw authError
        }
    }
    
    public func signInWithApple(credentials: AppleAuthCredentials) async throws -> AuthUser {
        await updateAuthState(.authenticating)
        
        do {
            let tokenString = String(data: credentials.identityToken, encoding: .utf8) ?? ""
            let response = try await authAPIClient.signInWithApple(
                identityToken: tokenString,
                nonce: credentials.nonce,
                fullName: credentials.fullName?.formatted(),
                email: credentials.email
            )
            
            let user = response.user.toDomainModel()
            let session = response.session.toDomainModel(user: user)
            
            await saveUser(user)
            await saveSession(session)
            await updateAuthState(.authenticated(user))
            
            return user
        } catch {
            let authError = mapError(error)
            await updateAuthState(.error(authError))
            throw authError
        }
    }
    
    public func signInWithGoogle(idToken: String) async throws -> AuthUser {
        await updateAuthState(.authenticating)
        
        do {
            let response = try await authAPIClient.signInWithGoogle(idToken: idToken)
            
            let user = response.user.toDomainModel()
            let session = response.session.toDomainModel(user: user)
            
            await saveUser(user)
            await saveSession(session)
            await updateAuthState(.authenticated(user))
            
            return user
        } catch {
            let authError = mapError(error)
            await updateAuthState(.error(authError))
            throw authError
        }
    }
    
    // MARK: - Sign Up Methods
    public func signUp(credentials: SignUpCredentials) async throws -> AuthUser {
        await updateAuthState(.authenticating)
        
        do {
            let response = try await authAPIClient.signUp(
                email: credentials.email,
                password: credentials.password,
                displayName: credentials.displayName
            )
            
            let user = response.user.toDomainModel()
            let session = response.session.toDomainModel(user: user)
            
            await saveUser(user)
            await saveSession(session)
            await updateAuthState(.authenticated(user))
            
            return user
        } catch {
            let authError = mapError(error)
            await updateAuthState(.error(authError))
            throw authError
        }
    }
    
    // MARK: - Sign Out
    public func signOut() async throws {
        try await authAPIClient.signOut()
        await clearAuthData()
        await updateAuthState(.unauthenticated)
    }
    
    // MARK: - Session Management
    public func refreshSession() async throws -> AuthSession {
        guard let currentSession = _currentSession else {
            throw AuthError.userTokenExpired
        }
        
        let response = try await authAPIClient.refreshToken(
            refreshToken: currentSession.refreshToken
        )
        
        let newSession = response.toDomainModel(user: currentSession.user)
        await saveSession(newSession)
        
        return newSession
    }
    
    public func getCurrentSession() async throws -> AuthSession? {
        if _currentSession == nil {
            await loadCurrentSession()
        }
        return _currentSession
    }
    
    public func deleteSession() async throws {
        await clearAuthData()
        await updateAuthState(.unauthenticated)
    }
    
    // MARK: - Password Management
    public func resetPassword(email: String) async throws {
        try await authAPIClient.resetPassword(email: email)
    }
    
    public func updatePassword(request: PasswordUpdateRequest) async throws {
        try await authAPIClient.updatePassword(
            currentPassword: request.currentPassword,
            newPassword: request.newPassword
        )
    }
    
    public func verifyPassword(password: String) async throws -> Bool {
        try await authAPIClient.verifyPassword(password: password)
    }
    
    // MARK: - Profile Management
    public func updateProfile(request: ProfileUpdateRequest) async throws -> AuthUser {
        let response = try await authAPIClient.updateProfile(
            displayName: request.displayName,
            photoURL: request.photoURL
        )
        
        let updatedUser = response.toDomainModel()
        await saveUser(updatedUser)
        await updateAuthState(.authenticated(updatedUser))
        
        return updatedUser
    }
    
    public func uploadProfilePhoto(imageData: Data) async throws -> URL {
        try await authAPIClient.uploadProfilePhoto(imageData: imageData)
    }
    
    public func deleteAccount() async throws {
        try await authAPIClient.deleteAccount()
        await clearAuthData()
        await updateAuthState(.unauthenticated)
    }
    
    // MARK: - Email Verification
    public func sendEmailVerification() async throws {
        try await authAPIClient.sendEmailVerification()
    }
    
    public func verifyEmail(code: String) async throws {
        try await authAPIClient.verifyEmail(code: code)
        
        if var user = _currentUser {
            user = AuthUser(
                id: user.id,
                email: user.email,
                displayName: user.displayName,
                photoURL: user.photoURL,
                isEmailVerified: true,
                authProvider: user.authProvider,
                createdAt: user.createdAt,
                lastSignInAt: user.lastSignInAt
            )
            await saveUser(user)
            await updateAuthState(.authenticated(user))
        }
    }
    
    public func resendEmailVerification() async throws {
        try await authAPIClient.resendEmailVerification()
    }
    
    // MARK: - Account Recovery
    public func sendPasswordResetEmail(email: String) async throws {
        try await authAPIClient.sendPasswordResetEmail(email: email)
    }
    
    public func verifyPasswordResetCode(email: String, code: String) async throws -> String {
        try await authAPIClient.verifyPasswordResetCode(email: email, code: code)
    }
    
    public func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        try await authAPIClient.confirmPasswordReset(
            email: email,
            code: code,
            newPassword: newPassword
        )
    }
    
    // MARK: - Account Linking
    public func linkAppleAccount(credentials: AppleAuthCredentials) async throws {
        let tokenString = String(data: credentials.identityToken, encoding: .utf8) ?? ""
        try await authAPIClient.linkAppleAccount(
            identityToken: tokenString,
            nonce: credentials.nonce
        )
    }
    
    public func linkGoogleAccount(idToken: String) async throws {
        try await authAPIClient.linkGoogleAccount(idToken: idToken)
    }
    
    public func unlinkProvider(provider: AuthProvider) async throws {
        try await authAPIClient.unlinkProvider(provider: provider.rawValue)
    }
    
    // MARK: - Security
    public func getSignInMethods(email: String) async throws -> [AuthProvider] {
        let methods = try await authAPIClient.getSignInMethods(email: email)
        return methods.compactMap { AuthProvider(rawValue: $0) }
    }
    
    public func enableTwoFactorAuth() async throws {
        try await authAPIClient.enableTwoFactorAuth()
    }
    
    public func disableTwoFactorAuth() async throws {
        try await authAPIClient.disableTwoFactorAuth()
    }
    
    public func verifyTwoFactorCode(code: String) async throws {
        try await authAPIClient.verifyTwoFactorCode(code: code)
    }
    
    // MARK: - Private Methods
    private func loadCurrentUser() async {
        do {
            _currentUser = try await localStorage.load(AuthUser.self, forKey: currentUserKey)
        } catch {
            _currentUser = nil
        }
    }
    
    private func loadCurrentSession() async {
        do {
            _currentSession = try await secureStorage.load(AuthSession.self, forKey: sessionKey)
        } catch {
            _currentSession = nil
        }
    }
    
    private func saveUser(_ user: AuthUser) async {
        _currentUser = user
        do {
            try await localStorage.save(user, forKey: currentUserKey)
        } catch {
            print("Failed to save user: \\(error)")
        }
    }
    
    private func saveSession(_ session: AuthSession) async {
        _currentSession = session
        do {
            try await secureStorage.save(session, forKey: sessionKey)
        } catch {
            print("Failed to save session: \\(error)")
        }
    }
    
    private func clearAuthData() async {
        _currentUser = nil
        _currentSession = nil
        
        do {
            try await localStorage.delete(forKey: currentUserKey)
            try await secureStorage.delete(forKey: sessionKey)
        } catch {
            print("Failed to clear auth data: \\(error)")
        }
    }
    
    @MainActor
    private func updateAuthState(_ state: AuthState) async {
        await authStateSubject.send(state)
    }
    
    private func mapError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        
        if let apiError = error as? APIError {
            switch apiError.code {
            case "INVALID_CREDENTIALS": return .invalidCredentials
            case "USER_NOT_FOUND": return .userNotFound
            case "EMAIL_ALREADY_EXISTS": return .emailAlreadyInUse
            case "WEAK_PASSWORD": return .weakPassword
            case "INVALID_EMAIL": return .invalidEmail
            case "USER_DISABLED": return .userDisabled
            case "TOO_MANY_REQUESTS": return .tooManyRequests
            case "OPERATION_NOT_ALLOWED": return .operationNotAllowed
            default: return .unknown(apiError.message)
            }
        }
        
        return .unknown(error.localizedDescription)
    }
}

// MARK: - Model Mapping Extensions
private extension AuthUserDTO {
    func toDomainModel() -> AuthUser {
        AuthUser(
            id: id,
            email: email,
            displayName: displayName,
            photoURL: photoURL,
            isEmailVerified: isEmailVerified,
            authProvider: AuthProvider(rawValue: authProvider) ?? .email,
            createdAt: createdAt,
            lastSignInAt: lastSignInAt
        )
    }
}

private extension AuthSessionDTO {
    func toDomainModel(user: AuthUser) -> AuthSession {
        AuthSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            user: user
        )
    }
}

private extension PersonNameComponents {
    func formatted() -> String {
        let formatter = PersonNameComponentsFormatter()
        return formatter.string(from: self)
    }
}

// MARK: - AsyncChannel Helper
private actor AsyncChannel<T> {
    private var continuation: AsyncStream<T>.Continuation?
    
    lazy var stream: AsyncStream<T> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()
    
    func send(_ value: T) {
        continuation?.yield(value)
    }
    
    func finish() {
        continuation?.finish()
    }
}