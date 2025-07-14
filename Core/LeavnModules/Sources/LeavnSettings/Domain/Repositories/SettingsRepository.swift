import Foundation

// MARK: - Settings Repository Protocol
public protocol SettingsRepository: Repository {
    // MARK: - App Settings Management
    func getAppSettings() async throws -> AppSettings
    func saveAppSettings(_ settings: AppSettings) async throws
    func resetAppSettings() async throws -> AppSettings
    func getDefaultSettings() async throws -> AppSettings
    
    // MARK: - Individual Settings Sections
    func getGeneralSettings() async throws -> GeneralSettings
    func saveGeneralSettings(_ settings: GeneralSettings) async throws
    
    func getBibleSettings() async throws -> BibleSettings
    func saveBibleSettings(_ settings: BibleSettings) async throws
    
    func getPrivacySettings() async throws -> PrivacySettings
    func savePrivacySettings(_ settings: PrivacySettings) async throws
    
    func getSyncSettings() async throws -> SyncSettings
    func saveSyncSettings(_ settings: SyncSettings) async throws
    
    func getAccessibilitySettings() async throws -> AccessibilitySettings
    func saveAccessibilitySettings(_ settings: AccessibilitySettings) async throws
    
    func getNotificationSettings() async throws -> NotificationSettings
    func saveNotificationSettings(_ settings: NotificationSettings) async throws
    
    func getDisplaySettings() async throws -> DisplaySettings
    func saveDisplaySettings(_ settings: DisplaySettings) async throws
    
    func getStorageSettings() async throws -> StorageSettings
    func saveStorageSettings(_ settings: StorageSettings) async throws
    
    func getAnalyticsSettings() async throws -> AnalyticsSettings
    func saveAnalyticsSettings(_ settings: AnalyticsSettings) async throws
    
    // MARK: - Individual Setting Values
    func getSetting<T: Codable>(key: String, type: T.Type) async throws -> T?
    func setSetting<T: Codable>(key: String, value: T) async throws
    func removeSetting(key: String) async throws
    func getAllSettings() async throws -> [String: Any]
    
    // MARK: - Settings Validation
    func validateSettings(_ settings: AppSettings) async throws -> [SettingsValidationError]
    func validateGeneralSettings(_ settings: GeneralSettings) async throws -> [SettingsValidationError]
    func validateBibleSettings(_ settings: BibleSettings) async throws -> [SettingsValidationError]
    func validatePrivacySettings(_ settings: PrivacySettings) async throws -> [SettingsValidationError]
    func validateSyncSettings(_ settings: SyncSettings) async throws -> [SettingsValidationError]
    func validateAccessibilitySettings(_ settings: AccessibilitySettings) async throws -> [SettingsValidationError]
    func validateNotificationSettings(_ settings: NotificationSettings) async throws -> [SettingsValidationError]
    func validateDisplaySettings(_ settings: DisplaySettings) async throws -> [SettingsValidationError]
    func validateStorageSettings(_ settings: StorageSettings) async throws -> [SettingsValidationError]
    func validateAnalyticsSettings(_ settings: AnalyticsSettings) async throws -> [SettingsValidationError]
    
    // MARK: - Settings Synchronization
    func syncSettings() async throws -> SyncStatus
    func getSyncStatus() async throws -> SyncStatus
    func forceSyncSettings() async throws -> SyncStatus
    func resolveSyncConflicts() async throws -> [SettingsChangeEvent]
    
    // MARK: - Settings History and Changes
    func getSettingsHistory(limit: Int, offset: Int) async throws -> [SettingsChangeEvent]
    func getSettingChanges(for key: String, limit: Int) async throws -> [SettingsChangeEvent]
    func trackSettingChange(_ event: SettingsChangeEvent) async throws
    
    // MARK: - Settings Export/Import
    func exportSettings() async throws -> SettingsExport
    func importSettings(_ export: SettingsExport, mergeStrategy: SettingsImportStrategy) async throws -> SettingsImportResult
    func validateImport(_ export: SettingsExport) async throws -> SettingsImportValidation
    
    // MARK: - Settings Backup and Restore
    func createBackup() async throws -> SettingsBackup
    func restoreFromBackup(_ backup: SettingsBackup) async throws
    func getBackups(limit: Int) async throws -> [SettingsBackup]
    func deleteBackup(_ backupId: String) async throws
    
