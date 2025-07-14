import XCTest
import Factory
@testable import LeavnCore
@testable import LeavnServices
@testable import PersistenceKit

final class DIContainerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset container to clean state
        Container.shared.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        Container.shared.reset()
    }
    
    // MARK: - Configuration Tests
    
    func testConfigurationRegistration() {
        // Given
        let testConfig = LeavnConfiguration(
            apiKey: "test-key",
            environment: .development
        )
        
        // When
        Container.shared.configuration.register { testConfig }
        let resolved = Container.shared.configuration()
        
        // Then
        XCTAssertEqual(resolved.apiKey, "test-key")
        XCTAssertEqual(resolved.environment, .development)
    }
    
    func testServiceLocatorConfiguration() {
        // Given
        let config = LeavnConfiguration.development
        
        // When
        ServiceLocator.shared.configure(with: config)
        let resolved = Container.shared.configuration()
        
        // Then
        XCTAssertEqual(resolved.environment, .development)
    }
    
    // MARK: - Core Services Tests
    
    func testNetworkServiceResolution() {
        // When
        let service = Container.shared.networkService()
        
        // Then
        XCTAssertNotNil(service)
        XCTAssertTrue(service is NetworkServiceProtocol)
    }
    
    func testAnalyticsServiceResolution() {
        // When
        let service = Container.shared.analyticsService()
        
        // Then
        XCTAssertNotNil(service)
        XCTAssertTrue(service is AnalyticsServiceProtocol)
    }
    
    func testCoreDataStackResolution() {
        // When
        let stack = Container.shared.coreDataStack()
        
        // Then
        XCTAssertNotNil(stack)
        XCTAssertEqual(stack.name, "LeavnDataModel")
    }
    
    // MARK: - Storage Services Tests
    
    func testUserDefaultsStorageResolution() {
        // When
        let storage = Container.shared.userDefaultsStorage()
        
        // Then
        XCTAssertNotNil(storage)
        XCTAssertTrue(storage is Storage)
    }
    
    func testKeychainStorageResolution() {
        // When
        let storage = Container.shared.keychainStorage()
        
        // Then
        XCTAssertNotNil(storage)
        XCTAssertTrue(storage is SecureStorage)
    }
    
    func testFileStorageResolution() {
        // When
        let storage = Container.shared.fileStorage()
        
        // Then
        XCTAssertNotNil(storage)
        XCTAssertTrue(storage is Storage)
    }
    
    func testCacheStorageResolution() {
        // When
        let storage = Container.shared.cacheStorage()
        
        // Then
        XCTAssertNotNil(storage)
        XCTAssertTrue(storage is Storage)
    }
    
    // MARK: - Feature Services Tests
    
    func testBibleServiceResolution() {
        // When
        let service = Container.shared.bibleService()
        
        // Then
        XCTAssertNotNil(service)
        XCTAssertTrue(service is BibleServiceProtocol)
    }
    
    func testAudioServiceResolution() {
        // When
        let service = Container.shared.audioService()
        
        // Then
        XCTAssertNotNil(service)
        XCTAssertTrue(service is AudioServiceProtocol)
    }
    
    func testHapticManagerResolution() {
        // When
        let manager = Container.shared.hapticManager()
        
        // Then
        XCTAssertNotNil(manager)
        XCTAssertTrue(manager is HapticManager)
    }
    
    // MARK: - Singleton Behavior Tests
    
    func testNetworkServiceIsSingleton() {
        // When
        let service1 = Container.shared.networkService()
        let service2 = Container.shared.networkService()
        
        // Then
        XCTAssertTrue(service1 === service2 as AnyObject)
    }
    
    func testAnalyticsServiceIsSingleton() {
        // When
        let service1 = Container.shared.analyticsService()
        let service2 = Container.shared.analyticsService()
        
        // Then
        XCTAssertTrue(service1 === service2 as AnyObject)
    }
    
    // MARK: - Property Wrapper Tests
    
    func testInjectedPropertyWrapper() {
        // Given
        class TestClass {
            @Injected(\.networkService) var networkService
        }
        
        // When
        let instance = TestClass()
        
        // Then
        XCTAssertNotNil(instance.networkService)
        XCTAssertTrue(instance.networkService is NetworkServiceProtocol)
    }
    
    func testLazyInjectedPropertyWrapper() {
        // Given
        class TestClass {
            @LazyInjected(\.analyticsService) var analyticsService
        }
        
        // When
        let instance = TestClass()
        let service = instance.analyticsService
        
        // Then
        XCTAssertNotNil(service)
        XCTAssertTrue(service is AnalyticsServiceProtocol)
    }
    
    // MARK: - Mock Service Tests
    
    func testMockServiceRegistration() {
        // Given
        Container.shared.networkService.register { MockNetworkService() }
        
        // When
        let service = Container.shared.networkService()
        
        // Then
        XCTAssertTrue(service is MockNetworkService)
    }
    
    // MARK: - Storage Adapter Tests
    
    func testSettingsLocalStorageAdapter() async throws {
        // Given
        let storage = Container.shared.settingsLocalStorage()
        let testSettings = AppSettings.default
        
        // When
        try await storage.saveAppSettings(testSettings)
        let loaded = try await storage.loadAppSettings()
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.id, testSettings.id)
    }
    
    func testSettingsSecureStorageAdapter() async throws {
        // Given
        let storage = Container.shared.settingsSecureStorage()
        let testData = "sensitive-data"
        
        // When
        try await storage.store(testData, forKey: "test-key")
        let retrieved = try await storage.retrieve(String.self, forKey: "test-key")
        
        // Then
        XCTAssertEqual(retrieved, testData)
        
        // Cleanup
        try await storage.remove(forKey: "test-key")
    }
    
    // MARK: - Integration Tests
    
    func testBibleServiceWithCache() async throws {
        // Given
        let bibleService = Container.shared.bibleService()
        let cacheManager = Container.shared.bibleCacheManager()
        
        // When
        let verse = try await bibleService.getDailyVerse()
        try await cacheManager.cacheVerse(verse)
        let cached = try await cacheManager.getCachedVerse(
            reference: verse.reference,
            translation: verse.translation
        )
        
        // Then
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.id, verse.id)
    }
    
    // MARK: - Error Handling Tests
    
    func testServiceErrorHandling() async {
        // Given
        Container.shared.networkService.register { MockNetworkService() }
        let service = Container.shared.networkService()
        
        // When/Then
        do {
            let _: String = try await service.request(
                Endpoint(path: "/test", method: .get)
            )
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is LeavnError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testContainerResolutionPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = Container.shared.networkService()
            }
        }
    }
    
    func testSingletonCachePerformance() {
        // First resolution creates the instance
        _ = Container.shared.analyticsService()
        
        // Measure subsequent resolutions
        measure {
            for _ in 0..<10000 {
                _ = Container.shared.analyticsService()
            }
        }
    }
}

// MARK: - Test Helpers

extension DIContainerTests {
    func resetAndRegisterMocks() {
        Container.shared.reset()
        Container.shared.networkService.register { MockNetworkService() }
        Container.shared.analyticsService.register { MockAnalyticsService() }
        Container.shared.bibleService.register { MockBibleService() }
    }
}