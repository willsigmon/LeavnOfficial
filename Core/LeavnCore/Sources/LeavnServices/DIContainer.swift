import Foundation
import Factory
import CoreData

// Note: NetworkingKit and PersistenceKit are part of the same package
// so we don't need to import them explicitly

#if canImport(AnalyticsKit)
import AnalyticsKit
#endif

// LeavnLibrary types are now available through LeavnCore

#if canImport(LeavnSettings)
import LeavnSettings
#endif

// AuthenticationModule types are now available through LeavnCore

// MARK: - DI Container Extension
public extension Container {
    // MARK: - Configuration
    var configuration: Factory<LeavnConfiguration> {
        self { LeavnConfiguration(apiKey: "default", environment: .production) }
            .singleton
    }
    
    // MARK: - Core Services
    
    /// Network service for all API communication
    /// Uses URLSession under the hood with configurable timeouts and retry logic
    var networkService: Factory<NetworkServiceProtocol> {
        self {
            #if canImport(NetworkingKit)
            DefaultNetworkService(configuration: self.configuration())
            #else
            MockNetworkService() // Stub for testing
            #endif
        }
        .singleton
    }
    
    var coreDataStack: Factory<NSPersistentContainer> {
        self {
            let container = NSPersistentContainer(name: "LeavnDataModel")
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load Core Data stack: \(error)")
                }
            }
            return container
        }
        .singleton
    }
    
    /// Analytics service for tracking user events and app usage
    /// Supports multiple providers (Firebase, Mixpanel, Console logging)
    var analyticsService: Factory<AnalyticsServiceProtocol> {
        self {
            #if canImport(AnalyticsKit)
            let service = AnalyticsService(configuration: self.configuration())
            #if DEBUG
            service.addProvider(ConsoleAnalyticsProvider())
            #endif
            return service
            #else
            MockAnalyticsService() // Stub that logs to console
            #endif
        }
        .singleton
    }
    
    // MARK: - Storage Services
    var userDefaultsStorage: Factory<Storage> {
        self { UserDefaultsStorage() }
            .singleton
    }
    
    var keychainStorage: Factory<SecureStorage> {
        self { KeychainStorage() }
            .singleton
    }
    
    var fileStorage: Factory<Storage> {
        self { try! FileStorage() }
            .singleton
    }
    
    var cacheStorage: Factory<Storage> {
        self { try! CacheStorage(configuration: self.configuration().cacheConfiguration) }
            .singleton
    }
    
    // MARK: - Feature Services
    
    /// Bible service for fetching and managing Bible content
    /// Integrates with ESV and Bible.com APIs
    var bibleService: Factory<BibleServiceProtocol> {
        self {
            DefaultBibleService(
                networkService: self.networkService(),
                esvAPIKey: self.configuration().esvAPIKey,
                bibleComAPIKey: self.configuration().bibleComAPIKey,
                cacheManager: self.bibleCacheManager()
            )
        }
        .singleton
    }
    
    /// Bible cache manager for offline access to scripture
    /// Uses Core Data in production, in-memory cache for tests
    var bibleCacheManager: Factory<BibleCacheManagerProtocol> {
        self {
            #if DEBUG
            // Use in-memory cache for testing/development
            InMemoryBibleCacheManager()
            #else
            // Use Core Data cache for production
            CoreDataBibleCacheManager(context: self.coreDataStack().viewContext)
            #endif
        }
        .singleton
    }
    
    /// ElevenLabs service for text-to-speech functionality
    /// Provides natural-sounding voice synthesis for Bible verses
    var elevenLabsService: Factory<ElevenLabsServiceProtocol> {
        self {
            guard !self.configuration().elevenLabsAPIKey.isEmpty else {
                return MockElevenLabsService() // Return mock if no API key
            }
            return DefaultElevenLabsService(
                networkService: self.networkService(),
                apiKey: self.configuration().elevenLabsAPIKey
            )
        }
        .singleton
    }
    
    /// Audio cache manager for storing generated speech files
    /// Reduces API calls and improves offline playback
    var audioCacheManager: Factory<AudioCacheManagerProtocol> {
        self {
            do {
                return try DefaultAudioCacheManager()
            } catch {
                print("Failed to create audio cache manager: \(error)")
                return InMemoryAudioCacheManager()
            }
        }
        .singleton
    }
    
    /// Audio service for playing Bible verses with voice synthesis
    /// Coordinates between ElevenLabs, cache, and Bible services
    var audioService: Factory<AudioServiceProtocol> {
        self {
            DefaultAudioService(
                elevenLabsService: self.elevenLabsService(),
                cacheManager: self.audioCacheManager(),
                bibleService: self.bibleService()
            )
        }
        .singleton
    }
    
    /// Authentication service for user sign-in and session management
    /// Stores tokens securely in keychain
    var authenticationService: Factory<AuthenticationServiceProtocol> {
        self {
            // Use mock until DefaultAuthenticationService is available
            MockAuthenticationService()
        }
        .singleton
    }
    
    var hapticManager: Factory<HapticManager> {
        self { DefaultHapticManager() }
            .singleton
    }
    
    /// Settings-aware haptic manager that respects user preferences
    /// Automatically enables/disables haptics based on settings
    var settingsAwareHapticManager: Factory<HapticManager> {
        self {
            #if canImport(LeavnSettings)
            SettingsAwareHapticManager(
                hapticManager: self.hapticManager(),
                settingsViewModel: self.settingsViewModel() as! SettingsViewModel
            )
            #else
            self.hapticManager() // Fallback to basic haptic manager
            #endif
        }
        .singleton
    }
    
    // MARK: - Library Module
    
    /// Library repository for managing saved verses, notes, and collections
    /// Syncs with cloud storage when online
    var libraryRepository: Factory<LibraryRepositoryProtocol> {
        self {
            // Use mock until DefaultLibraryRepository is available
            MockLibraryRepository()
        }
        .singleton
    }
    
    /// Use case for fetching library items with filtering and pagination
    var getLibraryItemsUseCase: Factory<GetLibraryItemsUseCaseProtocol> {
        self {
            // Use mock until GetLibraryItemsUseCase is available
            MockGetLibraryItemsUseCase()
        }
    }
    
    /// Use case for saving verses, notes, and other content to library
    var saveContentToLibraryUseCase: Factory<SaveContentToLibraryUseCaseProtocol> {
        self {
            // Use mock until SaveContentToLibraryUseCase is available
            MockSaveContentToLibraryUseCase()
        }
    }
    
    /// Use case for managing library collections
    var manageCollectionsUseCase: Factory<ManageCollectionsUseCaseProtocol> {
        self {
            // Use mock until ManageCollectionsUseCase is available
            MockManageCollectionsUseCase()
        }
    }
    
    /// Use case for managing offline downloads
    var manageDownloadsUseCase: Factory<ManageDownloadsUseCaseProtocol> {
        self {
            // Use mock until ManageDownloadsUseCase is available
            MockManageDownloadsUseCase()
        }
    }
    
    /// Use case for searching library content
    var searchLibraryUseCase: Factory<SearchLibraryUseCaseProtocol> {
        self {
            // Use mock until SearchLibraryUseCase is available
            MockSearchLibraryUseCase()
        }
    }
    
    /// Use case for retrieving library statistics
    var getLibraryStatisticsUseCase: Factory<GetLibraryStatisticsUseCaseProtocol> {
        self {
            // Use mock until GetLibraryStatisticsUseCase is available
            MockGetLibraryStatisticsUseCase()
        }
    }
    
    /// Use case for syncing library with cloud storage
    var syncLibraryUseCase: Factory<SyncLibraryUseCaseProtocol> {
        self {
            // Use mock until SyncLibraryUseCase is available
            MockSyncLibraryUseCase()
        }
    }
    
    /// Library view model factory
    /// Creates a new instance with all required dependencies
    var libraryViewModel: Factory<LibraryViewModelProtocol> {
        self {
            #if canImport(LeavnLibrary)
            LibraryViewModel(
                libraryRepository: self.libraryRepository(),
                analyticsService: self.analyticsService(),
                getLibraryItemsUseCase: self.getLibraryItemsUseCase(),
                saveContentToLibraryUseCase: self.saveContentToLibraryUseCase(),
                manageCollectionsUseCase: self.manageCollectionsUseCase(),
                manageDownloadsUseCase: self.manageDownloadsUseCase(),
                searchLibraryUseCase: self.searchLibraryUseCase(),
                getLibraryStatisticsUseCase: self.getLibraryStatisticsUseCase(),
                syncLibraryUseCase: self.syncLibraryUseCase()
            )
            #else
            MockLibraryViewModel()
            #endif
        }
    }
    
    // MARK: - Settings Module
    
    /// Local storage adapter for settings persistence
    var settingsLocalStorage: Factory<SettingsLocalStorage> {
        self { StorageSettingsLocalStorage(storage: self.userDefaultsStorage()) }
            .singleton
    }
    
    var settingsSecureStorage: Factory<SettingsSecureStorage> {
        self { SecureStorageSettingsSecureStorage(storage: self.keychainStorage()) }
            .singleton
    }
    
    /// Settings repository for app preferences and configuration
    /// Handles validation, migration, and secure storage of sensitive settings
    var settingsRepository: Factory<SettingsRepositoryProtocol> {
        self {
            #if canImport(LeavnSettings)
            DefaultSettingsRepository(
                localStorage: self.settingsLocalStorage(),
                cloudStorage: nil, // Will be configured later if needed
                secureStorage: self.settingsSecureStorage(),
                validator: DefaultSettingsValidator(),
                migrator: DefaultSettingsMigrator(),
                encryptor: nil, // Will be configured later if needed
                configuration: .default
            )
            #else
            MockSettingsRepository()
            #endif
        }
        .singleton
    }
    
    var getAppSettingsUseCase: Factory<Any> {
        self { 
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            GetAppSettingsUseCase(settingsRepository: self.settingsRepository())
            */
        }
    }
    
    var updateAppSettingsUseCase: Factory<Any> {
        self {
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            UpdateAppSettingsUseCase(
                settingsRepository: self.settingsRepository(),
                analyticsService: self.analyticsService()
            )
            */
        }
    }
    
    var updateIndividualSettingUseCase: Factory<Any> {
        self {
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            UpdateIndividualSettingUseCase(
                settingsRepository: self.settingsRepository(),
                analyticsService: self.analyticsService()
            )
            */
        }
    }
    
    var resetSettingsUseCase: Factory<Any> {
        self {
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            ResetSettingsUseCase(
                settingsRepository: self.settingsRepository(),
                analyticsService: self.analyticsService()
            )
            */
        }
    }
    
    var exportSettingsUseCase: Factory<Any> {
        self { 
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            ExportSettingsUseCase(settingsRepository: self.settingsRepository())
            */
        }
    }
    
    var importSettingsUseCase: Factory<Any> {
        self {
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            ImportSettingsUseCase(
                settingsRepository: self.settingsRepository(),
                analyticsService: self.analyticsService()
            )
            */
        }
    }
    
    var syncSettingsUseCase: Factory<Any> {
        self {
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            SyncSettingsUseCase(
                settingsRepository: self.settingsRepository(),
                analyticsService: self.analyticsService()
            )
            */
        }
    }
    
    var getSettingsHistoryUseCase: Factory<Any> {
        self { 
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            GetSettingsHistoryUseCase(settingsRepository: self.settingsRepository())
            */
        }
    }
    
    var createSettingsBackupUseCase: Factory<Any> {
        self { 
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            CreateSettingsBackupUseCase(settingsRepository: self.settingsRepository())
            */
        }
    }
    
    var validateSettingsUseCase: Factory<Any> {
        self { 
            // TODO: Restore this code when the required module is available.
            fatalError("Not implemented: missing dependency")
            /*
            ValidateSettingsUseCase(settingsRepository: self.settingsRepository())
            */
        }
    }
    
    /// Settings view model for UI binding
    /// Provides reactive settings management with SwiftUI integration
    var settingsViewModel: Factory<SettingsViewModelProtocol> {
        self {
            #if canImport(LeavnSettings)
            SettingsViewModel(
                getAppSettingsUseCase: self.getAppSettingsUseCase() as! GetAppSettingsUseCase,
                updateAppSettingsUseCase: self.updateAppSettingsUseCase() as! UpdateAppSettingsUseCase,
                updateIndividualSettingUseCase: self.updateIndividualSettingUseCase() as! UpdateIndividualSettingUseCase,
                resetSettingsUseCase: self.resetSettingsUseCase() as! ResetSettingsUseCase,
                exportSettingsUseCase: self.exportSettingsUseCase() as! ExportSettingsUseCase,
                importSettingsUseCase: self.importSettingsUseCase() as! ImportSettingsUseCase,
                syncSettingsUseCase: self.syncSettingsUseCase() as! SyncSettingsUseCase,
                getSettingsHistoryUseCase: self.getSettingsHistoryUseCase() as! GetSettingsHistoryUseCase,
                createSettingsBackupUseCase: self.createSettingsBackupUseCase() as! CreateSettingsBackupUseCase,
                validateSettingsUseCase: self.validateSettingsUseCase() as! ValidateSettingsUseCase,
                analyticsService: self.analyticsService()
            )
            #else
            MockSettingsViewModel()
            #endif
        }
    }
    
    // MARK: - Authentication Module
    
    /// Authentication repository for user management
    var authRepository: Factory<AuthRepositoryProtocol> {
        self {
            // Use mock until DefaultAuthRepository is available
            MockAuthRepository()
        }
        .singleton
    }
    
    /// Sign in use case
    var signInUseCase: Factory<SignInUseCaseProtocol> {
        self {
            #if canImport(AuthenticationModule)
            SignInUseCase(
                authRepository: self.authRepository(),
                analyticsService: self.analyticsService()
            )
            #else
            MockSignInUseCase()
            #endif
        }
    }
    
    /// Sign up use case
    var signUpUseCase: Factory<SignUpUseCaseProtocol> {
        self {
            #if canImport(AuthenticationModule)
            SignUpUseCase(
                authRepository: self.authRepository(),
                analyticsService: self.analyticsService()
            )
            #else
            MockSignUpUseCase()
            #endif
        }
    }
    
    /// Sign out use case
    var signOutUseCase: Factory<SignOutUseCaseProtocol> {
        self {
            #if canImport(AuthenticationModule)
            SignOutUseCase(
                authRepository: self.authRepository(),
                analyticsService: self.analyticsService()
            )
            #else
            MockSignOutUseCase()
            #endif
        }
    }
    
    /// Reset password use case
    var resetPasswordUseCase: Factory<ResetPasswordUseCaseProtocol> {
        self {
            #if canImport(AuthenticationModule)
            ResetPasswordUseCase(
                authRepository: self.authRepository(),
                analyticsService: self.analyticsService()
            )
            #else
            MockResetPasswordUseCase()
            #endif
        }
    }
    
    /// Update profile use case
    var updateProfileUseCase: Factory<UpdateProfileUseCaseProtocol> {
        self {
            #if canImport(AuthenticationModule)
            UpdateProfileUseCase(
                authRepository: self.authRepository(),
                analyticsService: self.analyticsService()
            )
            #else
            MockUpdateProfileUseCase()
            #endif
        }
    }
    
    /// Verify email use case
    var verifyEmailUseCase: Factory<VerifyEmailUseCaseProtocol> {
        self {
            #if canImport(AuthenticationModule)
            VerifyEmailUseCase(
                authRepository: self.authRepository(),
                analyticsService: self.analyticsService()
            )
            #else
            MockVerifyEmailUseCase()
            #endif
        }
    }
    
    /// Authentication view model factory
    var authViewModel: Factory<AuthViewModelProtocol> {
        self {
            #if canImport(AuthenticationModule)
            AuthViewModel(
                authRepository: self.authRepository(),
                analyticsService: self.analyticsService(),
                signInUseCase: self.signInUseCase(),
                signUpUseCase: self.signUpUseCase(),
                signOutUseCase: self.signOutUseCase(),
                resetPasswordUseCase: self.resetPasswordUseCase(),
                updateProfileUseCase: self.updateProfileUseCase(),
                verifyEmailUseCase: self.verifyEmailUseCase()
            )
            #else
            MockAuthViewModel()
            #endif
        }
    }
}

