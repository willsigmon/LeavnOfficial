import Foundation
import LeavnCore

// MARK: - Authentication Module-Specific Models
// All shared authentication types are imported from LeavnCore

// MARK: - Social Authentication Models
public struct GoogleAuthResult {
    public let idToken: String
    public let accessToken: String?
    public let email: String
    public let displayName: String?
    public let photoURL: URL?
    
    public init(
        idToken: String,
        accessToken: String? = nil,
        email: String,
        displayName: String? = nil,
        photoURL: URL? = nil
    ) {
        self.idToken = idToken
        self.accessToken = accessToken
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
    }
}

public struct FacebookAuthResult {
    public let accessToken: String
    public let userId: String
    public let email: String?
    public let displayName: String?
    public let photoURL: URL?
    
    public init(
        accessToken: String,
        userId: String,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil
    ) {
        self.accessToken = accessToken
        self.userId = userId
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
    }
}

// MARK: - Authentication Error Extensions
public enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case networkError
    case emailNotVerified
    case tooManyRequests
    case operationNotAllowed
    case invalidEmail
    case userDisabled
    case expiredActionCode
    case invalidActionCode
    case wrongPassword
    case credentialAlreadyInUse
    case requiresRecentLogin
    case providerAlreadyLinked
    case noSuchProvider
    case invalidUserToken
    case userTokenExpired
    case invalidAPIKey
    case appNotAuthorized
    case keychainError
    case internalError
    case customTokenMismatch
    case invalidCustomToken
    case customTokenExpired
    case invalidMessagePayload
    case invalidSender
    case invalidRecipientEmail
    case missingEmail
    case missingPassword
    case missingDisplayName
    case sessionExpired
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .weakPassword:
            return "Password is too weak"
        case .userNotFound:
            return "No account found with this email"
        case .networkError:
            return "Network connection error"
        case .emailNotVerified:
            return "Please verify your email before signing in"
        case .tooManyRequests:
            return "Too many attempts. Please try again later"
        case .operationNotAllowed:
            return "This operation is not allowed"
        case .invalidEmail:
            return "Invalid email address"
        case .userDisabled:
            return "This account has been disabled"
        case .expiredActionCode:
            return "This link has expired"
        case .invalidActionCode:
            return "Invalid verification code"
        case .wrongPassword:
            return "Incorrect password"
        case .credentialAlreadyInUse:
            return "This credential is already associated with another account"
        case .requiresRecentLogin:
            return "Please sign in again to continue"
        case .providerAlreadyLinked:
            return "This provider is already linked to your account"
        case .noSuchProvider:
            return "This provider is not linked to your account"
        case .invalidUserToken:
            return "Invalid authentication token"
        case .userTokenExpired:
            return "Your session has expired. Please sign in again"
        case .invalidAPIKey:
            return "Invalid API key"
        case .appNotAuthorized:
            return "This app is not authorized"
        case .keychainError:
            return "Error accessing secure storage"
        case .internalError:
            return "An internal error occurred"
        case .customTokenMismatch:
            return "Token mismatch error"
        case .invalidCustomToken:
            return "Invalid custom token"
        case .customTokenExpired:
            return "Custom token has expired"
        case .invalidMessagePayload:
            return "Invalid message payload"
        case .invalidSender:
            return "Invalid sender"
        case .invalidRecipientEmail:
            return "Invalid recipient email"
        case .missingEmail:
            return "Email is required"
        case .missingPassword:
            return "Password is required"
        case .missingDisplayName:
            return "Display name is required"
        case .sessionExpired:
            return "Your session has expired"
        case .cancelled:
            return "Operation was cancelled"
        }
    }
}

// MARK: - Authentication Configuration
public struct AuthenticationConfiguration {
    public let enableBiometrics: Bool
    public let enableSocialLogin: Bool
    public let enableEmailVerification: Bool
    public let sessionTimeout: TimeInterval
    public let maxLoginAttempts: Int
    public let passwordMinLength: Int
    public let passwordRequireUppercase: Bool
    public let passwordRequireNumbers: Bool
    public let passwordRequireSpecialChars: Bool
    
    public init(
        enableBiometrics: Bool = true,
        enableSocialLogin: Bool = true,
        enableEmailVerification: Bool = true,
        sessionTimeout: TimeInterval = 3600,
        maxLoginAttempts: Int = 5,
        passwordMinLength: Int = 6,
        passwordRequireUppercase: Bool = false,
        passwordRequireNumbers: Bool = false,
        passwordRequireSpecialChars: Bool = false
    ) {
        self.enableBiometrics = enableBiometrics
        self.enableSocialLogin = enableSocialLogin
        self.enableEmailVerification = enableEmailVerification
        self.sessionTimeout = sessionTimeout
        self.maxLoginAttempts = maxLoginAttempts
        self.passwordMinLength = passwordMinLength
        self.passwordRequireUppercase = passwordRequireUppercase
        self.passwordRequireNumbers = passwordRequireNumbers
        self.passwordRequireSpecialChars = passwordRequireSpecialChars
    }
    
    public static let `default` = AuthenticationConfiguration()
}