import Foundation
import CoreData

// MARK: - Default Settings Repository
public final class DefaultSettingsRepository: SettingsRepositoryProtocol {
    private let context: NSManagedObjectContext
    private let localStorage: SettingsLocalStorage
    private let secureStorage: SettingsSecureStorage
    
    public init(
        context: NSManagedObjectContext,
        localStorage: SettingsLocalStorage,
        secureStorage: SettingsSecureStorage
    ) {
        self.context = context
        self.localStorage = localStorage
        self.secureStorage = secureStorage
    }
    
    public func getSettings() async throws -> AppSettings {
        // Try to load from local storage first
        if let settings = try await localStorage.loadAppSettings() {
            return settings
        }
        
        // Return default settings if none exist
        return AppSettings()
    }
    
    public func updateSettings(_ settings: AppSettings) async throws {
        // Track the change
        let event = SettingsChangeEvent(
            setting: "all_settings",
            oldValue: try? await getSettings(),
            newValue: settings
        )
        
        // Save to local storage
        try await localStorage.saveAppSettings(settings)
        
        // Track change event
        try await localStorage.trackSettingChange(event)
        
        // Save sensitive data to secure storage if needed
        // Note: AppSettings doesn't have apiKeys property yet
        // This would be added when API key management is implemented
    }
    
    public func updateSetting<T: Codable>(key: String, value: T) async throws {
        // Get current settings
        var settings = try await getSettings()
        
        // Track the change
        let oldValue = try? await localStorage.getSetting(key: key, type: T.self)
        let event = SettingsChangeEvent(
            setting: key,
            oldValue: oldValue,
            newValue: value
        )
        
        // Update the specific setting
        try await localStorage.setSetting(key: key, value: value)
        
        // Track change event
        try await localStorage.trackSettingChange(event)
        
        // Update main settings object if it's a known property
        // Note: Since AppSettings properties are immutable, we would need to create a new instance
        // For now, we'll just update the local storage
        switch key {
        case "theme":
            if let theme = value as? String {
                let newTheme = Theme(rawValue: theme) ?? .system
                let newSettings = AppSettings(
                    theme: newTheme,
                    fontSize: settings.fontSize,
                    notificationsEnabled: settings.notificationsEnabled,
                    offlineModeEnabled: settings.offlineModeEnabled
                )
                try await localStorage.saveAppSettings(newSettings)
            }
        case "fontSize":
            if let sizeRaw = value as? String, let size = FontSize(rawValue: sizeRaw) {
                let newSettings = AppSettings(
                    theme: settings.theme,
                    fontSize: size,
                    notificationsEnabled: settings.notificationsEnabled,
                    offlineModeEnabled: settings.offlineModeEnabled
                )
                try await localStorage.saveAppSettings(newSettings)
            }
        case "notificationsEnabled":
            if let enabled = value as? Bool {
                let newSettings = AppSettings(
                    theme: settings.theme,
                    fontSize: settings.fontSize,
                    notificationsEnabled: enabled,
                    offlineModeEnabled: settings.offlineModeEnabled
                )
                try await localStorage.saveAppSettings(newSettings)
            }
        case "offlineModeEnabled":
            if let enabled = value as? Bool {
                let newSettings = AppSettings(
                    theme: settings.theme,
                    fontSize: settings.fontSize,
                    notificationsEnabled: settings.notificationsEnabled,
                    offlineModeEnabled: enabled
                )
                try await localStorage.saveAppSettings(newSettings)
            }
        default:
            break
        }
    }
    
    public func resetToDefaults() async throws {
        let defaultSettings = AppSettings()
        
        // Track the reset
        let event = SettingsChangeEvent(
            setting: "reset_to_defaults",
            oldValue: try? await getSettings(),
            newValue: defaultSettings
        )
        
        try await updateSettings(defaultSettings)
        try await localStorage.trackSettingChange(event)
        
        // Clear secure storage
        try await secureStorage.remove(forKey: "api_keys")
    }
    
    public func exportSettings() async throws -> Data {
        let settings = try await getSettings()
        return try JSONEncoder().encode(settings)
    }
    
    public func importSettings(from data: Data) async throws {
        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
        try await updateSettings(settings)
    }
    
    public func getSettingsHistory(limit: Int) async throws -> [SettingsChangeEvent] {
        return try await localStorage.getSettingsHistory(limit: limit, offset: 0)
    }
    
    public func createBackup(name: String) async throws -> SettingsBackup {
        let settings = try await getSettings()
        let backup = SettingsBackup(
            name: name,
            settings: settings,
            version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        )
        
        try await localStorage.saveBackup(backup)
        return backup
    }
    
    public func getBackups() async throws -> [SettingsBackup] {
        return try await localStorage.getBackups(limit: 10)
    }
    
    public func restoreBackup(_ backup: SettingsBackup) async throws {
        try await updateSettings(backup.settings)
    }
}