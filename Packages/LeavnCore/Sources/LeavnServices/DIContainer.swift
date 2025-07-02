import Foundation
import SwiftUI
import Combine
import LeavnCore
import OSLog

/// Enhanced Dependency Injection Container for the entire app
@MainActor
public final class DIContainer: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = DIContainer()
    
    // MARK: - Services
    @Published public private(set) var bibleService: BibleServiceProtocol?
    @Published public private(set) var searchService: SearchServiceProtocol?
    @Published public private(set) var libraryService: LibraryServiceProtocol?
    @Published public private(set) var userService: UserServiceProtocol?
    @Published public private(set) var syncService: SyncServiceProtocol?
    @Published public private(set) var aiService: AIServiceProtocol?
    @Published public private(set) var cacheService: CacheServiceProtocol?
    @Published public private(set) var networkService: NetworkServiceProtocol?
    @Published public private(set) var analyticsService: AnalyticsServiceProtocol?
    @Published public private(set) var notificationService: NotificationService?
    @Published public private(set) var lifeSituationsEngine: LifeSituationsEngineProtocol?

    // MARK: - Coordinators
    @Published public private(set) var navigationCoordinator: NavigationCoordinator?
    
    // MARK: - State
    @Published public private(set) var isInitialized = false
    @Published public private(set) var initializationError: Error?
    @Published public private(set) var initializationProgress: Double = 0.0
    
    // MARK: - Configuration
    private let isProduction = Bundle.main.object(forInfoDictionaryKey: "IS_PRODUCTION") as? Bool ?? false
    private let logger = Logger(subsystem: "com.leavn3", category: "DIContainer")
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Register all dependencies
    public func registerDependencies() async {
        await MainActor.run {
            self.initializationProgress = 0.1
        }
        
        // Register services in dependency order
        await registerCoreServices()
        await registerDataServices()
        await registerFeatureServices()
        await registerCoordinators()
        
        await MainActor.run {
            self.initializationProgress = 0.5
        }
    }
    
    /// Initialize all services
    public func initialize() async {
        guard !isInitialized else { return }
        
        await registerDependencies()
        
        await MainActor.run {
            self.initializationProgress = 0.6
        }
        
        // Initialize services in dependency order
        await initializeServices()
        
        await MainActor.run {
            self.isInitialized = true
            self.initializationProgress = 1.0
        }
        
        print("🎯 DIContainer fully initialized")
    }
    
    /// Initialize all registered services
    public func initializeServices() async {
        let services: [(String, ServiceProtocol?)] = [
            ("Cache", cacheService),
            ("Network", networkService),
            ("User", userService),
            ("Bible", bibleService),
            ("Search", searchService),
            ("Library", libraryService),
            ("Sync", syncService),
            ("AI", aiService),
            ("Analytics", analyticsService),
            ("LifeSituations", lifeSituationsEngine)
        ]
        
        let totalServices = Double(services.count)
        var completedServices = 0.0
        
        for (name, service) in services {
            if let service = service {
                do {
                    try await service.initialize()
                    print("✅ \(name) service initialized")
                } catch {
                    print("⚠️ \(name) service initialization failed: \(error)")
                }
            }
            
            completedServices += 1
            await MainActor.run {
                self.initializationProgress = 0.6 + (completedServices / totalServices) * 0.4
            }
        }
    }
    
    // MARK: - Service Registration
    
    private func registerCoreServices() async {
        // Cache service (no dependencies)
        do {
            cacheService = try ProductionCacheService.init() // Explicit initializer call to avoid ambiguity
        } catch {
            print("⚠️ Failed to create cache service: \(error)")
            // Use a simple in-memory cache as fallback
            cacheService = InMemoryCacheService()
        }
        
        self.networkService = DefaultNetworkService()
        try? await self.networkService?.initialize()

        // Notification Service
        self.notificationService = NotificationService.shared
        _ = await self.notificationService?.requestPermission()

        // Analytics Service
        if isProduction {
            analyticsService = ProductionAnalyticsService()  // Using production service
        } else {
            // Create a simple mock for development
            analyticsService = DevelopmentAnalyticsService()
        }
    }
    
    private func registerDataServices() async {
        // Bible service - use the already registered cacheService
        guard let cacheService = cacheService else {
            logger.error("Cache service not available for Bible service")
            return
        }
        bibleService = GetBibleService(cacheManager: cacheService)
        
        // User service
        userService = SimpleUserService(cacheService: cacheService)
        
        // Library service - needs userService, so create it after
        guard let userService = userService else {
            logger.error("User service not available for Library service")
            return
        }
        libraryService = ProductionLibraryService(userService: userService, cacheService: cacheService)
    }
    
    private func registerFeatureServices() async {
        // Ensure all required services are available before proceeding.
        guard let bibleService = bibleService,
              let cacheService = cacheService,
              let userService = userService,
              let libraryService = libraryService else {
            logger.error("Cannot register feature services due to missing dependencies.")
            return
        }

        // Register Search Service
        searchService = ProductionSearchService(
            bibleService: bibleService,
            cacheService: cacheService
        )
        logger.info("✅ Production Search Service registered.")

        // Register AI Service
        if AIConfiguration.isEnabled {
            let apiKey = AppConfiguration.APIKeys.openAIKey
            if !apiKey.isEmpty {
                aiService = ProductionAIService(
                    apiKey: apiKey,
                    baseURL: URL(string: "https://api.openai.com/v1")!,
                    urlSession: .shared,
                    cacheService: cacheService
                )
                logger.info("✅ Production AI Service registered.")
            } else {
                logger.warning("⚠️ No valid API key configured. Using MockAIService.")
                aiService = MockAIService()
            }
        } else {
            logger.info("🤖 AI Service is disabled. Using MockAIService.")
            aiService = MockAIService()
        }

        // Register Sync Service
        if #available(iOS 14.0, macOS 11.0, watchOS 7.0, *) {
            syncService = ProductionCloudSyncService(
                userService: userService,
                libraryService: libraryService
            )
            logger.info("✅ Production Cloud Sync Service registered.")
        } else {
            syncService = LegacySyncService()
            logger.info("⚠️ Using legacy sync service for older OS.")
        }

        // Register Analytics Service
        if isProduction {
            analyticsService = ProductionAnalyticsService()
            logger.info("✅ Production Analytics Service registered.")
        } else {
            analyticsService = DevelopmentAnalyticsService()
            logger.info("✅ Development Analytics Service registered.")
        }
        
        // Register Life Situations Engine
        lifeSituationsEngine = LifeSituationsEngine(
            bibleService: bibleService,
            cacheService: cacheService
        )
        logger.info("✅ Life Situations Engine registered.")
    }
    
    private func registerCoordinators() async {
        navigationCoordinator = NavigationCoordinator()
    }
    
    // MARK: - Service Access Helpers
    
    public func requireBibleService() -> BibleServiceProtocol {
        guard let service = bibleService else { fatalError("BibleService not available") }
        return service
    }

    public func requireSearchService() -> SearchServiceProtocol {
        guard let service = searchService else { fatalError("SearchService not available") }
        return service
    }

    public func requireLibraryService() -> LibraryServiceProtocol {
        guard let service = libraryService else { fatalError("LibraryService not available") }
        return service
    }

    public func requireUserService() -> UserServiceProtocol {
        guard let service = userService else { fatalError("UserService not available") }
        return service
    }

    public func requireSyncService() -> SyncServiceProtocol {
        guard let service = syncService else { fatalError("SyncService not available") }
        return service
    }

    public func requireCacheService() -> CacheServiceProtocol {
        guard let service = cacheService else { fatalError("CacheService not available") }
        return service
    }

    public func requireNetworkService() -> NetworkServiceProtocol {
        guard let service = networkService else { fatalError("NetworkService not available") }
        return service
    }

    public func requireAnalyticsService() -> AnalyticsServiceProtocol {
        guard let service = analyticsService else { fatalError("AnalyticsService not available") }
        return service
    }
    
    public func requireAIService() -> AIServiceProtocol {
        guard let service = aiService else {
            // If AI is critical, fatalError is appropriate.
            // If not, you might return a mock/null object.
            fatalError("Required AIService is not available. Check configuration and API keys.")
        }
        return service
    }
    
    // MARK: - Development Helpers
    
    #if DEBUG
    public func resetServices() async {
        isInitialized = false
        initializationError = nil
        initializationProgress = 0.0
        
        // Clear all services
        bibleService = nil
        searchService = nil
        libraryService = nil
        userService = nil
        syncService = nil
        aiService = nil
        cacheService = nil
        networkService = nil
        analyticsService = nil
        navigationCoordinator = nil
        
        await initialize()
    }
    
    public func getServiceStatus() -> [String: Bool] {
        return [
            "Bible": bibleService != nil,
            "Search": searchService != nil,
            "Library": libraryService != nil,
            "User": userService != nil,
            "Sync": syncService != nil,
            "AI": aiService != nil,
            "Cache": cacheService != nil,
            "Network": networkService != nil,
            "Analytics": analyticsService != nil
        ]
    }
    #endif
}

