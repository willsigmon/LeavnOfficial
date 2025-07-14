import Foundation
import Combine

// MARK: - Authentication Domain Models
// These types are shared between LeavnServices and AuthenticationModule

public struct AuthUser: Codable, Identifiable {
    public let id: String
    public let email: String
    public let displayName: String
    public let photoURL: URL?
    public let isEmailVerified: Bool
    public let authProvider: AuthProvider
    public let createdAt: Date
    public let lastSignInAt: Date?
    
    public init(
        id: String,
        email: String,
        displayName: String,
        photoURL: URL? = nil,
        isEmailVerified: Bool = false,
        authProvider: AuthProvider = .email,
        createdAt: Date = Date(),
        lastSignInAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isEmailVerified = isEmailVerified
        self.authProvider = authProvider
        self.createdAt = createdAt
        self.lastSignInAt = lastSignInAt
    }
    
    /// Convert to simplified User type for general use
    public var asUser: User {
        User(id: id, email: email, displayName: displayName, createdAt: createdAt)
    }
}

public enum AuthProvider: String, Codable, CaseIterable {
    case email = "email"
    case apple = "apple"
    case google = "google"
    case facebook = "facebook"
    
    public var displayName: String {
        switch self {
        case .email: return "Email"
        case .apple: return "Sign in with Apple"
        case .google: return "Google"
        case .facebook: return "Facebook"
        }
    }
    
    public var iconName: String {
        switch self {
        case .email: return "envelope"
        case .apple: return "apple.logo"
        case .google: return "globe"
        case .facebook: return "f.square"
        }
    }
}

// MARK: - Authentication State
public enum AuthState {
    case unknown
    case unauthenticated
    case authenticated(AuthUser)
    case refreshing
    
    public var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        }
        return false
    }
    
    public var user: AuthUser? {
        if case .authenticated(let user) = self {
            return user
        }
        return nil
    }
}

// MARK: - Authentication Credentials
public struct AuthCredentials {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    public var isValid: Bool {
        email.isValidEmail && password.count >= 6
    }
}

public struct SignUpCredentials {
    public let email: String
    public let password: String
    public let displayName: String
    public let acceptsTerms: Bool
    
    public init(email: String, password: String, displayName: String, acceptsTerms: Bool) {
        self.email = email
        self.password = password
        self.displayName = displayName
        self.acceptsTerms = acceptsTerms
    }
    
    public var isValid: Bool {
        email.isValidEmail && 
        password.count >= 6 && 
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        acceptsTerms
    }
}

public struct AppleAuthCredentials {
    public let identityToken: Data
    public let nonce: String
    public let fullName: PersonNameComponents?
    
    public init(identityToken: Data, nonce: String, fullName: PersonNameComponents? = nil) {
        self.identityToken = identityToken
        self.nonce = nonce
        self.fullName = fullName
    }
}

// MARK: - Authentication Session
public struct AuthSession: Codable {
    public let accessToken: String
    public let refreshToken: String?
    public let expiresAt: Date
    public let userId: String
    
    public init(accessToken: String, refreshToken: String? = nil, expiresAt: Date, userId: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.userId = userId
    }
    
    public var isExpired: Bool {
        Date() >= expiresAt
    }
    
    public var needsRefresh: Bool {
        // Refresh if less than 5 minutes remaining
        Date().addingTimeInterval(300) >= expiresAt
    }
}

// MARK: - Authentication Requests
public struct PasswordUpdateRequest {
    public let currentPassword: String
    public let newPassword: String
    
    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

public struct ProfileUpdateRequest {
    public let displayName: String?
    public let photoURL: URL?
    
    public init(displayName: String? = nil, photoURL: URL? = nil) {
        self.displayName = displayName
        self.photoURL = photoURL
    }
}

// MARK: - Authentication Repository Protocol
public protocol AuthRepositoryProtocol {
    // Authentication State
    var currentUser: AuthUser? { get async }
    var isAuthenticated: Bool { get async }
    var authState: AsyncStream<AuthState> { get }
    
    // Sign In Methods
    func signIn(credentials: AuthCredentials) async throws -> AuthUser
    func signInWithApple(credentials: AppleAuthCredentials) async throws -> AuthUser
    func signInWithGoogle(idToken: String) async throws -> AuthUser
    
    // Sign Up Methods
    func signUp(credentials: SignUpCredentials) async throws -> AuthUser
    
    // Sign Out
    func signOut() async throws
    
    // Session Management
    func refreshSession() async throws -> AuthSession
    func getCurrentSession() async throws -> AuthSession?
    func deleteSession() async throws
    
