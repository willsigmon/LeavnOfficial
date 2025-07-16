import Foundation

import Combine

// MARK: - Settings View Model
@MainActor
public final class SettingsViewModel: StatefulViewModel<SettingsViewState, SettingsViewEvent> {
    
    // Use Cases
    private let getAppSettingsUseCase: GetAppSettingsUseCase
    private let updateAppSettingsUseCase: UpdateAppSettingsUseCase
    private let updateIndividualSettingUseCase: UpdateIndividualSettingUseCase
    private let resetSettingsUseCase: ResetSettingsUseCase
    private let exportSettingsUseCase: ExportSettingsUseCase
    private let importSettingsUseCase: ImportSettingsUseCase
    private let syncSettingsUseCase: SyncSettingsUseCase
    private let getSettingsHistoryUseCase: GetSettingsHistoryUseCase
    private let createSettingsBackupUseCase: CreateSettingsBackupUseCase
    private let validateSettingsUseCase: ValidateSettingsUseCase
    
    // Services
    private let analyticsService: AnalyticsService?
    
    // Observation
    private var settingsObserver: Task<Void, Never>?
    
    public init(
        getAppSettingsUseCase: GetAppSettingsUseCase,
        updateAppSettingsUseCase: UpdateAppSettingsUseCase,
        updateIndividualSettingUseCase: UpdateIndividualSettingUseCase,
        resetSettingsUseCase: ResetSettingsUseCase,
        exportSettingsUseCase: ExportSettingsUseCase,
        importSettingsUseCase: ImportSettingsUseCase,
        syncSettingsUseCase: SyncSettingsUseCase,
        getSettingsHistoryUseCase: GetSettingsHistoryUseCase,
        createSettingsBackupUseCase: CreateSettingsBackupUseCase,
        validateSettingsUseCase: ValidateSettingsUseCase,
        analyticsService: AnalyticsService? = nil
    ) {
        self.getAppSettingsUseCase = getAppSettingsUseCase
        self.updateAppSettingsUseCase = updateAppSettingsUseCase
        self.updateIndividualSettingUseCase = updateIndividualSettingUseCase
        self.resetSettingsUseCase = resetSettingsUseCase
        self.exportSettingsUseCase = exportSettingsUseCase
        self.importSettingsUseCase = importSettingsUseCase
        self.syncSettingsUseCase = syncSettingsUseCase
        self.getSettingsHistoryUseCase = getSettingsHistoryUseCase
        self.createSettingsBackupUseCase = createSettingsBackupUseCase
        self.validateSettingsUseCase = validateSettingsUseCase
        self.analyticsService = analyticsService
        
        super.init(initialState: SettingsViewState())
        
        startObservingSettings()
    }
    
    deinit {
        settingsObserver?.cancel()
    }
    
    public override func send(_ event: SettingsViewEvent) {
        switch event {
        case .loadSettings:
            loadSettings()
            
        case .updateGeneralSettings(let settings):
            updateGeneralSettings(settings)
            
        case .updateBibleSettings(let settings):
            updateBibleSettings(settings)
            
        case .updatePrivacySettings(let settings):
            updatePrivacySettings(settings)
            
        case .updateSyncSettings(let settings):
            updateSyncSettings(settings)
            
        case .updateAccessibilitySettings(let settings):
            updateAccessibilitySettings(settings)
            
        case .updateNotificationSettings(let settings):
            updateNotificationSettings(settings)
            
        case .updateDisplaySettings(let settings):
            updateDisplaySettings(settings)
            
        case .updateStorageSettings(let settings):
            updateStorageSettings(settings)
            
        case .updateAnalyticsSettings(let settings):
            updateAnalyticsSettings(settings)
            
        case .updateIndividualSetting(let key, let value):
            updateIndividualSetting(key: key, value: value)
            
        case .resetSettings(let resetType):
            resetSettings(resetType)
            
        case .exportSettings(let options):
            exportSettings(options)
            
        case .importSettings(let export, let strategy):
            importSettings(export, strategy: strategy)
            
        case .syncSettings(let forceSync):
            syncSettings(forceSync: forceSync)
            
        case .loadSettingsHistory:
            loadSettingsHistory()
            
        case .createBackup(let name):
            createBackup(name: name)
            
        case .restoreBackup(let backup):
            restoreBackup(backup)
            
        case .validateCurrentSettings:
            validateCurrentSettings()
            
        case .selectSection(let section):
            selectSection(section)
            
        case .searchSettings(let query):
            searchSettings(query)
            
        case .clearError:
            clearError()
            
        case .clearSuccess:
            clearSuccess()
        }
    }
    