// MARK: - AI Configuration

public struct AIConfiguration {
    public static var isEnabled: Bool {
        #if DEBUG
        return UserDefaults.standard.bool(forKey: "ai_enabled")
        #else
        return Bundle.main.object(forInfoDictionaryKey: "AI_ENABLED") as? Bool ?? false
        #endif
    }
    
    public static var apiKey: String? {
        // In a real app, this should load from a secure source
        return nil
    }
}

// MARK: - Environment Key

private struct DIContainerKey: EnvironmentKey {
    static var defaultValue: DIContainer {
        MainActor.assumeIsolated {
            DIContainer.shared
        }
    }
}

public extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}

// MARK: - SwiftUI View Extension

public extension View {
    func withDIContainer() -> some View {
        self.environmentObject(DIContainer.shared)
    }
}

// MARK: - Development/Legacy Service Implementations

private final class DevelopmentAnalyticsService: AnalyticsServiceProtocol {
    func initialize() async throws {
        print("📊 Development Analytics Service initialized")
    }
    
    func track(event: AnalyticsEvent) async {
        #if DEBUG
        print("[DEV Analytics] \(event.name): \(event.parameters ?? [:])")
        #endif
    }
    
    func setUserProperty(_ key: String, value: String) async {
        #if DEBUG
        print("[DEV Analytics] User property: \(key) = \(value)")
        #endif
    }
    
