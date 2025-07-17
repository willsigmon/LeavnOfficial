import Foundation

// MARK: - Leavn Configuration
public struct LeavnConfiguration: Sendable {
    public let apiKey: String
    public let environment: LeavnEnvironment
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
        environment: LeavnEnvironment = .production,
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
    
    // Default configuration for the app
    public static let `default` = LeavnConfiguration(
        apiKey: "leavn-default-key",
        environment: .development,
        esvAPIKey: "",
        bibleComAPIKey: "",
        elevenLabsAPIKey: ""
    )
}

public enum LeavnEnvironment: Sendable {
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

// MARK: - Cache Configuration
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

// MARK: - Feature Flags
public struct FeatureFlags: Sendable {
    public let enableOfflineMode: Bool
    public let enableAudioBible: Bool
    public let enableAIInsights: Bool
    public let enableSocialSharing: Bool
    public let enableCommunityFeatures: Bool
    public let enableAdvancedSearch: Bool
    public let enableMultipleTranslations: Bool
    
    public init(
        enableOfflineMode: Bool = true,
        enableAudioBible: Bool = true,
        enableAIInsights: Bool = false,
        enableSocialSharing: Bool = true,
        enableCommunityFeatures: Bool = false,
        enableAdvancedSearch: Bool = true,
        enableMultipleTranslations: Bool = true
    ) {
        self.enableOfflineMode = enableOfflineMode
        self.enableAudioBible = enableAudioBible
        self.enableAIInsights = enableAIInsights
        self.enableSocialSharing = enableSocialSharing
        self.enableCommunityFeatures = enableCommunityFeatures
        self.enableAdvancedSearch = enableAdvancedSearch
        self.enableMultipleTranslations = enableMultipleTranslations
    }
    
    public static let `default` = FeatureFlags()
}

// MARK: - Convenience Initializers
public extension LeavnConfiguration {
    /// Development configuration with default values
    static var development: LeavnConfiguration {
        LeavnConfiguration(
            apiKey: "dev-api-key",
            environment: .development,
            audioNarrationEnabled: true,
            offlineModeEnabled: true,
            hapticFeedbackEnabled: true
        )
    }
    
    /// Staging configuration
    static var staging: LeavnConfiguration {
        LeavnConfiguration(
            apiKey: ProcessInfo.processInfo.environment["API_KEY"] ?? "staging-api-key",
            environment: .staging,
            esvAPIKey: ProcessInfo.processInfo.environment["ESV_API_KEY"] ?? "",
            bibleComAPIKey: ProcessInfo.processInfo.environment["BIBLE_COM_API_KEY"] ?? "",
            elevenLabsAPIKey: ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? ""
        )
    }
    
    /// Production configuration
    static var production: LeavnConfiguration {
        LeavnConfiguration(
            apiKey: ProcessInfo.processInfo.environment["API_KEY"] ?? "",
            environment: .production,
            esvAPIKey: ProcessInfo.processInfo.environment["ESV_API_KEY"] ?? "",
            bibleComAPIKey: ProcessInfo.processInfo.environment["BIBLE_COM_API_KEY"] ?? "",
            elevenLabsAPIKey: ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? "",
            audioNarrationEnabled: true,
            offlineModeEnabled: true,
            hapticFeedbackEnabled: true
        )
    }
}