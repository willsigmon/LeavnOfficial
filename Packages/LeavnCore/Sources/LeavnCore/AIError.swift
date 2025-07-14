import Foundation

/// Errors specific to AI service operations
public enum AIError: LocalizedError, Sendable {
    case missingAPIKey
    case rateLimitExceeded
    case invalidResponse
    case serverError(Int)
    case requestFailed(Error)
    case decodingError(DecodingError)
    case timeout
    case invalidInput(String)
    
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is missing. Please configure a valid OpenAI API key."
        case .rateLimitExceeded:
            return "AI request rate limit exceeded. Please try again later."
        case .invalidResponse:
            return "Invalid response received from AI service."
        case .serverError(let code):
            return "AI service server error (HTTP \(code))."
        case .requestFailed(let error):
            return "AI request failed: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode AI response: \(error.localizedDescription)"
        case .timeout:
            return "AI request timed out. Please try again."
        case .invalidInput(let reason):
            return "Invalid input: \(reason)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .missingAPIKey:
            return "Add your OpenAI API key in the app settings."
        case .rateLimitExceeded:
            return "Wait a few minutes before making more requests."
        case .invalidResponse, .serverError, .decodingError:
            return "Try again or contact support if the problem persists."
        case .requestFailed, .timeout:
            return "Check your internet connection and try again."
        case .invalidInput:
            return "Modify your input and try again."
        }
    }
}