// MARK: - Service Locator
public final class ServiceLocator {
    public static let shared = ServiceLocator()
    
    private init() {}
    
    public func configure(with configuration: LeavnConfiguration) {
        Container.shared.configuration.register { configuration }
        
        // Setup error handling
        setupGlobalErrorHandling()
        
        // Validate configuration
        validateConfiguration(configuration)
    }
    
    public func reset() {
        Container.shared.reset()
    }
    
    private func setupGlobalErrorHandling() {
        // Set up global error handling for all services
        NSSetUncaughtExceptionHandler { exception in
            let error = LeavnError.systemError("Uncaught exception: \(exception.description)")
            // Track error if analytics is available
            #if canImport(AnalyticsKit)
            Container.shared.analyticsService().trackError(error, properties: [
                "exception_name": exception.name.rawValue,
                "exception_reason": exception.reason ?? "Unknown"
            ])
            #else
            print("[Error] Uncaught exception: \(exception)")
            #endif
        }
    }
    
    private func validateConfiguration(_ configuration: LeavnConfiguration) {
        // Validate required API keys
        if configuration.environment == .production {
            assert(!configuration.esvAPIKey.isEmpty, "ESV API key is required for production")
            assert(!configuration.elevenLabsAPIKey.isEmpty, "ElevenLabs API key is required for production")
        }
    }
}

