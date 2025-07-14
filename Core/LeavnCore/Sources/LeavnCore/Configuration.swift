import Foundation

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