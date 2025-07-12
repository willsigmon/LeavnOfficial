import Foundation
import LeavnCore
import CloudKit

// MARK: - Secret Manager

/// A centralized manager for handling API keys and other secrets.
public enum SecretManager {
    
    /// An enumeration of the secret keys used throughout the application.
    public enum Key: String {
        case openAI = "OPENAI_API_KEY"
        case anthropic = "ANTHROPIC_API_KEY"
        case elevenLabs = "ELEVENLABS_API_KEY"
    }
    
    /// Retrieves a secret value from the process environment variables.
    ///
    /// This is the recommended approach for providing secrets during development.
    /// To set an environment variable, run the following command in your terminal
    /// before launching Xcode:
    ///
    /// `export OPENAI_API_KEY="your_api_key_here"`
    ///
    /// - Parameter key: The secret key to retrieve.
    /// - Returns: The secret value, or `nil` if not found.
    public static func get(_ key: Key) -> String? {
        // First try environment variable (for development)
        if let envKey = ProcessInfo.processInfo.environment[key.rawValue], !envKey.isEmpty {
            return envKey
        }
        
        // Then try keychain (for production)
        if let keychainKey = KeychainHelper.getAPIKey(for: key.rawValue.lowercased()) {
            return keychainKey
        }
        
        // Finally try UserDefaults (for testing - not secure)
        if let userDefaultsKey = UserDefaults.standard.string(forKey: "\(key.rawValue.lowercased())_api_key"), !userDefaultsKey.isEmpty {
            return userDefaultsKey
        }
        
        return nil
    }

    /// Sets a secret value securely in the Keychain.
    /// - Parameters:
    ///   - key: The secret key to set.
    ///   - value: The secret value to store.
    public static func set(_ key: Key, value: String) {
        KeychainHelper.setAPIKey(value, for: key.rawValue.lowercased())
    }
}

// MARK: - App Configuration

public struct AppConfiguration {
    // MARK: - API Keys
    public struct APIKeys {
        // GetBible API doesn't require authentication
        public static let getBibleBaseURL = "https://bible-api.com"
        
        // AI Service Keys - Load from environment or keychain for security
        public static var openAIKey: String {
            SecretManager.get(.openAI) ?? ""
        }
        
        public static var anthropicKey: String {
            SecretManager.get(.anthropic) ?? ""
        }
        
        public static var elevenLabsKey: String {
            SecretManager.get(.elevenLabs) ?? ""
        }
        
        // Helper method to set API keys securely
        public static func setOpenAIKey(_ key: String) {
            SecretManager.set(.openAI, value: key)
        }
        
        public static func setAnthropicKey(_ key: String) {
            SecretManager.set(.anthropic, value: key)
        }
        
        public static func setElevenLabsKey(_ key: String) {
            SecretManager.set(.elevenLabs, value: key)
        }
    }
    
    // MARK: - CloudKit Configuration
    public struct CloudKit {
        public static let containerIdentifier = "iCloud.com.yourcompany.leavn"
        
        // Record Types
        public static let bookmarkRecordType = "Bookmark"
        public static let userProfileRecordType = "UserProfile"
        public static let readingHistoryRecordType = "ReadingHistory"
        
        // Zone Names
        public static let privateZoneName = "UserDataZone"
        
        // Subscription IDs
        public static let bookmarkSubscriptionID = "bookmark-changes"
        public static let profileSubscriptionID = "profile-changes"
    }
    
    // MARK: - App Settings
    public struct Settings {
        public static let defaultTranslation = BibleTranslation(
            abbreviation: "ESV",
            name: "English Standard Version",
            language: "English",
            languageCode: "en"
        )
        public static let cacheExpirationDays = 30
        public static let maxCacheSizeMB = 500
        public static let preloadChapterCount = 2
        public static let searchResultLimit = 100
        public static let readingHistoryLimit = 50
    }
    
    // MARK: - Feature Flags
    public struct Features {
        public static var isAIEnabled: Bool {
            #if DEBUG
            return true
            #else
            return !APIKeys.openAIKey.isEmpty || !APIKeys.anthropicKey.isEmpty
            #endif
        }
        
        public static let isOfflineModeEnabled = true
        public static let isCloudSyncEnabled = true
        public static let isAdvancedSearchEnabled = true
        public static let isReadingPlansEnabled = true
    }
    
    // MARK: - Debug Settings
    public struct Debug {
        public static let useMockServices = ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] == "true"
        public static let verboseLogging = ProcessInfo.processInfo.environment["VERBOSE_LOGGING"] == "true"
        public static let clearCacheOnLaunch = ProcessInfo.processInfo.environment["CLEAR_CACHE"] == "true"
    }
}

// MARK: - CloudKit Setup Helper

public class CloudKitSetup {
    public static func configureContainer() -> CKContainer {
        return CKContainer(identifier: AppConfiguration.CloudKit.containerIdentifier)
    }
    
    public static func setupSubscriptions(in container: CKContainer) async throws {
        let privateDB = container.privateCloudDatabase
        
        // Check if subscriptions already exist
        do {
            let existingSubscriptions = try await privateDB.allSubscriptions()
            let existingIDs = existingSubscriptions.map { $0.subscriptionID }
            
            // Create bookmark subscription if needed
            if !existingIDs.contains(AppConfiguration.CloudKit.bookmarkSubscriptionID) {
                let bookmarkSubscription = CKQuerySubscription(
                    recordType: AppConfiguration.CloudKit.bookmarkRecordType,
                    predicate: NSPredicate(value: true),
                    subscriptionID: AppConfiguration.CloudKit.bookmarkSubscriptionID,
                    options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
                )
                
                let notificationInfo = CKSubscription.NotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                bookmarkSubscription.notificationInfo = notificationInfo
                
                try await privateDB.save(bookmarkSubscription)
            }
            
            // Create profile subscription if needed
            if !existingIDs.contains(AppConfiguration.CloudKit.profileSubscriptionID) {
                let profileSubscription = CKQuerySubscription(
                    recordType: AppConfiguration.CloudKit.userProfileRecordType,
                    predicate: NSPredicate(value: true),
                    subscriptionID: AppConfiguration.CloudKit.profileSubscriptionID,
                    options: [.firesOnRecordCreation, .firesOnRecordUpdate]
                )
                
                let notificationInfo = CKSubscription.NotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                profileSubscription.notificationInfo = notificationInfo
                
                try await privateDB.save(profileSubscription)
            }
        } catch {
            print("Failed to setup CloudKit subscriptions: \(error)")
            throw error
        }
    }
}

// MARK: - Environment Configuration

public extension ProcessInfo {
    static func setupEnvironment() {
        // This would be called early in app startup to configure environment
        // In production, you'd load these from a secure configuration file
        
        #if DEBUG
        // Set debug environment variables if not already set
        if processInfo.environment["USE_MOCK_SERVICES"] == nil {
            // Default to real services even in debug
            setenv("USE_MOCK_SERVICES", "false", 1)
        }
        
        if processInfo.environment["VERBOSE_LOGGING"] == nil {
            setenv("VERBOSE_LOGGING", "true", 1)
        }
        #endif
    }
}
