import Foundation

// MARK: - Get App Settings Use Case
public struct GetAppSettingsUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = AppSettings
    
    private let settingsRepository: SettingsRepository
    
    public init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }
    
    public func execute(_ input: Void) async throws -> AppSettings {
        try await settingsRepository.getAppSettings()
    }
}

// MARK: - Update App Settings Use Case
public struct UpdateAppSettingsUseCase: UseCase {
    public typealias Input = UpdateAppSettingsInput
    public typealias Output = AppSettings
    
    private let settingsRepository: SettingsRepository
    private let analyticsService: AnalyticsService?
    
    public init(settingsRepository: SettingsRepository, analyticsService: AnalyticsService? = nil) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: UpdateAppSettingsInput) async throws -> AppSettings {
        // Validate settings before saving
        let validationErrors = try await settingsRepository.validateSettings(input.settings)
        
        guard validationErrors.isEmpty else {
            analyticsService?.track(event: SettingsAnalyticsEvent.settingsValidationFailed(
                errors: validationErrors.map { $0.field }
            ))
            throw LeavnError.validationError(message: "Settings validation failed: \(validationErrors.first?.reason ?? "Unknown error")")
        }
        
        // Get current settings for change tracking
        let currentSettings = try? await settingsRepository.getAppSettings()
        
        // Save the new settings
        try await settingsRepository.saveAppSettings(input.settings)
        
        // Track changes if analytics is enabled
        if let current = currentSettings {
            let changes = detectChanges(from: current, to: input.settings)
            for change in changes {
                try await settingsRepository.trackSettingChange(change)
                analyticsService?.track(event: SettingsAnalyticsEvent.settingChanged(
                    key: change.settingKey,
                    oldValue: change.oldValue?.value as? String,
                    newValue: change.newValue.value as? String,
                    source: change.source.rawValue
                ))
            }
        }
        
        analyticsService?.track(event: SettingsAnalyticsEvent.settingsUpdated(
            sections: input.updatedSections ?? [],
            changeCount: 1
        ))
        
        return input.settings
    }
    
    private func detectChanges(from oldSettings: AppSettings, to newSettings: AppSettings) -> [SettingsChangeEvent] {
        var changes: [SettingsChangeEvent] = []
        
        // Compare each section and detect changes
        if oldSettings.general != newSettings.general {
            changes.append(SettingsChangeEvent(
                settingKey: "general",
                oldValue: try? AnyCodable(oldSettings.general),
                newValue: try! AnyCodable(newSettings.general)
            ))
        }
        
        if oldSettings.bible != newSettings.bible {
            changes.append(SettingsChangeEvent(
                settingKey: "bible",
                oldValue: try? AnyCodable(oldSettings.bible),
                newValue: try! AnyCodable(newSettings.bible)
            ))
        }
        
        if oldSettings.privacy != newSettings.privacy {
            changes.append(SettingsChangeEvent(
                settingKey: "privacy",
                oldValue: try? AnyCodable(oldSettings.privacy),
                newValue: try! AnyCodable(newSettings.privacy)
            ))
        }
        
        if oldSettings.sync != newSettings.sync {
            changes.append(SettingsChangeEvent(
                settingKey: "sync",
                oldValue: try? AnyCodable(oldSettings.sync),
                newValue: try! AnyCodable(newSettings.sync)
            ))
        }
        
        if oldSettings.accessibility != newSettings.accessibility {
            changes.append(SettingsChangeEvent(
                settingKey: "accessibility",
                oldValue: try? AnyCodable(oldSettings.accessibility),
                newValue: try! AnyCodable(newSettings.accessibility)
            ))
        }
        
        if oldSettings.notifications != newSettings.notifications {
            changes.append(SettingsChangeEvent(
                settingKey: "notifications",
                oldValue: try? AnyCodable(oldSettings.notifications),
                newValue: try! AnyCodable(newSettings.notifications)
            ))
        }
        
        if oldSettings.display != newSettings.display {
            changes.append(SettingsChangeEvent(
                settingKey: "display",
                oldValue: try? AnyCodable(oldSettings.display),
                newValue: try! AnyCodable(newSettings.display)
            ))
        }
        
        if oldSettings.storage != newSettings.storage {
            changes.append(SettingsChangeEvent(
                settingKey: "storage",
                oldValue: try? AnyCodable(oldSettings.storage),
                newValue: try! AnyCodable(newSettings.storage)
            ))
        }
        
        if oldSettings.analytics != newSettings.analytics {
            changes.append(SettingsChangeEvent(
                settingKey: "analytics",
                oldValue: try? AnyCodable(oldSettings.analytics),
                newValue: try! AnyCodable(newSettings.analytics)
            ))
        }
        
        return changes
    }
}

