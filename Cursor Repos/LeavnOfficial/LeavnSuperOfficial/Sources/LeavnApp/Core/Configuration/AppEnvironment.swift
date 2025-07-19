import Foundation

enum AppEnvironment {
    case development
    case staging
    case production
    
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        // Check for TestFlight
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return .staging
        } else {
            return .production
        }
        #endif
    }
    
    // MARK: - API Endpoints
    var apiBaseURL: URL {
        switch self {
        case .development:
            return URL(string: "http://localhost:8080/api/v1")!
        case .staging:
            return URL(string: "https://staging-api.leavn.app/api/v1")!
        case .production:
            return URL(string: "https://api.leavn.app/api/v1")!
        }
    }
    
    var webSocketURL: URL {
        switch self {
        case .development:
            return URL(string: "ws://localhost:8080/ws")!
        case .staging:
            return URL(string: "wss://staging-api.leavn.app/ws")!
        case .production:
            return URL(string: "wss://api.leavn.app/ws")!
        }
    }
    
    var esvAPIBaseURL: URL {
        return URL(string: "https://api.esv.org/v3")!
    }
    
    var elevenLabsAPIBaseURL: URL {
        return URL(string: "https://api.elevenlabs.io/v1")!
    }
    
    // MARK: - Feature Flags
    var isAudioEnabled: Bool {
        switch self {
        case .development:
            return true
        case .staging:
            return true
        case .production:
            return true
        }
    }
    
    var isCommunityEnabled: Bool {
        switch self {
        case .development:
            return true
        case .staging:
            return true
        case .production:
            return true
        }
    }
    
    var isOfflineEnabled: Bool {
        return true // Always enabled
    }
    
    var isAISearchEnabled: Bool {
        switch self {
        case .development:
            return true
        case .staging:
            return true
        case .production:
            return false // Enable when ready
        }
    }
    
    var isPrayerWallEnabled: Bool {
        switch self {
        case .development:
            return true
        case .staging:
            return true
        case .production:
            return true
        }
    }
    
    // MARK: - Analytics
    var analyticsEnabled: Bool {
        switch self {
        case .development:
            return false
        case .staging:
            return true
        case .production:
            return true
        }
    }
    
    // MARK: - API Keys
    // These should be loaded from secure configuration
    var defaultESVAPIKey: String? {
        // In production, this should come from server or secure config
        return nil
    }
    
    var defaultElevenLabsAPIKey: String? {
        // In production, this should come from server or secure config
        return nil
    }
}

// MARK: - Feature Flags
struct FeatureFlags {
    static let environment = AppEnvironment.current
    
    static var isAudioEnabled: Bool { environment.isAudioEnabled }
    static var isCommunityEnabled: Bool { environment.isCommunityEnabled }
    static var isOfflineEnabled: Bool { environment.isOfflineEnabled }
    static var isAISearchEnabled: Bool { environment.isAISearchEnabled }
    static var isPrayerWallEnabled: Bool { environment.isPrayerWallEnabled }
    static var analyticsEnabled: Bool { environment.analyticsEnabled }
}

// MARK: - Configuration
struct AppConfiguration {
    static let environment = AppEnvironment.current
    
    static var apiBaseURL: URL { environment.apiBaseURL }
    static var webSocketURL: URL { environment.webSocketURL }
    static var esvAPIBaseURL: URL { environment.esvAPIBaseURL }
    static var elevenLabsAPIBaseURL: URL { environment.elevenLabsAPIBaseURL }
    
    // Bundle Information
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "com.leavn.app"
    }
    
    // User Agent for API calls
    static var userAgent: String {
        "Leavn/\(appVersion) (iOS; Build \(buildNumber))"
    }
}