// MARK: - Injectable Property Wrapper
@propertyWrapper
public struct Injected<T> {
    private let keyPath: KeyPath<Container, Factory<T>>
    
    public init(_ keyPath: KeyPath<Container, Factory<T>>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: T {
        Container.shared[keyPath: keyPath]()
    }
}

// MARK: - Lazy Injectable Property Wrapper
@propertyWrapper
public struct LazyInjected<T> {
    private let keyPath: KeyPath<Container, Factory<T>>
    private var instance: T?
    
    public init(_ keyPath: KeyPath<Container, Factory<T>>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: T {
        mutating get {
            if instance == nil {
                instance = Container.shared[keyPath: keyPath]()
            }
            return instance!
        }
    }
}

// MARK: - Settings Storage Adapters
private final class StorageSettingsLocalStorage: SettingsLocalStorage {
    private let storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    func loadAppSettings() async throws -> AppSettings? {
        try await storage.load(AppSettings.self, forKey: "app_settings")
    }
    
    func saveAppSettings(_ settings: AppSettings) async throws {
        try await storage.save(settings, forKey: "app_settings")
    }
    
    func getSetting<T: Codable>(key: String, type: T.Type) async throws -> T? {
        try await storage.load(type, forKey: key)
    }
    
    func setSetting<T: Codable>(key: String, value: T) async throws {
        try await storage.save(value, forKey: key)
    }
    