// MARK: - Update Individual Setting Use Case
public struct UpdateIndividualSettingUseCase: UseCase {
    public typealias Input = UpdateIndividualSettingInput
    public typealias Output = Void
    
    private let settingsRepository: SettingsRepository
    private let analyticsService: AnalyticsService?
    
    public init(settingsRepository: SettingsRepository, analyticsService: AnalyticsService? = nil) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: UpdateIndividualSettingInput) async throws {
        // Get old value for tracking
        let oldValue = try? await settingsRepository.getSetting(key: input.key, type: type(of: input.value))
        
        // Set the new value
        try await settingsRepository.setSetting(key: input.key, value: input.value)
        
        // Track the change
        let changeEvent = SettingsChangeEvent(
            settingKey: input.key,
            oldValue: oldValue.flatMap { try? AnyCodable($0) },
            newValue: try! AnyCodable(input.value),
            source: input.source
        )
        
        try await settingsRepository.trackSettingChange(changeEvent)
        
        analyticsService?.track(event: SettingsAnalyticsEvent.settingChanged(
            key: input.key,
            oldValue: oldValue as? String,
            newValue: input.value as? String,
            source: input.source.rawValue
        ))
    }
}

// MARK: - Reset Settings Use Case
public struct ResetSettingsUseCase: UseCase {
    public typealias Input = ResetSettingsInput
    public typealias Output = AppSettings
    
    private let settingsRepository: SettingsRepository
    private let analyticsService: AnalyticsService?
    
