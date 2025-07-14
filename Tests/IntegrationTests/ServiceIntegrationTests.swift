import XCTest
import LeavnCore
import LeavnServices
import Factory
@testable import Leavn

final class ServiceIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Setup test configuration
        let testConfig = LeavnConfiguration(
            apiKey: "test-api-key",
            environment: .development,
            analyticsEnabled: false,
            esvAPIKey: "test-esv-key",
            bibleComAPIKey: "test-bible-com-key",
            elevenLabsAPIKey: "test-elevenlabs-key"
        )
        ServiceLocator.shared.configure(with: testConfig)
    }
    
    override func tearDown() {
        super.tearDown()
        ServiceLocator.shared.reset()
    }
    
    // MARK: - Bible Service Tests
    func testBibleServiceIntegration() async throws {
        // Given
        let bibleService = Container.shared.bibleService()
        
        // When/Then - Test translations fetch
        do {
            let translations = try await bibleService.fetchTranslations()
            XCTAssertFalse(translations.isEmpty, "Should have available translations")
        } catch {
            XCTFail("Failed to fetch translations: \(error)")
        }
        
        // When/Then - Test book catalog
        do {
            let books = try await bibleService.getBooks(includeApocrypha: false)
            XCTAssertEqual(books.count, 66, "Should have 66 canonical books")
        } catch {
            XCTFail("Failed to fetch books: \(error)")
        }
    }
    
    // MARK: - Audio Service Tests
    func testAudioServiceIntegration() async throws {
        // Given
        let audioService = Container.shared.audioService()
        let testChapter = AudioChapter(
            book: "Genesis",
            chapter: 1,
            translation: "ESV",
            voiceId: "test-voice",
            voiceName: "Test Voice",
            verses: [
                AudioVerse(verseNumber: 1, text: "In the beginning, God created the heavens and the earth.")
            ]
        )
        
        // When
        XCTAssertFalse(audioService.isPlaying, "Should not be playing initially")
        XCTAssertEqual(audioService.playbackSpeed, 1.0, "Default playback speed should be 1.0")
        
        // Test queue management
        audioService.addToQueue(testChapter)
        XCTAssertEqual(audioService.playbackQueue.count, 1, "Should have one item in queue")
        
        audioService.clearQueue()
        XCTAssertTrue(audioService.playbackQueue.isEmpty, "Queue should be empty after clear")
    }
    
    // MARK: - Haptic Service Tests
    func testHapticServiceIntegration() async throws {
        // Given
        let hapticManager = Container.shared.settingsAwareHapticManager()
        
        // When/Then - Test haptic feedback (won't actually trigger on simulator)
        do {
            try await hapticManager.impact(.light)
            try await hapticManager.notification(.success)
            try await hapticManager.selection()
        } catch {
            // Haptics might not be available on all devices
            print("Haptic feedback not available: \(error)")
        }
    }
    
    // MARK: - Settings Service Tests
    func testSettingsServiceIntegration() async throws {
        // Given
        let settingsViewModel = Container.shared.settingsViewModel()
        
        // When - Load settings
        await settingsViewModel.loadSettings()
        
        // Then
        XCTAssertNotNil(settingsViewModel.appSettings, "Should have loaded app settings")
        XCTAssertFalse(settingsViewModel.isLoading, "Should not be loading after completion")
        
        // Test individual setting update
        let originalHaptic = settingsViewModel.appSettings?.accessibility.hapticFeedback ?? false
        await settingsViewModel.updateSetting(key: "accessibility.hapticFeedback", value: !originalHaptic)
        
        // Verify update
        await settingsViewModel.loadSettings()
        XCTAssertEqual(
            settingsViewModel.appSettings?.accessibility.hapticFeedback,
            !originalHaptic,
            "Haptic setting should be toggled"
        )
    }
    
    // MARK: - Library Service Tests
    func testLibraryServiceIntegration() async throws {
        // Given
        let libraryViewModel = Container.shared.libraryViewModel()
        
        // When - Load library
        await libraryViewModel.loadLibrary()
        
        // Then
        XCTAssertFalse(libraryViewModel.isLoading, "Should not be loading after completion")
        
        // Test search
        libraryViewModel.searchQuery = "test"
        await libraryViewModel.performSearch()
        
        // Test statistics
        let stats = await libraryViewModel.getStatistics()
        XCTAssertNotNil(stats, "Should have library statistics")
    }
    
    // MARK: - Error Recovery Tests
    func testErrorRecoveryIntegration() async throws {
        // Given
        let errorRecovery = DefaultErrorRecoveryService()
        
        // Test network error recovery
        let networkError = LeavnError.networkError(underlying: nil)
        let networkStrategy = errorRecovery.handleError(networkError)
        
        switch networkStrategy {
        case .retry(let attempts, let delay):
            XCTAssertGreaterThan(attempts, 0, "Should have retry attempts")
            XCTAssertGreaterThan(delay, 0, "Should have retry delay")
        default:
            XCTFail("Network error should trigger retry strategy")
        }
        
        // Test unauthorized error recovery
        let authError = LeavnError.unauthorized
        let authStrategy = errorRecovery.handleError(authError)
        
        switch authStrategy {
        case .authenticate:
            // Expected
            break
        default:
            XCTFail("Unauthorized error should trigger authentication")
        }
    }
    
    // MARK: - Full Integration Test
    func testFullServiceIntegration() async throws {
        // This test simulates a complete user flow
        
        // 1. Load settings
        let settingsViewModel = Container.shared.settingsViewModel()
        await settingsViewModel.loadSettings()
        
        // 2. Fetch Bible data
        let bibleService = Container.shared.bibleService()
        let translations = try await bibleService.fetchTranslations()
        XCTAssertFalse(translations.isEmpty)
        
        // 3. Track analytics event
        let analyticsService = Container.shared.analyticsService()
        analyticsService.track(event: CommonAnalyticsEvent.screenView(
            screenName: "Integration Test",
            screenClass: "ServiceIntegrationTests"
        ))
        
        // 4. Test cache managers
        let bibleCache = Container.shared.bibleCacheManager()
        let cacheSize = try await bibleCache.getCacheSize()
        XCTAssertGreaterThanOrEqual(cacheSize, 0, "Cache size should be non-negative")
        
        // 5. Verify all services are properly initialized
        XCTAssertNotNil(Container.shared.networkService(), "Network service should be initialized")
        XCTAssertNotNil(Container.shared.authenticationService(), "Auth service should be initialized")
        XCTAssertNotNil(Container.shared.elevenLabsService(), "ElevenLabs service should be initialized")
        XCTAssertNotNil(Container.shared.audioService(), "Audio service should be initialized")
    }
}

// MARK: - Performance Tests
extension ServiceIntegrationTests {
    func testServiceInitializationPerformance() {
        measure {
            // Reset and reinitialize
            ServiceLocator.shared.reset()
            
            let config = LeavnConfiguration(
                apiKey: "perf-test",
                environment: .development
            )
            ServiceLocator.shared.configure(with: config)
            
            // Access services to trigger initialization
            _ = Container.shared.networkService()
            _ = Container.shared.bibleService()
            _ = Container.shared.audioService()
            _ = Container.shared.settingsViewModel()
        }
    }
}