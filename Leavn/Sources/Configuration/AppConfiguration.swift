import Foundation

// import Factory - Removed external dependency

// MARK: - Environment Type
public enum AppEnvironment {
    case development
    case production
}

// MARK: - Configuration Types
public struct LeavnConfiguration {
    let apiKey: String
    let environment: AppEnvironment
    let analyticsEnabled: Bool
    let cacheConfiguration: CacheConfiguration
    let esvAPIKey: String
    let bibleComAPIKey: String
    let elevenLabsAPIKey: String
    let audioNarrationEnabled: Bool
    let offlineModeEnabled: Bool
}

public struct CacheConfiguration: Sendable {
    static let `default` = CacheConfiguration()
}

// MARK: - App Configuration
public final class AppConfiguration: @unchecked Sendable {
    // MARK: - Singleton
    public static let shared = AppConfiguration()
    
    // MARK: - Environment Configuration
    private let environment: AppEnvironment
    
    // MARK: - API Keys (should be loaded from secure storage in production)
    private struct APIKeys {
        static let esv = ProcessInfo.processInfo.environment["ESV_API_KEY"] ?? ""
        static let bibleCom = ProcessInfo.processInfo.environment["BIBLE_COM_API_KEY"] ?? ""
        static let elevenLabs = ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? ""
        static let leavn = ProcessInfo.processInfo.environment["LEAVN_API_KEY"] ?? "default-key"
    }
    
    // MARK: - Initialization
    private init() {
        #if DEBUG
        self.environment = .development
        #else
        self.environment = .production
        #endif
    }
    
    // MARK: - Public Methods
    public func setupApplication() {
        // Configure dependency injection
        configureDependencyInjection()
        
        // Setup error handling
        setupErrorHandling()
        
        // Initialize services
        initializeServices()
    }
    
    // MARK: - Private Methods
    private func configureDependencyInjection() {
        let configuration = LeavnConfiguration(
            apiKey: APIKeys.leavn,
            environment: environment,
            analyticsEnabled: environment != .development,
            cacheConfiguration: .default,
            esvAPIKey: APIKeys.esv,
            bibleComAPIKey: APIKeys.bibleCom,
            elevenLabsAPIKey: APIKeys.elevenLabs,
            audioNarrationEnabled: true,
            offlineModeEnabled: true
        )
        
        ServiceLocator.shared.configure(with: configuration)
    }
    
    private func setupErrorHandling() {
        // Global error handling is set up in ServiceLocator
    }
    
    private func initializeServices() {
        Task {
            do {
                // Pre-warm critical services
                // TODO: Replace with actual service initialization when Factory is available
                // _ = Container.shared.networkService()
                // _ = Container.shared.analyticsService()
                // _ = Container.shared.hapticManager()
                
                // Load initial data if needed
                await loadInitialData()
            } catch {
                print("Failed to initialize services: \(error)")
            }
        }
    }
    
    private func loadInitialData() async {
        // Load any initial data needed for the app
        do {
            // Pre-fetch Bible translations
            // TODO: Replace with actual service calls when Factory is available
            // let translations = try await Container.shared.bibleService().fetchTranslations()
            // print("Loaded \(translations.count) Bible translations")
            
            // Pre-fetch default settings
            // _ = try await Container.shared.getAppSettingsUseCase().execute(())
            
        } catch {
            print("Failed to load initial data: \(error)")
            // TODO: Replace with actual service call when Factory is available
            // Container.shared.analyticsService().trackError(error)
        }
    }
}

// MARK: - Production Configuration
extension AppConfiguration {
    public struct ProductionConfig {
        // Feature flags
        public static let enableAudioNarration = true
        public static let enableOfflineMode = true
        public static let enableHapticFeedback = true
        public static let enableApocrypha = true
        
        // Cache settings
        public static let maxCacheSize: Int64 = 500 * 1024 * 1024 // 500MB
        public static let cacheExpirationDays = 30
        
        // Audio settings
        public static let defaultPlaybackSpeed: Float = 1.0
        public static let maxAudioCacheSize: Int64 = 200 * 1024 * 1024 // 200MB
        
        // Network settings
        public static let apiTimeoutSeconds: TimeInterval = 30
        public static let maxRetryAttempts = 3
        
        // Analytics settings
        public static let analyticsFlushInterval: TimeInterval = 60
        public static let analyticsQueueSize = 100
    }
}

// MARK: - Error Monitoring
extension AppConfiguration {
    public func handleUncaughtException(_ exception: NSException) {
        _ = LeavnError.systemError("Uncaught exception: \(exception.description)")
        
        // Log to analytics
        // TODO: Replace with actual service call when Factory is available
        // Container.shared.analyticsService().trackError(error, additionalInfo: [
        //     "exception_name": exception.name.rawValue,
        //     "exception_reason": exception.reason ?? "Unknown",
        //     "call_stack": exception.callStackSymbols.joined(separator: "\n")
        // ])
        
        // In production, you might want to show a user-friendly error dialog
        #if !DEBUG
        // Show error recovery UI
        #endif
    }
}
