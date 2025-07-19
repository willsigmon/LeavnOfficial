import Foundation

public enum AppError: LocalizedError, Equatable {
    // Network Errors
    case network(NetworkError)
    case noInternetConnection
    case requestTimeout
    case serverUnavailable
    
    // Authentication Errors
    case notAuthenticated
    case authenticationFailed(String?)
    case sessionExpired
    case invalidCredentials
    
    // Data Errors
    case dataNotFound
    case dataCorrupted
    case decodingFailed(String)
    case encodingFailed(String)
    
    // Storage Errors
    case storageFull
    case fileNotFound(String)
    case fileAccessDenied(String)
    case coreDataError(String)
    
    // API Errors
    case apiKeyMissing(String)
    case apiRateLimited
    case apiQuotaExceeded
    case invalidAPIResponse
    
    // Audio Errors
    case audioStreamingFailed
    case audioDownloadFailed
    case audioPlaybackFailed(String)
    case voiceNotAvailable
    
    // Content Errors
    case contentUnavailable
    case contentFormatUnsupported
    case translationNotAvailable(String)
    
    // User Errors
    case invalidInput(String)
    case operationCancelled
    case featureNotAvailable
    case subscriptionRequired
    
    // System Errors
    case unknown(Error?)
    case internalError(String)
    
    public var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .noInternetConnection:
            return "No internet connection available"
        case .requestTimeout:
            return "Request timed out"
        case .serverUnavailable:
            return "Server is currently unavailable"
            
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .authenticationFailed(let message):
            return message ?? "Authentication failed"
        case .sessionExpired:
            return "Your session has expired. Please log in again"
        case .invalidCredentials:
            return "Invalid username or password"
            
        case .dataNotFound:
            return "Requested data not found"
        case .dataCorrupted:
            return "Data appears to be corrupted"
        case .decodingFailed(let type):
            return "Failed to decode \(type)"
        case .encodingFailed(let type):
            return "Failed to encode \(type)"
            
        case .storageFull:
            return "Device storage is full"
        case .fileNotFound(let filename):
            return "File not found: \(filename)"
        case .fileAccessDenied(let filename):
            return "Access denied: \(filename)"
        case .coreDataError(let message):
            return "Database error: \(message)"
            
        case .apiKeyMissing(let service):
            return "\(service) API key is missing"
        case .apiRateLimited:
            return "API rate limit exceeded. Please try again later"
        case .apiQuotaExceeded:
            return "API quota exceeded"
        case .invalidAPIResponse:
            return "Invalid response from server"
            
        case .audioStreamingFailed:
            return "Failed to stream audio"
        case .audioDownloadFailed:
            return "Failed to download audio"
        case .audioPlaybackFailed(let reason):
            return "Audio playback failed: \(reason)"
        case .voiceNotAvailable:
            return "Selected voice is not available"
            
        case .contentUnavailable:
            return "Content is not available"
        case .contentFormatUnsupported:
            return "Content format is not supported"
        case .translationNotAvailable(let translation):
            return "Translation '\(translation)' is not available"
            
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .operationCancelled:
            return "Operation was cancelled"
        case .featureNotAvailable:
            return "This feature is not available"
        case .subscriptionRequired:
            return "A subscription is required for this feature"
            
        case .unknown(let error):
            return error?.localizedDescription ?? "An unknown error occurred"
        case .internalError(let message):
            return "Internal error: \(message)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Check your internet connection and try again"
        case .sessionExpired, .notAuthenticated:
            return "Please log in to continue"
        case .storageFull:
            return "Free up some space on your device"
        case .apiRateLimited:
            return "Wait a few minutes before trying again"
        case .apiKeyMissing:
            return "Configure the required API keys in settings"
        case .subscriptionRequired:
            return "Upgrade to a premium subscription"
        default:
            return nil
        }
    }
    
    public var isRetryable: Bool {
        switch self {
        case .network, .noInternetConnection, .requestTimeout, .serverUnavailable,
             .apiRateLimited, .audioStreamingFailed, .audioDownloadFailed:
            return true
        default:
            return false
        }
    }
}

extension AppError {
    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.network(let a), .network(let b)):
            return a.localizedDescription == b.localizedDescription
        case (.authenticationFailed(let a), .authenticationFailed(let b)):
            return a == b
        case (.decodingFailed(let a), .decodingFailed(let b)):
            return a == b
        case (.encodingFailed(let a), .encodingFailed(let b)):
            return a == b
        case (.fileNotFound(let a), .fileNotFound(let b)):
            return a == b
        case (.fileAccessDenied(let a), .fileAccessDenied(let b)):
            return a == b
        case (.coreDataError(let a), .coreDataError(let b)):
            return a == b
        case (.apiKeyMissing(let a), .apiKeyMissing(let b)):
            return a == b
        case (.audioPlaybackFailed(let a), .audioPlaybackFailed(let b)):
            return a == b
        case (.translationNotAvailable(let a), .translationNotAvailable(let b)):
            return a == b
        case (.invalidInput(let a), .invalidInput(let b)):
            return a == b
        case (.internalError(let a), .internalError(let b)):
            return a == b
        case (.unknown, .unknown):
            return true
        default:
            return lhs.errorDescription == rhs.errorDescription
        }
    }
}