    func flush() async {}
}

private final class LegacySyncService: SyncServiceProtocol {
    func initialize() async throws {
        print("☁️ Legacy Sync Service initialized (no-op)")
    }
    
    func syncData() async throws {
        // No-op for legacy OS versions
    }
    
    func enableSync() async throws {
        throw LeavnError.notSupported("Sync requires iOS 14.0+")
    }
    
    func disableSync() async throws {}
    
    func getSyncStatus() async -> SyncStatus {
        return .disabled
    }
    
    func forceSyncUser() async throws {
        throw LeavnError.notSupported("Sync requires iOS 14.0+")
    }
    
    func forceSyncLibrary() async throws {
        throw LeavnError.notSupported("Sync requires iOS 14.0+")
    }
}

// MARK: - In-Memory Cache Service

// Updated to require T: Codable & Sendable for Swift 6 concurrency compliance
private actor InMemoryCacheService: CacheServiceProtocol {
    private var cache: [String: (value: Data, expiration: Date?)] = [:]
    
    func initialize() async throws {
        print("📦 In-Memory Cache Service initialized")
    }
    
    func get<T: Codable & Sendable>(_ key: String, type: T.Type) async -> T? {
        guard let entry = cache[key] else { return nil }
        
        if let expiration = entry.expiration, expiration < Date() {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: entry.value)
    }
    
    func set<T: Codable & Sendable>(_ key: String, value: T, expirationDate: Date?) async {
        guard let data = try? JSONEncoder().encode(value) else { return }
        cache[key] = (data, expirationDate)
    }
    
    func remove(_ key: String) async {
        cache.removeValue(forKey: key)
    }
    
    func clear() async {
        cache.removeAll()
    }
    
    func getCacheSize() async -> Int64 {
        return Int64(cache.values.reduce(0) { $0 + $1.value.count })
    }
    
    func clearExpiredItems() async {
        let now = Date()
        cache = cache.filter { _, value in
            guard let expiration = value.expiration else { return true }
            return expiration > now
        }
    }
}

// MARK: - Default Network Service

private final class DefaultNetworkService: NetworkServiceProtocol {
    private let session = URLSession.shared
    
    func initialize() async throws {
        print("🌐 Default Network Service initialized")
    }
    
    func isConnected() async -> Bool {
        // Simple connectivity check
        let url = URL(string: "https://www.apple.com")!
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3.0
        
        do {
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: endpoint.path) else {
            throw ServiceError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let params = endpoint.parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.networkError("HTTP error")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func download(_ url: URL) async throws -> Data {
        let (data, _) = try await session.data(from: url)
        return data
    }
    
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        // Simple publisher that checks connectivity periodically
        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .map { _ in true } // Simplified - always returns true
            .prepend(true)
            .eraseToAnyPublisher()
    }
}

