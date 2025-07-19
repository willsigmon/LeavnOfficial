import Foundation
import Dependencies
import Security

// MARK: - Settings Service
@MainActor
public struct SettingsService: Sendable {
    // User Preferences
    public var getAppearanceSettings: @Sendable () async -> AppearanceSettings
    public var setAppearanceSettings: @Sendable (AppearanceSettings) async throws -> Void
    
    public var getBibleSettings: @Sendable () async -> BibleSettings
    public var setBibleSettings: @Sendable (BibleSettings) async throws -> Void
    
    public var getAudioSettings: @Sendable () async -> AudioSettings
    public var setAudioSettings: @Sendable (AudioSettings) async throws -> Void
    
    public var getNotificationSettings: @Sendable () async -> NotificationSettings
    public var setNotificationSettings: @Sendable (NotificationSettings) async throws -> Void
    
    // API Keys & Credentials
    public var getAPIKey: @Sendable (APIKeyType) async throws -> String?
    public var setAPIKey: @Sendable (APIKeyType, String) async throws -> Void
    public var deleteAPIKey: @Sendable (APIKeyType) async throws -> Void
    
    // Data Management
    public var exportData: @Sendable () async throws -> URL
    public var importData: @Sendable (URL) async throws -> Void
    public var clearAllData: @Sendable () async throws -> Void
    public var calculateStorageUsage: @Sendable () async throws -> StorageUsage
}

// MARK: - API Key Types
public enum APIKeyType: String, CaseIterable, Sendable {
    case esv = "esv_api_key"
    case elevenLabs = "elevenlabs_api_key"
    case openAI = "openai_api_key"
    
    var serviceName: String {
        switch self {
        case .esv: return "ESV Bible API"
        case .elevenLabs: return "ElevenLabs TTS"
        case .openAI: return "OpenAI"
        }
    }
}

// MARK: - Storage Usage
public struct StorageUsage: Equatable, Sendable {
    public let totalBytes: Int64
    public let audioBytes: Int64
    public let documentsBytes: Int64
    public let cacheBytes: Int64
    
    public var totalMB: Double {
        Double(totalBytes) / 1024 / 1024
    }
    
    public var audioMB: Double {
        Double(audioBytes) / 1024 / 1024
    }
    
    public var documentsMB: Double {
        Double(documentsBytes) / 1024 / 1024
    }
    
    public var cacheMB: Double {
        Double(cacheBytes) / 1024 / 1024
    }
}

// MARK: - Settings Models
public struct AppearanceSettings: Equatable, Codable, Sendable {
    public var theme: Theme
    public var accentColor: AccentColor
    public var useLargeFonts: Bool
    public var reduceTransparency: Bool
    
    public enum Theme: String, CaseIterable, Codable, Sendable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }
    
    public enum AccentColor: String, CaseIterable, Codable, Sendable {
        case blue = "Blue"
        case purple = "Purple"
        case green = "Green"
        case orange = "Orange"
        case pink = "Pink"
    }
    
    public init(
        theme: Theme = .system,
        accentColor: AccentColor = .blue,
        useLargeFonts: Bool = false,
        reduceTransparency: Bool = false
    ) {
        self.theme = theme
        self.accentColor = accentColor
        self.useLargeFonts = useLargeFonts
        self.reduceTransparency = reduceTransparency
    }
}

public struct BibleSettings: Equatable, Codable, Sendable {
    public var defaultTranslation: String
    public var fontSize: CGFloat
    public var lineSpacing: CGFloat
    public var showVerseNumbers: Bool
    public var showRedLetters: Bool
    public var continuousScrolling: Bool
    
    public init(
        defaultTranslation: String = "ESV",
        fontSize: CGFloat = 16,
        lineSpacing: CGFloat = 1.5,
        showVerseNumbers: Bool = true,
        showRedLetters: Bool = true,
        continuousScrolling: Bool = false
    ) {
        self.defaultTranslation = defaultTranslation
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.showVerseNumbers = showVerseNumbers
        self.showRedLetters = showRedLetters
        self.continuousScrolling = continuousScrolling
    }
}

public struct AudioSettings: Equatable, Codable, Sendable {
    public var defaultVoice: String
    public var playbackSpeed: Double
    public var autoPlayNext: Bool
    public var sleepTimer: SleepTimer?
    public var skipSilence: Bool
    