    func removeSetting(key: String) async throws {
        try await storage.remove(forKey: key)
    }
    
    func getAllSettings() async throws -> [String: Any] {
        // Return a dictionary representation of current app settings
        guard let settings = try await loadAppSettings() else {
            return [:]
        }
        
        // Convert settings to dictionary using JSONSerialization
        let data = try JSONEncoder().encode(settings)
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json as? [String: Any] ?? [:]
    }
    
    func getSettingsHistory(limit: Int, offset: Int) async throws -> [SettingsChangeEvent] {
        try await storage.load([SettingsChangeEvent].self, forKey: "settings_history") ?? []
    }
    
    func getSettingChanges(for key: String, limit: Int) async throws -> [SettingsChangeEvent] {
        let allChanges = try await getSettingsHistory(limit: 1000, offset: 0)
        return Array(allChanges.filter { $0.settingKey == key }.prefix(limit))
    }
    
    func trackSettingChange(_ event: SettingsChangeEvent) async throws {
        var history = try await getSettingsHistory(limit: 1000, offset: 0)
        history.append(event)
        // Keep only the latest 1000 changes
        if history.count > 1000 {
            history = Array(history.suffix(1000))
        }
        try await storage.save(history, forKey: "settings_history")
    }
    
    func saveBackup(_ backup: SettingsBackup) async throws {
        var backups = try await getBackups(limit: 100)
        backups.append(backup)
        try await storage.save(backups, forKey: "settings_backups")
    }
    
    func getBackups(limit: Int) async throws -> [SettingsBackup] {
        let allBackups = try await storage.load([SettingsBackup].self, forKey: "settings_backups") ?? []
        return Array(allBackups.prefix(limit))
    }
    
    func deleteBackup(_ backupId: String) async throws {
        var backups = try await getBackups(limit: 100)
        backups.removeAll { $0.id == backupId }
        try await storage.save(backups, forKey: "settings_backups")
    }
    
    func getSettingsVersion() async throws -> String? {
        try await storage.load(String.self, forKey: "settings_version")
    }
}

private final class SecureStorageSettingsSecureStorage: SettingsSecureStorage {
    private let storage: SecureStorage
    
    init(storage: SecureStorage) {
        self.storage = storage
    }
    
    func store<T: Codable>(_ value: T, forKey key: String) async throws {
        try await storage.save(value, forKey: key)
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        try await storage.load(type, forKey: key)
    }
    
    func remove(forKey key: String) async throws {
        try await storage.remove(forKey: key)
    }
}

// TODO: When all modules are restored, uncomment and restore stubs and dependencies above.