    public init(settingsRepository: SettingsRepository, analyticsService: AnalyticsService? = nil) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: ResetSettingsInput) async throws -> AppSettings {
        let currentSettings = try? await settingsRepository.getAppSettings()
        
        let resetSettings: AppSettings
        
        switch input.resetType {
        case .all:
            resetSettings = try await settingsRepository.resetAppSettings()
            
        case .section(let section):
            let current = try await settingsRepository.getAppSettings()
            let defaults = try await settingsRepository.getDefaultSettings()
            
            resetSettings = resetSection(section, in: current, with: defaults)
            try await settingsRepository.saveAppSettings(resetSettings)
            
        case .specific(let keys):
            let current = try await settingsRepository.getAppSettings()
            let defaults = try await settingsRepository.getDefaultSettings()
            
            resetSettings = resetSpecificSettings(keys, in: current, with: defaults)
            try await settingsRepository.saveAppSettings(resetSettings)
        }
        
        // Track the reset
        analyticsService?.track(event: SettingsAnalyticsEvent.settingsReset(
            resetType: input.resetType.description,
            previousVersion: currentSettings?.version
        ))
        
        // Create change event
        if let current = currentSettings {
            let changeEvent = SettingsChangeEvent(
                settingKey: "settings_reset",
                oldValue: try? AnyCodable(current),
                newValue: try! AnyCodable(resetSettings),
                source: .reset
            )
            
            try await settingsRepository.trackSettingChange(changeEvent)
        }
        
        return resetSettings
    }
    
    private func resetSection(_ section: SettingsSection, in current: AppSettings, with defaults: AppSettings) -> AppSettings {
        switch section {
        case .general:
            return AppSettings(
                general: defaults.general,
                bible: current.bible,
                privacy: current.privacy,
                sync: current.sync,
                accessibility: current.accessibility,
                notifications: current.notifications,
                display: current.display,
                storage: current.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .bible:
            return AppSettings(
                general: current.general,
                bible: defaults.bible,
                privacy: current.privacy,
                sync: current.sync,
                accessibility: current.accessibility,
                notifications: current.notifications,
                display: current.display,
                storage: current.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .privacy:
            return AppSettings(
                general: current.general,
                bible: current.bible,
                privacy: defaults.privacy,
                sync: current.sync,
                accessibility: current.accessibility,
                notifications: current.notifications,
                display: current.display,
                storage: current.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .sync:
            return AppSettings(
                general: current.general,
                bible: current.bible,
                privacy: current.privacy,
                sync: defaults.sync,
                accessibility: current.accessibility,
                notifications: current.notifications,
                display: current.display,
                storage: current.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .accessibility:
            return AppSettings(
                general: current.general,
                bible: current.bible,
                privacy: current.privacy,
                sync: current.sync,
                accessibility: defaults.accessibility,
                notifications: current.notifications,
                display: current.display,
                storage: current.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .notifications:
            return AppSettings(
                general: current.general,
                bible: current.bible,
                privacy: current.privacy,
                sync: current.sync,
                accessibility: current.accessibility,
                notifications: defaults.notifications,
                display: current.display,
                storage: current.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .display:
            return AppSettings(
                general: current.general,
                bible: current.bible,
                privacy: current.privacy,
                sync: current.sync,
                accessibility: current.accessibility,
                notifications: current.notifications,
                display: defaults.display,
                storage: current.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .storage:
            return AppSettings(
                general: current.general,
                bible: current.bible,
                privacy: current.privacy,
                sync: current.sync,
                accessibility: current.accessibility,
                notifications: current.notifications,
                display: current.display,
                storage: defaults.storage,
                analytics: current.analytics,
                lastModified: Date(),
                version: current.version
            )
        case .analytics:
            return AppSettings(
                general: current.general,
                bible: current.bible,
                privacy: current.privacy,
                sync: current.sync,
                accessibility: current.accessibility,
                notifications: current.notifications,
                display: current.display,
                storage: current.storage,
                analytics: defaults.analytics,
                lastModified: Date(),
                version: current.version
            )
        }
    }
    
    private func resetSpecificSettings(_ keys: [String], in current: AppSettings, with defaults: AppSettings) -> AppSettings {
        // This would need specific implementation based on the keys
        // For now, return current settings
        return current
    }
}

// MARK: - Export Settings Use Case
public struct ExportSettingsUseCase: UseCase {
    public typealias Input = ExportSettingsInput
    public typealias Output = SettingsExport
    
    private let settingsRepository: SettingsRepository
    private let analyticsService: AnalyticsService?
    
    public init(settingsRepository: SettingsRepository, analyticsService: AnalyticsService? = nil) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: ExportSettingsInput) async throws -> SettingsExport {
        var settings = try await settingsRepository.getAppSettings()
        
        // Filter sensitive data if requested
        if input.excludeSensitiveData {
            settings = filterSensitiveData(from: settings)
        }
        
        // Filter specific sections if requested
        if let includedSections = input.includedSections {
            settings = filterSections(settings, includedSections: includedSections)
        }
        
        let export = try await settingsRepository.exportSettings()
        
        analyticsService?.track(event: SettingsAnalyticsEvent.settingsExported(
            includedSections: input.includedSections?.map { $0.rawValue } ?? [],
            excludedSensitiveData: input.excludeSensitiveData
        ))
        
        return export
    }
    
    private func filterSensitiveData(from settings: AppSettings) -> AppSettings {
        // Remove sensitive information like sync provider credentials, biometric settings, etc.
        let filteredPrivacy = PrivacySettings(
            analyticsEnabled: settings.privacy.analyticsEnabled,
            crashReportingEnabled: settings.privacy.crashReportingEnabled,
            personalizedAdsEnabled: settings.privacy.personalizedAdsEnabled,
            dataCollectionLevel: settings.privacy.dataCollectionLevel,
            shareUsageData: settings.privacy.shareUsageData,
            locationServicesEnabled: settings.privacy.locationServicesEnabled,
            biometricAuthEnabled: false, // Sensitive
            passcodeRequired: false, // Sensitive
            sessionTimeout: settings.privacy.sessionTimeout,
            privateMode: settings.privacy.privateMode,
            encryptLocal: settings.privacy.encryptLocal,
            allowScreenshots: settings.privacy.allowScreenshots
        )
        
        return AppSettings(
            general: settings.general,
            bible: settings.bible,
            privacy: filteredPrivacy,
            sync: settings.sync,
            accessibility: settings.accessibility,
            notifications: settings.notifications,
            display: settings.display,
            storage: settings.storage,
            analytics: settings.analytics,
            lastModified: settings.lastModified,
            version: settings.version
        )
    }
    
    private func filterSections(_ settings: AppSettings, includedSections: [SettingsSection]) -> AppSettings {
        let defaults = AppSettings() // Default settings for excluded sections
        
        return AppSettings(
            general: includedSections.contains(.general) ? settings.general : defaults.general,
            bible: includedSections.contains(.bible) ? settings.bible : defaults.bible,
            privacy: includedSections.contains(.privacy) ? settings.privacy : defaults.privacy,
            sync: includedSections.contains(.sync) ? settings.sync : defaults.sync,
            accessibility: includedSections.contains(.accessibility) ? settings.accessibility : defaults.accessibility,
            notifications: includedSections.contains(.notifications) ? settings.notifications : defaults.notifications,
            display: includedSections.contains(.display) ? settings.display : defaults.display,
            storage: includedSections.contains(.storage) ? settings.storage : defaults.storage,
            analytics: includedSections.contains(.analytics) ? settings.analytics : defaults.analytics,
            lastModified: settings.lastModified,
            version: settings.version
        )
    }
}

// MARK: - Import Settings Use Case
public struct ImportSettingsUseCase: UseCase {
    public typealias Input = ImportSettingsInput
    public typealias Output = SettingsImportResult
    
    private let settingsRepository: SettingsRepository
    private let analyticsService: AnalyticsService?
    
    public init(settingsRepository: SettingsRepository, analyticsService: AnalyticsService? = nil) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: ImportSettingsInput) async throws -> SettingsImportResult {
        // Validate the import first
        let validation = try await settingsRepository.validateImport(input.export)
        
        guard validation.isValid else {
            analyticsService?.track(event: SettingsAnalyticsEvent.settingsImportFailed(
                reason: "validation_failed",
                errors: validation.errors
            ))
            
            throw LeavnError.validationError(message: "Import validation failed: \(validation.errors.joined(separator: ", "))")
        }
        
        // Perform the import
        let result = try await settingsRepository.importSettings(input.export, mergeStrategy: input.strategy)
        
        analyticsService?.track(event: SettingsAnalyticsEvent.settingsImported(
            strategy: input.strategy.rawValue,
            importedCount: result.importedSettings.count,
            conflictCount: result.conflicts.count,
            success: result.success
        ))
        
        return result
    }
}

// MARK: - Sync Settings Use Case
public struct SyncSettingsUseCase: UseCase {
    public typealias Input = SyncSettingsInput
    public typealias Output = SyncStatus
    
    private let settingsRepository: SettingsRepository
    private let analyticsService: AnalyticsService?
    
    public init(settingsRepository: SettingsRepository, analyticsService: AnalyticsService? = nil) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: SyncSettingsInput) async throws -> SyncStatus {
        analyticsService?.track(event: SettingsAnalyticsEvent.settingsSyncStarted(
            isForced: input.forceSync
        ))
        
        do {
            let status = input.forceSync 
                ? try await settingsRepository.forceSyncSettings()
                : try await settingsRepository.syncSettings()
            
            analyticsService?.track(event: SettingsAnalyticsEvent.settingsSyncCompleted(
                status: status.rawValue,
                duration: 0 // Would need to track actual duration
            ))
            
            return status
            
        } catch {
            analyticsService?.track(event: SettingsAnalyticsEvent.settingsSyncFailed(
                error: error.localizedDescription
            ))
            
            throw error
        }
    }
}

// MARK: - Get Settings History Use Case
public struct GetSettingsHistoryUseCase: UseCase {
    public typealias Input = GetSettingsHistoryInput
    public typealias Output = [SettingsChangeEvent]
    
    private let settingsRepository: SettingsRepository
    
    public init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }
    
    public func execute(_ input: GetSettingsHistoryInput) async throws -> [SettingsChangeEvent] {
        if let settingKey = input.settingKey {
            return try await settingsRepository.getSettingChanges(
                for: settingKey,
                limit: input.limit
            )
        } else {
            return try await settingsRepository.getSettingsHistory(
                limit: input.limit,
                offset: input.offset
            )
        }
    }
}

// MARK: - Create Settings Backup Use Case
public struct CreateSettingsBackupUseCase: UseCase {
    public typealias Input = CreateSettingsBackupInput
    public typealias Output = SettingsBackup
    
    private let settingsRepository: SettingsRepository
    private let analyticsService: AnalyticsService?
    
    public init(settingsRepository: SettingsRepository, analyticsService: AnalyticsService? = nil) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: CreateSettingsBackupInput) async throws -> SettingsBackup {
        let backup = try await settingsRepository.createBackup()
        
        analyticsService?.track(event: SettingsAnalyticsEvent.settingsBackupCreated(
            backupId: backup.id,
            isAutomatic: input.isAutomatic
        ))
        
        return backup
    }
}

// MARK: - Validate Settings Use Case
public struct ValidateSettingsUseCase: UseCase {
    public typealias Input = ValidateSettingsInput
    public typealias Output = [SettingsValidationError]
    
    private let settingsRepository: SettingsRepository
    
    public init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }
    
    public func execute(_ input: ValidateSettingsInput) async throws -> [SettingsValidationError] {
        switch input.validationType {
        case .full(let settings):
            return try await settingsRepository.validateSettings(settings)
            
        case .general(let settings):
            return try await settingsRepository.validateGeneralSettings(settings)
            
        case .bible(let settings):
            return try await settingsRepository.validateBibleSettings(settings)
            
        case .privacy(let settings):
            return try await settingsRepository.validatePrivacySettings(settings)
            
        case .sync(let settings):
            return try await settingsRepository.validateSyncSettings(settings)
            
        case .accessibility(let settings):
            return try await settingsRepository.validateAccessibilitySettings(settings)
            
        case .notifications(let settings):
            return try await settingsRepository.validateNotificationSettings(settings)
            
        case .display(let settings):
            return try await settingsRepository.validateDisplaySettings(settings)
            
        case .storage(let settings):
            return try await settingsRepository.validateStorageSettings(settings)
            
        case .analytics(let settings):
            return try await settingsRepository.validateAnalyticsSettings(settings)
        }
    }
}