    public enum SleepTimer: String, CaseIterable, Codable, Sendable {
        case minutes15 = "15 minutes"
        case minutes30 = "30 minutes"
        case minutes45 = "45 minutes"
        case hour1 = "1 hour"
        case endOfChapter = "End of chapter"
    }
    
    public init(
        defaultVoice: String = "Rachel",
        playbackSpeed: Double = 1.0,
        autoPlayNext: Bool = true,
        sleepTimer: SleepTimer? = nil,
        skipSilence: Bool = false
    ) {
        self.defaultVoice = defaultVoice
        self.playbackSpeed = playbackSpeed
        self.autoPlayNext = autoPlayNext
        self.sleepTimer = sleepTimer
        self.skipSilence = skipSilence
    }
}

public struct NotificationSettings: Equatable, Codable, Sendable {
    public var dailyReminder: Bool
    public var reminderTime: Date
    public var prayerReminders: Bool
    public var communityUpdates: Bool
    public var readingPlanReminders: Bool
    
    public init(
        dailyReminder: Bool = false,
        reminderTime: Date = Date(),
        prayerReminders: Bool = true,
        communityUpdates: Bool = true,
        readingPlanReminders: Bool = true
    ) {
        self.dailyReminder = dailyReminder
        self.reminderTime = reminderTime
        self.prayerReminders = prayerReminders
        self.communityUpdates = communityUpdates
        self.readingPlanReminders = readingPlanReminders
    }
}

// MARK: - Keychain Manager
private struct KeychainManager {
    static let service = "com.leavn.app"
    
    static func save(key: String, value: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw SettingsError.keychainError(status)
        }
    }
    
    static func load(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw SettingsError.keychainError(status)
        }
        
        return string
    }
    
    static func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SettingsError.keychainError(status)
        }
    }
}

// MARK: - Dependency Implementation
extension SettingsService: DependencyKey {
    public static let liveValue = Self(
        getAppearanceSettings: {
            @Dependency(\.userDefaults) var userDefaults
            
            if let data = userDefaults.appearanceSettingsData,
               let settings = try? JSONDecoder().decode(AppearanceSettings.self, from: data) {
                return settings
            }
            return AppearanceSettings()
        },
        setAppearanceSettings: { settings in
            @Dependency(\.userDefaults) var userDefaults
            
            let data = try JSONEncoder().encode(settings)
            await userDefaults.setAppearanceSettingsData(data)
        },
        getBibleSettings: {
            @Dependency(\.userDefaults) var userDefaults
            
            if let data = userDefaults.bibleSettingsData,
               let settings = try? JSONDecoder().decode(BibleSettings.self, from: data) {
                return settings
            }
            return BibleSettings()
        },
        setBibleSettings: { settings in
            @Dependency(\.userDefaults) var userDefaults
            
            let data = try JSONEncoder().encode(settings)
            await userDefaults.setBibleSettingsData(data)
        },
        getAudioSettings: {
            @Dependency(\.userDefaults) var userDefaults
            
            if let data = userDefaults.audioSettingsData,
               let settings = try? JSONDecoder().decode(AudioSettings.self, from: data) {
                return settings
            }
            return AudioSettings()
        },
        setAudioSettings: { settings in
            @Dependency(\.userDefaults) var userDefaults
            
            let data = try JSONEncoder().encode(settings)
            await userDefaults.setAudioSettingsData(data)
        },
        getNotificationSettings: {
            @Dependency(\.userDefaults) var userDefaults
            
            if let data = userDefaults.notificationSettingsData,
               let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
                return settings
            }
            return NotificationSettings()
        },
        setNotificationSettings: { settings in
            @Dependency(\.userDefaults) var userDefaults
            
            let data = try JSONEncoder().encode(settings)
            await userDefaults.setNotificationSettingsData(data)
        },
        getAPIKey: { type in
            try KeychainManager.load(key: type.rawValue)
        },
        setAPIKey: { type, value in
            try KeychainManager.save(key: type.rawValue, value: value)
        },
        deleteAPIKey: { type in
            try KeychainManager.delete(key: type.rawValue)
        },
        exportData: {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportPath = documentsPath.appendingPathComponent("LeavnExport_\(Date().timeIntervalSince1970).json")
            
            // Gather all data
            let exportData = ExportData(
                version: 1,
                exportDate: Date(),
                bookmarks: [], // Would fetch from Core Data
                notes: [],
                highlights: [],
                settings: ExportData.Settings(
                    appearance: AppearanceSettings(),
                    bible: BibleSettings(),
                    audio: AudioSettings(),
                    notifications: NotificationSettings()
                )
            )
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(exportData)
            try data.write(to: exportPath)
            
            return exportPath
        },
        importData: { url in
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let importData = try decoder.decode(ExportData.self, from: data)
            
            // Import data into Core Data and settings
            // This would be implemented with proper Core Data operations
        },
        clearAllData: {
            @Dependency(\.libraryService) var libraryService
            
            // Clear Core Data
            // Clear UserDefaults
            // Clear Keychain
            // Clear Downloads
            
            // Reset to defaults
            @Dependency(\.userDefaults) var userDefaults
            await userDefaults.reset()
        },
        calculateStorageUsage: {
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let cachesPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            
            func sizeOfDirectory(at url: URL) -> Int64 {
                var size: Int64 = 0
                
                if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
                    for case let fileURL as URL in enumerator {
                        if let attributes = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                           let fileSize = attributes.fileSize {
                            size += Int64(fileSize)
                        }
                    }
                }
                
                return size
            }
            