    // MARK: - Settings Loading
    private func loadSettings() {
        updateState { state in
            state.isLoading = true
            state.error = nil
        }
        
        Task {
            do {
                let settings = try await getAppSettingsUseCase.execute(())
                
                updateState { state in
                    state.isLoading = false
                    state.settings = settings
                    state.lastLoadedAt = Date()
                }
                
                analyticsService?.track(event: CommonAnalyticsEvent.screenView(
                    screenName: "Settings",
                    screenClass: "SettingsView"
                ))
                
            } catch {
                updateState { state in
                    state.isLoading = false
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - Individual Settings Updates
    private func updateGeneralSettings(_ settings: GeneralSettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: settings,
            bible: currentSettings.bible,
            privacy: currentSettings.privacy,
            sync: currentSettings.sync,
            accessibility: currentSettings.accessibility,
            notifications: currentSettings.notifications,
            display: currentSettings.display,
            storage: currentSettings.storage,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.general])
    }
    
    private func updateBibleSettings(_ settings: BibleSettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: settings,
            privacy: currentSettings.privacy,
            sync: currentSettings.sync,
            accessibility: currentSettings.accessibility,
            notifications: currentSettings.notifications,
            display: currentSettings.display,
            storage: currentSettings.storage,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.bible])
    }
    