// MARK: - Input Models
public struct UpdateAppSettingsInput {
    public let settings: AppSettings
    public let updatedSections: [SettingsSection]?
    
    public init(settings: AppSettings, updatedSections: [SettingsSection]? = nil) {
        self.settings = settings
        self.updatedSections = updatedSections
    }
}

public struct UpdateIndividualSettingInput {
    public let key: String
    public let value: Any
    public let source: SettingsChangeSource
    
    public init(key: String, value: Any, source: SettingsChangeSource = .user) {
        self.key = key
        self.value = value
        self.source = source
    }
}

public struct ResetSettingsInput {
    public let resetType: SettingsResetType
    
    public init(resetType: SettingsResetType) {
        self.resetType = resetType
    }
}

public enum SettingsResetType {
    case all
    case section(SettingsSection)
    case specific([String])
    
    public var description: String {
        switch self {
        case .all: return "all"
        case .section(let section): return "section_\(section.rawValue)"
        case .specific(let keys): return "specific_\(keys.joined(separator: ","))"
        }
    }
}

public enum SettingsSection: String, Codable, CaseIterable {
    case general = "general"
    case bible = "bible"
    case privacy = "privacy"
    case sync = "sync"
    case accessibility = "accessibility"
    case notifications = "notifications"
    case display = "display"
    case storage = "storage"
    case analytics = "analytics"
    