            let audioPath = documentsPath.appendingPathComponent("Audio")
            
            return StorageUsage(
                totalBytes: sizeOfDirectory(at: documentsPath) + sizeOfDirectory(at: cachesPath),
                audioBytes: sizeOfDirectory(at: audioPath),
                documentsBytes: sizeOfDirectory(at: documentsPath),
                cacheBytes: sizeOfDirectory(at: cachesPath)
            )
        }
    )
    
    public static let testValue = Self(
        getAppearanceSettings: { AppearanceSettings() },
        setAppearanceSettings: { _ in },
        getBibleSettings: { BibleSettings() },
        setBibleSettings: { _ in },
        getAudioSettings: { AudioSettings() },
        setAudioSettings: { _ in },
        getNotificationSettings: { NotificationSettings() },
        setNotificationSettings: { _ in },
        getAPIKey: { _ in "test-key" },
        setAPIKey: { _, _ in },
        deleteAPIKey: { _ in },
        exportData: { 
            let tempDir = FileManager.default.temporaryDirectory
            return tempDir.appendingPathComponent("test-export.json")
        },
        importData: { _ in },
        clearAllData: { },
        calculateStorageUsage: {
            StorageUsage(
                totalBytes: 1024 * 1024 * 100,
                audioBytes: 1024 * 1024 * 50,
                documentsBytes: 1024 * 1024 * 30,
                cacheBytes: 1024 * 1024 * 20
            )
        }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var settingsService: SettingsService {
        get { self[SettingsService.self] }
        set { self[SettingsService.self] = newValue }
    }
}

// MARK: - Export Data Model
private struct ExportData: Codable {
    let version: Int
    let exportDate: Date
    let bookmarks: [Bookmark]
    let notes: [Note]
    let highlights: [Highlight]
    let settings: Settings
    
    struct Settings: Codable {
        let appearance: AppearanceSettings
        let bible: BibleSettings
        let audio: AudioSettings
        let notifications: NotificationSettings
    }
}

// MARK: - Settings Errors
enum SettingsError: LocalizedError {
    case keychainError(OSStatus)
    case exportFailed(String)
    case importFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .importFailed(let reason):
            return "Import failed: \(reason)"
        }
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaultsClient {
    var appearanceSettingsData: Data? {
        data(forKey: "appearanceSettings")
    }
    
    func setAppearanceSettingsData(_ data: Data) async {
        await set(data, forKey: "appearanceSettings")
    }
    
    var bibleSettingsData: Data? {
        data(forKey: "bibleSettings")
    }
    
    func setBibleSettingsData(_ data: Data) async {
        await set(data, forKey: "bibleSettings")
    }
    
    var audioSettingsData: Data? {
        data(forKey: "audioSettings")
    }
    
    func setAudioSettingsData(_ data: Data) async {
        await set(data, forKey: "audioSettings")
    }
    
    var notificationSettingsData: Data? {
        data(forKey: "notificationSettings")
    }
    
    func setNotificationSettingsData(_ data: Data) async {
        await set(data, forKey: "notificationSettings")
    }
}