import Foundation

public enum AppConfiguration {
    
    // MARK: - API Configuration
    public struct API {
        public static let baseURL = "https://api.getbible.net/v2"
        public static let timeout: TimeInterval = 30
        public static let maxRetries = 3
        
        public struct Headers {
            public static let userAgent = "Leavn/1.0 (iOS)"
            public static let acceptLanguage = "en-US"
        }
    }
    
    // MARK: - Cache Configuration
    public struct Cache {
        public static let maxMemoryCacheSizeMB = 50
        public static let maxDiskCacheSizeMB = 500
        public static let cacheExpirationDays = 30
        public static let offlineContentLimitMB = 1000
    }
    
    // MARK: - Sync Configuration
    public struct Sync {
        public static let syncIntervalMinutes = 15
        public static let backgroundSyncEnabled = true
        public static let wifiOnlySync = false
        public static let maxConcurrentSyncs = 3
    }
    
    // MARK: - Analytics Configuration
    public struct Analytics {
        public static let enabled = true
        public static let debugLoggingEnabled = false
        public static let sessionTimeout: TimeInterval = 1800 // 30 minutes
        public static let batchSize = 20
    }
    
    // MARK: - Feature Flags
    public struct Features {
        public static let communityEnabled = true
        public static let aiSuggestionsEnabled = true
        public static let offlineReadingEnabled = true
        public static let crossReferenceEnabled = true
        public static let advancedSearchEnabled = true
        public static let multiTranslationEnabled = true
        public static let audioNarrationsEnabled = true
        public static let studyNotesEnabled = true
    }
    
    // MARK: - Platform Specific
    #if os(iOS)
    public struct IOS {
        public static let minimumFontScale: CGFloat = 0.5
        public static let maximumFontScale: CGFloat = 2.0
        public static let hapticFeedbackEnabled = true
        public static let parallaxEffectEnabled = true
    }
    #endif
    
    #if os(macOS)
    public struct MacOS {
        public static let defaultWindowWidth: CGFloat = 1200
        public static let defaultWindowHeight: CGFloat = 800
        public static let minimumWindowWidth: CGFloat = 800
        public static let minimumWindowHeight: CGFloat = 600
    }
    #endif
    
    #if os(visionOS)
    public struct VisionOS {
        public static let defaultVolumeSize = CGSize(width: 800, height: 600)
        public static let immersiveSpaceEnabled = true
        public static let handTrackingEnabled = true
        public static let spatialAudioEnabled = true
    }
    #endif
    
    #if os(watchOS)
    public struct WatchOS {
        public static let complicationUpdateInterval: TimeInterval = 3600 // 1 hour
        public static let quickVersesCount = 5
        public static let hapticResponseEnabled = true
    }
    #endif
    
    #if os(tvOS)
    public struct TVOS {
        public static let defaultWindowSize = CGSize(width: 1920, height: 1080)
        public static let focusAnimationDuration: TimeInterval = 0.3
        public static let maxFocusableItems = 20
        public static let parallaxEffectEnabled = true
    }
    #endif
    
    // MARK: - Environment
    public enum Environment: String {
        case development
        case staging
        case production
        
        public static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }
    
    // MARK: - Build Info
    public struct BuildInfo {
        public static var version: String {
            if let versionValue = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
                // Handle both String and NSNumber cases
                if let stringValue = versionValue as? String {
                    return stringValue
                } else if let numberValue = versionValue as? NSNumber {
                    return numberValue.stringValue
                }
            }
            return "1.0"
        }
        
        public static var buildNumber: String {
            if let buildValue = Bundle.main.infoDictionary?["CFBundleVersion"] {
                // Handle both String and NSNumber cases
                if let stringValue = buildValue as? String {
                    return stringValue
                } else if let numberValue = buildValue as? NSNumber {
                    return numberValue.stringValue
                }
            }
            return "1"
        }
        
        public static var bundleIdentifier: String {
            Bundle.main.bundleIdentifier ?? "com.leavn.app"
        }
    }
    

}

// MARK: - UserDefaults Keys
public extension UserDefaults {
    enum Keys: String {
        case selectedTranslation
        case fontSize
        case darkModeEnabled
        case lastSyncDate
        case onboardingCompleted
        case notificationsEnabled
        case selectedBook
        case selectedChapter
        case readingHistory
        case bookmarks
        case highlights
        case studyNotes
        case preferredLanguage
        case autoPlayAudio
        case readingPlan
        case dailyVerseEnabled
    }
    
    func value<T>(for key: Keys, default defaultValue: T) -> T {
        return object(forKey: key.rawValue) as? T ?? defaultValue
    }
    
    func setValue<T>(_ value: T?, for key: Keys) {
        set(value, forKey: key.rawValue)
    }
}
