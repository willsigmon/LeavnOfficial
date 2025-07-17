import Foundation

// LeavnConfiguration, LeavnEnvironment, CacheConfiguration, and FeatureFlags are now defined in Configuration.swift to avoid duplication.

// MARK: - Core Protocols
public protocol LeavnModule {
    var identifier: String { get }
    func initialize(with configuration: LeavnConfiguration) async throws
    func cleanup() async
}

public protocol Injectable {}

public protocol UseCase {
    associatedtype Input
    associatedtype Output
    
    func execute(_ input: Input) async throws -> Output
}

public protocol Repository {}

public protocol DataSource {}

// MARK: - Core Errors
public enum LeavnError: LocalizedError {
    case networkError(underlying: Error?)
    case decodingError(underlying: Error)
    case unauthorized
    case notFound
    case serverError(message: String)
    case localStorageError(underlying: Error)
    case validationError(message: String)
    case invalidInput(String)
    case notImplemented(String)
    case systemError(String)
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error?.localizedDescription ?? "Unknown network error")"
        case .decodingError(let error):
            return "Data parsing error: \(error.localizedDescription)"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .serverError(let message):
            return "Server error: \(message)"
        case .localStorageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .notImplemented(let message):
            return "Not implemented: \(message)"
        case .systemError(let message):
            return "System error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Core Models
// User is now defined in Core/LeavnCore/Sources/LeavnCore/Models/User.swift

// MARK: - Core Extensions
public extension String {
    var isValidBibleReference: Bool {
        let pattern = #"^[1-3]?\s?[A-Za-z]+\s+\d+(:\d+(-\d+)?)?$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}

public extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url
    }
} 