    private func updatePrivacySettings(_ settings: PrivacySettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: currentSettings.bible,
            privacy: settings,
            sync: currentSettings.sync,
            accessibility: currentSettings.accessibility,
            notifications: currentSettings.notifications,
            display: currentSettings.display,
            storage: currentSettings.storage,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.privacy])
    }
    
    private func updateSyncSettings(_ settings: SyncSettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: currentSettings.bible,
            privacy: currentSettings.privacy,
            sync: settings,
            accessibility: currentSettings.accessibility,
            notifications: currentSettings.notifications,
            display: currentSettings.display,
            storage: currentSettings.storage,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.sync])
    }
    
    private func updateAccessibilitySettings(_ settings: AccessibilitySettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: currentSettings.bible,
            privacy: currentSettings.privacy,
            sync: currentSettings.sync,
            accessibility: settings,
            notifications: currentSettings.notifications,
            display: currentSettings.display,
            storage: currentSettings.storage,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.accessibility])
    }
    
    private func updateNotificationSettings(_ settings: NotificationSettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: currentSettings.bible,
            privacy: currentSettings.privacy,
            sync: currentSettings.sync,
            accessibility: currentSettings.accessibility,
            notifications: settings,
            display: currentSettings.display,
            storage: currentSettings.storage,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.notifications])
    }
    
    private func updateDisplaySettings(_ settings: DisplaySettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: currentSettings.bible,
            privacy: currentSettings.privacy,
            sync: currentSettings.sync,
            accessibility: currentSettings.accessibility,
            notifications: currentSettings.notifications,
            display: settings,
            storage: currentSettings.storage,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.display])
    }
    
    private func updateStorageSettings(_ settings: StorageSettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: currentSettings.bible,
            privacy: currentSettings.privacy,
            sync: currentSettings.sync,
            accessibility: currentSettings.accessibility,
            notifications: currentSettings.notifications,
            display: currentSettings.display,
            storage: settings,
            analytics: currentSettings.analytics,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.storage])
    }
    
    private func updateAnalyticsSettings(_ settings: AnalyticsSettings) {
        guard let currentSettings = state.settings else { return }
        
        let updatedSettings = AppSettings(
            general: currentSettings.general,
            bible: currentSettings.bible,
            privacy: currentSettings.privacy,
            sync: currentSettings.sync,
            accessibility: currentSettings.accessibility,
            notifications: currentSettings.notifications,
            display: currentSettings.display,
            storage: currentSettings.storage,
            analytics: settings,
            lastModified: Date(),
            version: currentSettings.version
        )
        
        updateAppSettings(updatedSettings, updatedSections: [.analytics])
    }
    
    private func updateAppSettings(_ settings: AppSettings, updatedSections: [SettingsSection]) {
        updateState { state in
            state.isUpdating = true
            state.error = nil
        }
        
        Task {
            do {
                let input = UpdateAppSettingsInput(settings: settings, updatedSections: updatedSections)
                let updatedSettings = try await updateAppSettingsUseCase.execute(input)
                
                updateState { state in
                    state.isUpdating = false
                    state.settings = updatedSettings
                    state.lastUpdatedAt = Date()
                    state.successMessage = "Settings updated successfully"
                }
                
            } catch {
                updateState { state in
                    state.isUpdating = false
                    state.error = error
                }
            }
        }
    }
    
    private func updateIndividualSetting(key: String, value: Any) {
        Task {
            do {
                let input = UpdateIndividualSettingInput(key: key, value: value)
                try await updateIndividualSettingUseCase.execute(input)
                
                // Reload settings to reflect the change
                send(.loadSettings)
                
            } catch {
                updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - Settings Reset
    private func resetSettings(_ resetType: SettingsResetType) {
        updateState { state in
            state.isResetting = true
            state.error = nil
        }
        
        Task {
            do {
                let input = ResetSettingsInput(resetType: resetType)
                let resetSettings = try await resetSettingsUseCase.execute(input)
                
                updateState { state in
                    state.isResetting = false
                    state.settings = resetSettings
                    state.successMessage = "Settings reset successfully"
                }
                
            } catch {
                updateState { state in
                    state.isResetting = false
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - Settings Export/Import
    private func exportSettings(_ options: ExportSettingsOptions) {
        updateState { state in
            state.isExporting = true
            state.error = nil
        }
        
        Task {
            do {
                let input = ExportSettingsInput(
                    includedSections: options.includedSections,
                    excludeSensitiveData: options.excludeSensitiveData
                )
                let export = try await exportSettingsUseCase.execute(input)
                
                updateState { state in
                    state.isExporting = false
                    state.lastExport = export
                    state.successMessage = "Settings exported successfully"
                }
                
            } catch {
                updateState { state in
                    state.isExporting = false
                    state.error = error
                }
            }
        }
    }
    
    private func importSettings(_ export: SettingsExport, strategy: SettingsImportStrategy) {
        updateState { state in
            state.isImporting = true
            state.error = nil
        }
        
        Task {
            do {
                let input = ImportSettingsInput(export: export, strategy: strategy)
                let result = try await importSettingsUseCase.execute(input)
                
                updateState { state in
                    state.isImporting = false
                    state.lastImportResult = result
                    
                    if result.success {
                        state.successMessage = "Settings imported successfully"
                        // Reload settings to reflect changes
                        Task { [weak self] in
                            self?.send(.loadSettings)
                        }
                    } else {
                        state.error = LeavnError.validationError(message: "Import failed: \(result.errors.joined(separator: ", "))")
                    }
                }
                
            } catch {
                updateState { state in
                    state.isImporting = false
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - Settings Sync
    private func syncSettings(forceSync: Bool) {
        updateState { state in
            state.isSyncing = true
            state.error = nil
        }
        
        Task {
            do {
                let input = SyncSettingsInput(forceSync: forceSync)
                let status = try await syncSettingsUseCase.execute(input)
                
                updateState { state in
                    state.isSyncing = false
                    state.syncStatus = status
                    state.lastSyncedAt = Date()
                    
                    if status == .success {
                        state.successMessage = "Settings synced successfully"
                        // Reload settings to reflect any changes from sync
                        Task { [weak self] in
                            self?.send(.loadSettings)
                        }
                    }
                }
                
            } catch {
                updateState { state in
                    state.isSyncing = false
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - Settings History
    private func loadSettingsHistory() {
        updateState { state in
            state.isLoadingHistory = true
            state.error = nil
        }
        
        Task {
            do {
                let input = GetSettingsHistoryInput(limit: 50)
                let history = try await getSettingsHistoryUseCase.execute(input)
                
                updateState { state in
                    state.isLoadingHistory = false
                    state.settingsHistory = history
                }
                
            } catch {
                updateState { state in
                    state.isLoadingHistory = false
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - Settings Backup
    private func createBackup(name: String?) {
        updateState { state in
            state.isCreatingBackup = true
            state.error = nil
        }
        
        Task {
            do {
                let input = CreateSettingsBackupInput(name: name)
                let backup = try await createSettingsBackupUseCase.execute(input)
                
                updateState { state in
                    state.isCreatingBackup = false
                    state.availableBackups.append(backup)
                    state.successMessage = "Backup created successfully"
                }
                
            } catch {
                updateState { state in
                    state.isCreatingBackup = false
                    state.error = error
                }
            }
        }
    }
    
    private func restoreBackup(_ backup: SettingsBackup) {
        updateState { state in
            state.isRestoringBackup = true
            state.error = nil
        }
        
        Task {
            do {
                let input = ResetSettingsInput(resetType: .all)
                _ = try await resetSettingsUseCase.execute(input)
                
                // Update settings with backup data
                try await updateAppSettingsUseCase.execute(
                    UpdateAppSettingsInput(settings: backup.settings)
                )
                
                updateState { state in
                    state.isRestoringBackup = false
                    state.settings = backup.settings
                    state.successMessage = "Backup restored successfully"
                }
                
            } catch {
                updateState { state in
                    state.isRestoringBackup = false
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - Settings Validation
    private func validateCurrentSettings() {
        guard let settings = state.settings else { return }
        
        updateState { state in
            state.isValidating = true
            state.error = nil
        }
        
        Task {
            do {
                let input = ValidateSettingsInput(validationType: .full(settings))
                let validationErrors = try await validateSettingsUseCase.execute(input)
                
                updateState { state in
                    state.isValidating = false
                    state.validationErrors = validationErrors
                    
                    if validationErrors.isEmpty {
                        state.successMessage = "All settings are valid"
                    }
                }
                
            } catch {
                updateState { state in
                    state.isValidating = false
                    state.error = error
                }
            }
        }
    }
    
    // MARK: - UI State Management
    private func selectSection(_ section: SettingsSection) {
        updateState { state in
            state.selectedSection = section
        }
    }
    
    private func searchSettings(_ query: String) {
        updateState { state in
            state.searchQuery = query
            state.filteredSections = filterSections(query: query)
        }
    }
    
    private func clearError() {
        updateState { state in
            state.error = nil
        }
    }
    
    private func clearSuccess() {
        updateState { state in
            state.successMessage = nil
        }
    }
    
    // MARK: - Settings Observation
    private func startObservingSettings() {
        // This would need to be implemented with the actual repository
        // For now, it's a placeholder for observing settings changes
    }
    
    // MARK: - Helper Methods
    private func filterSections(query: String) -> [SettingsSection] {
        guard !query.isEmpty else {
            return SettingsSection.allCases
        }
        
        return SettingsSection.allCases.filter { section in
            section.displayName.localizedCaseInsensitiveContains(query)
        }
    }
}

// MARK: - Settings View State
public struct SettingsViewState: ViewState {
    // Loading States
    public var isLoading: Bool = false
    public var isUpdating: Bool = false
    public var isResetting: Bool = false
    public var isExporting: Bool = false
    public var isImporting: Bool = false
    public var isSyncing: Bool = false
    public var isLoadingHistory: Bool = false
    public var isCreatingBackup: Bool = false
    public var isRestoringBackup: Bool = false
    public var isValidating: Bool = false
    
    // Error and Success
    public var error: Error?
    public var successMessage: String?
    
    // Settings Data
    public var settings: AppSettings?
    public var validationErrors: [SettingsValidationError] = []
    
    // UI State
    public var selectedSection: SettingsSection = .general
    public var searchQuery: String = ""
    public var filteredSections: [SettingsSection] = SettingsSection.allCases
    
    // Sync Status
    public var syncStatus: SyncStatus = .idle
    public var lastSyncedAt: Date?
    
    // Export/Import
    public var lastExport: SettingsExport?
    public var lastImportResult: SettingsImportResult?
    
    // History and Backups
    public var settingsHistory: [SettingsChangeEvent] = []
    public var availableBackups: [SettingsBackup] = []
    
    // Timestamps
    public var lastLoadedAt: Date?
    public var lastUpdatedAt: Date?
    
    public init() {}
}

// MARK: - Settings View Events
public enum SettingsViewEvent {
    // Loading
    case loadSettings
    
    // Settings Updates
    case updateGeneralSettings(GeneralSettings)
    case updateBibleSettings(BibleSettings)
    case updatePrivacySettings(PrivacySettings)
    case updateSyncSettings(SyncSettings)
    case updateAccessibilitySettings(AccessibilitySettings)
    case updateNotificationSettings(NotificationSettings)
    case updateDisplaySettings(DisplaySettings)
    case updateStorageSettings(StorageSettings)
    case updateAnalyticsSettings(AnalyticsSettings)
    case updateIndividualSetting(String, Any)
    
    // Settings Management
    case resetSettings(SettingsResetType)
    case exportSettings(ExportSettingsOptions)
    case importSettings(SettingsExport, SettingsImportStrategy)
    case syncSettings(Bool) // forceSync
    
    // History and Backup
    case loadSettingsHistory
    case createBackup(String?) // name
    case restoreBackup(SettingsBackup)
    
    // Validation
    case validateCurrentSettings
    
    // UI Events
    case selectSection(SettingsSection)
    case searchSettings(String)
    case clearError
    case clearSuccess
}

// MARK: - Supporting Types
public struct ExportSettingsOptions {
    public let includedSections: [SettingsSection]?
    public let excludeSensitiveData: Bool
    
    public init(includedSections: [SettingsSection]? = nil, excludeSensitiveData: Bool = true) {
        self.includedSections = includedSections
        self.excludeSensitiveData = excludeSensitiveData
    }
}

// MARK: - Computed Properties
public extension SettingsViewState {
    var hasSettings: Bool {
        settings != nil
    }
    
    var hasValidationErrors: Bool {
        !validationErrors.isEmpty
    }
    
    var canSync: Bool {
        guard let settings = settings else { return false }
        return settings.sync.cloudSyncEnabled && !isSyncing
    }
    
    var canExport: Bool {
        hasSettings && !isExporting
    }
    
    var canImport: Bool {
        !isImporting
    }
    
    var canCreateBackup: Bool {
        hasSettings && !isCreatingBackup
    }
    
    var canRestoreBackup: Bool {
        !isRestoringBackup && !availableBackups.isEmpty
    }
    
    var isPerformingOperation: Bool {
        isLoading || isUpdating || isResetting || isExporting || 
        isImporting || isSyncing || isCreatingBackup || isRestoringBackup
    }
    
    var displayedSections: [SettingsSection] {
        searchQuery.isEmpty ? SettingsSection.allCases : filteredSections
    }
    
    var syncStatusDescription: String {
        switch syncStatus {
        case .idle: return "Ready to sync"
        case .syncing: return "Syncing..."
        case .success: return "Up to date"
        case .failed: return "Sync failed"
        }
    }
    
    var lastSyncDescription: String? {
        guard let lastSyncedAt = lastSyncedAt else { return nil }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Last synced \(formatter.localizedString(for: lastSyncedAt, relativeTo: Date()))"
    }
}