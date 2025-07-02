import Foundation


public enum LeavnError: LocalizedError, Sendable {
    case networkError(underlying: Error)
    case cacheError(underlying: Error)
    case authenticationError(reason: AuthErrorReason)
    case dataError(reason: DataErrorReason)
    case syncError(reason: SyncErrorReason)
    case validationError(field: String, reason: String)
    case notSupported(_ message: String)
    case aiError(message: String)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .authenticationError(let reason):
            return reason.description
        case .dataError(let reason):
            return reason.description
        case .syncError(let reason):
            return reason.description
        case .validationError(let field, let reason):
            return "\(field): \(reason)"
        case .notSupported(let message):
            return "Not supported: \(message)"
        case .aiError(let message):
            return "AI error: \(message)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .cacheError:
            return "Try clearing the app cache in Settings."
        case .authenticationError:
            return "Please sign in again to continue."
        case .dataError:
            return "The data appears to be corrupted. Try refreshing."
        case .syncError:
            return "Sync will retry automatically when connection improves."
        case .validationError:
            return "Please correct the error and try again."
        case .notSupported:
            return "This feature is not available on your device or OS version."
        case .aiError:
            return "The AI service is temporarily unavailable. Please try again later."
        case .unknown:
            return "Please try again. If the problem persists, contact support."
        }
    }
}

public enum AuthErrorReason: Sendable {
    case invalidCredentials
    case tokenExpired
    case userNotFound
    case accountLocked
    case networkUnavailable
    
    var description: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .tokenExpired:
            return "Your session has expired"
        case .userNotFound:
            return "User account not found"
        case .accountLocked:
            return "Account has been locked"
        case .networkUnavailable:
            return "Cannot authenticate offline"
        }
    }
}

public enum DataErrorReason: Sendable {
    case notFound
    case corrupted
    case incompatibleVersion
    case insufficientStorage
    
    var description: String {
        switch self {
        case .notFound:
            return "The requested data was not found"
        case .corrupted:
            return "The data appears to be corrupted"
        case .incompatibleVersion:
            return "This data format is not supported"
        case .insufficientStorage:
            return "Not enough storage space available"
        }
    }
}

public enum SyncErrorReason: Sendable {
    case conflict
    case quotaExceeded
    case serverError
    case rateLimited
    
    var description: String {
        switch self {
        case .conflict:
            return "Sync conflict detected"
        case .quotaExceeded:
            return "Storage quota exceeded"
        case .serverError:
            return "Server sync error"
        case .rateLimited:
            return "Too many sync requests"
        }
    }
}

// MARK: - Error Handling Extensions
public extension Error {
    var asLeavnError: LeavnError {
        if let leavnError = self as? LeavnError {
            return leavnError
        }
        
        // Convert common errors
        if let urlError = self as? URLError {
            return .networkError(underlying: urlError)
        }
        
        return .unknown(self)
    }
}
