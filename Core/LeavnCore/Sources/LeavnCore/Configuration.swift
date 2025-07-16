import Foundation

// MARK: - Leavn Configuration
public struct LeavnConfiguration: Sendable {
    public let apiKey: String?
    public let environment: Environment
    public let esvAPIKey: String?
    public let bibleComAPIKey: String?
    public let elevenLabsAPIKey: String?
    public let audioNarrationEnabled: Bool
    public let offlineModeEnabled: Bool
    public let hapticFeedbackEnabled: Bool
    
    public enum Environment: String, Sendable {
        case development
        case staging
        case production
    }
    
    public init(
        apiKey: String? = nil,
        environment: Environment = .production,
        esvAPIKey: String? = nil,
        bibleComAPIKey: String? = nil,
        elevenLabsAPIKey: String? = nil,
        audioNarrationEnabled: Bool = true,
        offlineModeEnabled: Bool = true,
        hapticFeedbackEnabled: Bool = true
    ) {
        self.apiKey = apiKey
        self.environment = environment
        self.esvAPIKey = esvAPIKey
        self.bibleComAPIKey = bibleComAPIKey
        self.elevenLabsAPIKey = elevenLabsAPIKey
        self.audioNarrationEnabled = audioNarrationEnabled
        self.offlineModeEnabled = offlineModeEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
    }
    
    public static let `default` = LeavnConfiguration()
}

// MARK: - Cache Configuration
public struct CacheConfiguration: Sendable {
    public let maxAge: TimeInterval
    public let maxSize: Int
    public let diskCacheEnabled: Bool
    public let memoryCacheEnabled: Bool
    
    public init(
        maxAge: TimeInterval = 3600, // 1 hour
        maxSize: Int = 50 * 1024 * 1024, // 50MB
        diskCacheEnabled: Bool = true,
        memoryCacheEnabled: Bool = true
    ) {
        self.maxAge = maxAge
        self.maxSize = maxSize
        self.diskCacheEnabled = diskCacheEnabled
        self.memoryCacheEnabled = memoryCacheEnabled
    }
    
    public static let `default` = CacheConfiguration()
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