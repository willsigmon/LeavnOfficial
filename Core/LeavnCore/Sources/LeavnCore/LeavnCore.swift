import Foundation

// MARK: - Core Types
public struct LeavnConfiguration: Sendable {
    public let apiKey: String
    public let environment: Environment
    public let baseURL: URL
    public let analyticsEnabled: Bool
    public let cacheConfiguration: CacheConfiguration
    
    // API Keys
    public let esvAPIKey: String
    public let bibleComAPIKey: String
    public let elevenLabsAPIKey: String
    
    // Feature Flags
    public let audioNarrationEnabled: Bool
    public let offlineModeEnabled: Bool
    public let hapticFeedbackEnabled: Bool
    
    // Feature Flags
    public let features: FeatureFlags
    
    public init(
        apiKey: String,
        environment: Environment = .production,
        baseURL: URL? = nil,
        analyticsEnabled: Bool = true,
        cacheConfiguration: CacheConfiguration = .default,
        esvAPIKey: String = "",
        bibleComAPIKey: String = "",
        elevenLabsAPIKey: String = "",
        audioNarrationEnabled: Bool = true,
        offlineModeEnabled: Bool = true,
        hapticFeedbackEnabled: Bool = true,
        features: FeatureFlags = .default
    ) {
        self.apiKey = apiKey
        self.environment = environment
        self.baseURL = baseURL ?? environment.defaultBaseURL
        self.analyticsEnabled = analyticsEnabled
        self.cacheConfiguration = cacheConfiguration
        self.esvAPIKey = esvAPIKey
        self.bibleComAPIKey = bibleComAPIKey
        self.elevenLabsAPIKey = elevenLabsAPIKey
        self.audioNarrationEnabled = audioNarrationEnabled
        self.offlineModeEnabled = offlineModeEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.features = features
    }
}

public enum Environment: Sendable {
    case development
    case staging
    case production
    
    var defaultBaseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://dev-api.leavn.app")!
        case .staging:
            return URL(string: "https://staging-api.leavn.app")!
        case .production:
            return URL(string: "https://api.leavn.app")!
        }
    }
}

public struct CacheConfiguration: Sendable {
    public let memoryCapacity: Int
    public let diskCapacity: Int
    public let diskPath: String?
    
    public static let `default` = CacheConfiguration(
        memoryCapacity: 10 * 1024 * 1024, // 10MB
        diskCapacity: 50 * 1024 * 1024, // 50MB
        diskPath: nil
    )
    
    public init(memoryCapacity: Int, diskCapacity: Int, diskPath: String?) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.diskPath = diskPath
    }
}

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
public struct User: Codable, Identifiable, Sendable {
    public let id: String
    public let email: String
    public let displayName: String
    public let photoURL: URL?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String,
        email: String,
        displayName: String,
        photoURL: URL? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

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