    public var displayName: String {
        switch self {
        case .general: return "General"
        case .bible: return "Bible"
        case .privacy: return "Privacy"
        case .sync: return "Sync"
        case .accessibility: return "Accessibility"
        case .notifications: return "Notifications"
        case .display: return "Display"
        case .storage: return "Storage"
        case .analytics: return "Analytics"
        }
    }
}

public struct ExportSettingsInput {
    public let includedSections: [SettingsSection]?
    public let excludeSensitiveData: Bool
    
    public init(includedSections: [SettingsSection]? = nil, excludeSensitiveData: Bool = true) {
        self.includedSections = includedSections
        self.excludeSensitiveData = excludeSensitiveData
    }
}

public struct ImportSettingsInput {
    public let export: SettingsExport
    public let strategy: SettingsImportStrategy
    
    public init(export: SettingsExport, strategy: SettingsImportStrategy) {
        self.export = export
        self.strategy = strategy
    }
}

public struct SyncSettingsInput {
    public let forceSync: Bool
    
    public init(forceSync: Bool = false) {
        self.forceSync = forceSync
    }
}

public struct GetSettingsHistoryInput {
    public let limit: Int
    public let offset: Int
    public let settingKey: String?
    
    public init(limit: Int = 50, offset: Int = 0, settingKey: String? = nil) {
        self.limit = limit
        self.offset = offset
        self.settingKey = settingKey
    }
}

public struct CreateSettingsBackupInput {
    public let isAutomatic: Bool
    public let name: String?
    
    public init(isAutomatic: Bool = false, name: String? = nil) {
        self.isAutomatic = isAutomatic
        self.name = name
    }
}

public struct ValidateSettingsInput {
    public let validationType: SettingsValidationType
    
    public init(validationType: SettingsValidationType) {
        self.validationType = validationType
    }
}