    // MARK: - Settings Cache Management
    func clearSettingsCache() async throws
    func refreshSettingsCache() async throws
    func preloadSettings() async throws
    
    // MARK: - Settings Notifications
    func observeSettingChanges(for key: String) -> AsyncThrowingStream<SettingsChangeEvent, Error>
    func observeAllSettingChanges() -> AsyncThrowingStream<SettingsChangeEvent, Error>
    func stopObserving(for key: String) async throws
    func stopObservingAll() async throws
    
    // MARK: - Settings Migration
    func migrateSettings(from version: String, to version: String) async throws -> SettingsMigrationResult
    func getCurrentSettingsVersion() async throws -> String
    func needsMigration() async throws -> Bool
    
    // MARK: - Settings Security
    func encryptSensitiveSettings() async throws
    func decryptSensitiveSettings() async throws
    func rotateSensitiveSettingsKey() async throws
    func validateSettingsIntegrity() async throws -> SettingsIntegrityResult
}

// MARK: - Supporting Types
public enum SettingsImportStrategy: String, Codable, CaseIterable {
    case replace = "replace"
    case merge = "merge"
    case preserveLocal = "preserve_local"
    case preserveImported = "preserve_imported"
    
    public var displayName: String {
        switch self {
        case .replace: return "Replace All"
        case .merge: return "Merge"
        case .preserveLocal: return "Preserve Local"
        case .preserveImported: return "Preserve Imported"
        }
    }
    
    public var description: String {
        switch self {
        case .replace: return "Replace all current settings with imported ones"
        case .merge: return "Merge imported settings with current ones"
        case .preserveLocal: return "Keep local settings where conflicts exist"
        case .preserveImported: return "Use imported settings where conflicts exist"
        }
    }
}

public struct SettingsImportResult: Codable {
    public let success: Bool
    public let importedSettings: [String]
    public let skippedSettings: [String]
    public let conflicts: [SettingsConflict]
    public let errors: [String]
    public let importDate: Date
    
    public init(
        success: Bool,
        importedSettings: [String] = [],
        skippedSettings: [String] = [],
        conflicts: [SettingsConflict] = [],
        errors: [String] = [],
        importDate: Date = Date()
    ) {
        self.success = success
        self.importedSettings = importedSettings
        self.skippedSettings = skippedSettings
        self.conflicts = conflicts
        self.errors = errors
        self.importDate = importDate
    }
}

public struct SettingsImportValidation: Codable {
    public let isValid: Bool
    public let compatibleVersion: Bool
    public let warnings: [String]
    public let errors: [String]
    public let requiredMigrations: [String]
    
    public init(
        isValid: Bool,
        compatibleVersion: Bool = true,
        warnings: [String] = [],
        errors: [String] = [],
        requiredMigrations: [String] = []
    ) {
        self.isValid = isValid
        self.compatibleVersion = compatibleVersion
        self.warnings = warnings
        self.errors = errors
        self.requiredMigrations = requiredMigrations
    }
}

public struct SettingsConflict: Codable, Identifiable {
    public let id: String
    public let key: String
    public let localValue: AnyCodable
    public let importedValue: AnyCodable
    public let resolution: ConflictResolution?
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        key: String,
        localValue: AnyCodable,
        importedValue: AnyCodable,
        resolution: ConflictResolution? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.key = key
        self.localValue = localValue
        self.importedValue = importedValue
        self.resolution = resolution
        self.timestamp = timestamp
    }
}

public enum ConflictResolution: String, Codable {
    case useLocal = "use_local"
    case useImported = "use_imported"
    case merge = "merge"
    case skip = "skip"
    
    public var displayName: String {
        switch self {
        case .useLocal: return "Use Local"
        case .useImported: return "Use Imported"
        case .merge: return "Merge"
        case .skip: return "Skip"
        }
    }
}

public struct SettingsBackup: Codable, Identifiable {
    public let id: String
    public let settings: AppSettings
    public let createdAt: Date
    public let appVersion: String
    public let deviceInfo: DeviceInfo
    public let isAutomatic: Bool
    public let name: String?
    public let size: Int64
    
    public init(
        id: String = UUID().uuidString,
        settings: AppSettings,
        createdAt: Date = Date(),
        appVersion: String,
        deviceInfo: DeviceInfo,
        isAutomatic: Bool = true,
        name: String? = nil,
        size: Int64 = 0
    ) {
        self.id = id
        self.settings = settings
        self.createdAt = createdAt
        self.appVersion = appVersion
        self.deviceInfo = deviceInfo
        self.isAutomatic = isAutomatic
        self.name = name
        self.size = size
    }
    