    // Password Management
    func resetPassword(email: String) async throws
    func updatePassword(request: PasswordUpdateRequest) async throws
    func verifyPassword(password: String) async throws -> Bool
    
    // Profile Management
    func updateProfile(request: ProfileUpdateRequest) async throws -> AuthUser
    func uploadProfilePhoto(imageData: Data) async throws -> URL
    func deleteAccount() async throws
    
    // Email Verification
    func sendEmailVerification() async throws
    func verifyEmail(code: String) async throws
    func resendEmailVerification() async throws
}

// MARK: - Authentication Use Case Protocols
public protocol SignInUseCaseProtocol {
    func execute(credentials: AuthCredentials) async throws -> AuthUser
    func executeWithApple(credentials: AppleAuthCredentials) async throws -> AuthUser
    func executeWithGoogle(idToken: String) async throws -> AuthUser
}

public protocol SignUpUseCaseProtocol {
    func execute(credentials: SignUpCredentials) async throws -> AuthUser
}

public protocol SignOutUseCaseProtocol {
    func execute() async throws
}

public protocol ResetPasswordUseCaseProtocol {
    func execute(email: String) async throws
}

public protocol UpdateProfileUseCaseProtocol {
    func execute(request: ProfileUpdateRequest) async throws -> AuthUser
    func uploadPhoto(imageData: Data) async throws -> URL
}

public protocol VerifyEmailUseCaseProtocol {
    func sendVerification() async throws
    func verify(code: String) async throws
    func resendVerification() async throws
}

// MARK: - Authentication View Model Protocol
public protocol AuthViewModelProtocol: ObservableObject {
    var currentState: AuthViewState { get }
    func handle(event: AuthViewEvent)
}

// MARK: - Authentication View State
public struct AuthViewState: Equatable {
    public var user: AuthUser?
    public var isAuthenticated: Bool
    public var isLoading: Bool
    public var error: Error?
    public var authMode: AuthMode
    public var email: String
    public var password: String
    public var confirmPassword: String
    public var displayName: String
    public var acceptsTerms: Bool
    public var isPasswordVisible: Bool
    public var validationErrors: [ValidationError]
    
    public init(
        user: AuthUser? = nil,
        isAuthenticated: Bool = false,
        isLoading: Bool = false,
        error: Error? = nil,
        authMode: AuthMode = .signIn,
        email: String = "",
        password: String = "",
        confirmPassword: String = "",
        displayName: String = "",
        acceptsTerms: Bool = false,
        isPasswordVisible: Bool = false,
        validationErrors: [ValidationError] = []
    ) {
        self.user = user
        self.isAuthenticated = isAuthenticated
        self.isLoading = isLoading
        self.error = error
        self.authMode = authMode
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
        self.displayName = displayName
        self.acceptsTerms = acceptsTerms
        self.isPasswordVisible = isPasswordVisible
        self.validationErrors = validationErrors
    }
    
    public static func == (lhs: AuthViewState, rhs: AuthViewState) -> Bool {
        lhs.user?.id == rhs.user?.id &&
        lhs.isAuthenticated == rhs.isAuthenticated &&
        lhs.isLoading == rhs.isLoading &&
        lhs.authMode == rhs.authMode &&
        lhs.email == rhs.email &&
        lhs.password == rhs.password &&
        lhs.confirmPassword == rhs.confirmPassword &&
        lhs.displayName == rhs.displayName &&
        lhs.acceptsTerms == rhs.acceptsTerms &&
        lhs.isPasswordVisible == rhs.isPasswordVisible &&
        lhs.validationErrors == rhs.validationErrors
    }
}

public enum AuthMode: Equatable {
    case signIn
    case signUp
    case resetPassword
}

public enum ValidationError: String, Equatable {
    case invalidEmail = "Invalid email address"
    case passwordTooShort = "Password must be at least 6 characters"
    case passwordsDontMatch = "Passwords don't match"
    case displayNameEmpty = "Display name is required"
    case termsNotAccepted = "You must accept the terms of service"
}

// MARK: - Authentication View Events
public enum AuthViewEvent {
    case updateEmail(String)
    case updatePassword(String)
    case updateConfirmPassword(String)
    case updateDisplayName(String)
    case togglePasswordVisibility
    case toggleTermsAcceptance
    case switchMode(AuthMode)
    case signIn
    case signInWithApple
    case signInWithGoogle
    case signUp
    case signOut
    case resetPassword
    case resendVerificationEmail
    case deleteAccount
}

// MARK: - String Email Validation Extension
public extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}