public enum SettingsValidationType {
    case full(AppSettings)
    case general(GeneralSettings)
    case bible(BibleSettings)
    case privacy(PrivacySettings)
    case sync(SyncSettings)
    case accessibility(AccessibilitySettings)
    case notifications(NotificationSettings)
    case display(DisplaySettings)
    case storage(StorageSettings)
    case analytics(AnalyticsSettings)
}

// MARK: - Settings Analytics Events
enum SettingsAnalyticsEvent: AnalyticsEvent {
    case settingsUpdated(sections: [SettingsSection], changeCount: Int)
    case settingChanged(key: String, oldValue: String?, newValue: String?, source: String)
    case settingsReset(resetType: String, previousVersion: String?)
    case settingsExported(includedSections: [String], excludedSensitiveData: Bool)
    case settingsImported(strategy: String, importedCount: Int, conflictCount: Int, success: Bool)
    case settingsImportFailed(reason: String, errors: [String])
    case settingsSyncStarted(isForced: Bool)
    case settingsSyncCompleted(status: String, duration: TimeInterval)
    case settingsSyncFailed(error: String)
    case settingsBackupCreated(backupId: String, isAutomatic: Bool)
    case settingsBackupRestored(backupId: String)
    case settingsValidationFailed(errors: [String])
    case settingsMigrationCompleted(fromVersion: String, toVersion: String, success: Bool)
    case settingsIntegrityCheckFailed(corruptedSettings: [String])
    
    var name: String {
        switch self {
        case .settingsUpdated: return "settings_updated"
        case .settingChanged: return "setting_changed"
        case .settingsReset: return "settings_reset"
        case .settingsExported: return "settings_exported"
        case .settingsImported: return "settings_imported"
        case .settingsImportFailed: return "settings_import_failed"
        case .settingsSyncStarted: return "settings_sync_started"
        case .settingsSyncCompleted: return "settings_sync_completed"
        case .settingsSyncFailed: return "settings_sync_failed"
        case .settingsBackupCreated: return "settings_backup_created"
        case .settingsBackupRestored: return "settings_backup_restored"
        case .settingsValidationFailed: return "settings_validation_failed"
        case .settingsMigrationCompleted: return "settings_migration_completed"
        case .settingsIntegrityCheckFailed: return "settings_integrity_check_failed"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .settingsUpdated(let sections, let changeCount):
            return [
                "sections": sections.map { $0.rawValue },
                "change_count": changeCount
            ]
            
        case .settingChanged(let key, let oldValue, let newValue, let source):
            var params: [String: Any] = [
                "setting_key": key,
                "source": source
            ]
            if let oldValue = oldValue {
                params["old_value"] = oldValue
            }
            if let newValue = newValue {
                params["new_value"] = newValue
            }
            return params
            
        case .settingsReset(let resetType, let previousVersion):
            var params: [String: Any] = ["reset_type": resetType]
            if let version = previousVersion {
                params["previous_version"] = version
            }
            return params
            
        case .settingsExported(let includedSections, let excludedSensitiveData):
            return [
                "included_sections": includedSections,
                "excluded_sensitive_data": excludedSensitiveData
            ]
            
        case .settingsImported(let strategy, let importedCount, let conflictCount, let success):
            return [
                "strategy": strategy,
                "imported_count": importedCount,
                "conflict_count": conflictCount,
                "success": success
            ]
            
        case .settingsImportFailed(let reason, let errors):
            return [
                "reason": reason,
                "errors": errors
            ]
            
        case .settingsSyncStarted(let isForced):
            return ["is_forced": isForced]
            
        case .settingsSyncCompleted(let status, let duration):
            return [
                "status": status,
                "duration_seconds": Int(duration)
            ]
            
        case .settingsSyncFailed(let error):
            return ["error": error]
            
        case .settingsBackupCreated(let backupId, let isAutomatic):
            return [
                "backup_id": backupId,
                "is_automatic": isAutomatic
            ]
            
        case .settingsBackupRestored(let backupId):
            return ["backup_id": backupId]
            
        case .settingsValidationFailed(let errors):
            return ["errors": errors]
            
        case .settingsMigrationCompleted(let fromVersion, let toVersion, let success):
            return [
                "from_version": fromVersion,
                "to_version": toVersion,
                "success": success
            ]
            
        case .settingsIntegrityCheckFailed(let corruptedSettings):
            return ["corrupted_settings": corruptedSettings]
        }
    }
}