    public var displayName: String {
        if let name = name {
            return name
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let prefix = isAutomatic ? "Auto" : "Manual"
        return "\(prefix) - \(formatter.string(from: createdAt))"
    }
}

public struct SettingsMigrationResult: Codable {
    public let success: Bool
    public let fromVersion: String
    public let toVersion: String
    public let migratedSettings: [String]
    public let removedSettings: [String]
    public let addedSettings: [String]
    public let errors: [String]
    public let migrationDate: Date
    
    public init(
        success: Bool,
        fromVersion: String,
        toVersion: String,
        migratedSettings: [String] = [],
        removedSettings: [String] = [],
        addedSettings: [String] = [],
        errors: [String] = [],
        migrationDate: Date = Date()
    ) {
        self.success = success
        self.fromVersion = fromVersion
        self.toVersion = toVersion
        self.migratedSettings = migratedSettings
        self.removedSettings = removedSettings
        self.addedSettings = addedSettings
        self.errors = errors
        self.migrationDate = migrationDate
    }
}

public struct SettingsIntegrityResult: Codable {
    public let isValid: Bool
    public let corruptedSettings: [String]
    public let missingSettings: [String]
    public let unexpectedSettings: [String]
    public let checksum: String
    public let validationDate: Date
    
    public init(
        isValid: Bool,
        corruptedSettings: [String] = [],
        missingSettings: [String] = [],
        unexpectedSettings: [String] = [],
        checksum: String,
        validationDate: Date = Date()
    ) {
        self.isValid = isValid
        self.corruptedSettings = corruptedSettings
        self.missingSettings = missingSettings
        self.unexpectedSettings = unexpectedSettings
        self.checksum = checksum
        self.validationDate = validationDate
    }
}

// MARK: - Settings Repository Events
public enum SettingsRepositoryEvent {
    case settingsLoaded(AppSettings)
    case settingChanged(SettingsChangeEvent)
    case syncStarted
    case syncCompleted(SyncStatus)
    case syncFailed(Error)
    case backupCreated(SettingsBackup)
    case backupRestored(SettingsBackup)
    case importCompleted(SettingsImportResult)
    case migrationCompleted(SettingsMigrationResult)
    case validationFailed([SettingsValidationError])
    case cacheCleared
    case integrityCheckFailed(SettingsIntegrityResult)
}

// MARK: - Settings Repository Factory
public protocol SettingsRepositoryFactory {
    func createSettingsRepository() -> SettingsRepository
}

// MARK: - Settings Repository Configuration
public struct SettingsRepositoryConfiguration {
    public let enableAutoBackup: Bool
    public let backupRetentionDays: Int
    public let syncEnabled: Bool
    public let syncProvider: SyncProvider
    public let encryptionEnabled: Bool
    public let cacheEnabled: Bool
    public let maxCacheSize: Int64
    public let validationEnabled: Bool
    public let observeSystemSettings: Bool
    
    public static let `default` = SettingsRepositoryConfiguration(
        enableAutoBackup: true,
        backupRetentionDays: 30,
        syncEnabled: true,
        syncProvider: .icloud,
        encryptionEnabled: true,
        cacheEnabled: true,
        maxCacheSize: 10 * 1024 * 1024, // 10MB
        validationEnabled: true,
        observeSystemSettings: true
    )
    
    public init(
        enableAutoBackup: Bool = true,
        backupRetentionDays: Int = 30,
        syncEnabled: Bool = true,
        syncProvider: SyncProvider = .icloud,
        encryptionEnabled: Bool = true,
        cacheEnabled: Bool = true,
        maxCacheSize: Int64 = 10 * 1024 * 1024,
        validationEnabled: Bool = true,
        observeSystemSettings: Bool = true
    ) {
        self.enableAutoBackup = enableAutoBackup
        self.backupRetentionDays = backupRetentionDays
        self.syncEnabled = syncEnabled
        self.syncProvider = syncProvider
        self.encryptionEnabled = encryptionEnabled
        self.cacheEnabled = cacheEnabled
        self.maxCacheSize = maxCacheSize
        self.validationEnabled = validationEnabled
        self.observeSystemSettings = observeSystemSettings
    }
}