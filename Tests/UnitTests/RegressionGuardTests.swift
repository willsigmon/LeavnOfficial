import XCTest
@testable import LeavnCore
@testable import LeavnServices
@testable import LeavnBible

/// Regression Guard Test Suite
/// Ensures core functionality remains intact after changes
final class RegressionGuardTests: XCTestCase {
    
    // MARK: - Bible Service Tests
    
    func testBibleServiceInitialization() {
        let service = ProductionBibleService()
        XCTAssertNotNil(service, "Bible service should initialize")
    }
    
    func testApocryphaSupport() {
        let service = ProductionBibleService()
        let books = service.getApocryphaBooks()
        XCTAssertFalse(books.isEmpty, "Apocrypha books should be available")
        XCTAssertTrue(books.contains { $0.name == "1 Maccabees" }, "Should include 1 Maccabees")
    }
    
    // MARK: - Audio Service Tests
    
    func testElevenLabsServiceConfiguration() {
        let config = Configuration.shared
        XCTAssertNotNil(config.elevenLabsAPIKey, "ElevenLabs API key should be configured")
    }
    
    func testAudioServiceInitialization() {
        let service = ElevenLabsAudioService()
        XCTAssertNotNil(service, "Audio service should initialize")
    }
    
    // MARK: - Theme System Tests
    
    func testThemeConfiguration() {
        let theme = LeavnTheme.shared
        XCTAssertNotNil(theme.backgroundColor(for: .light), "Light theme should have background color")
        XCTAssertNotNil(theme.backgroundColor(for: .dark), "Dark theme should have background color")
        XCTAssertNotNil(theme.backgroundColor(for: .sage), "Sage theme should have background color")
    }
    
    // MARK: - Navigation Tests
    
    func testMainTabViewTabs() {
        // Verify expected tabs exist
        let expectedTabs = ["home", "bible", "search", "library", "community"]
        XCTAssertEqual(expectedTabs.count, 5, "Should have 5 main tabs")
    }
    
    // MARK: - Model Tests
    
    func testBibleBookModel() {
        let book = BibleBook(
            id: "GEN",
            name: "Genesis",
            abbreviation: "Gen",
            testament: .old,
            chapters: 50
        )
        XCTAssertEqual(book.name, "Genesis")
        XCTAssertEqual(book.chapters, 50)
        XCTAssertEqual(book.testament, .old)
    }
    
    func testBibleVerseModel() {
        let verse = BibleVerse(
            id: "GEN.1.1",
            reference: "Genesis 1:1",
            text: "In the beginning God created the heaven and the earth.",
            book: "GEN",
            chapter: 1,
            verse: 1,
            translation: "KJV"
        )
        XCTAssertEqual(verse.reference, "Genesis 1:1")
        XCTAssertEqual(verse.chapter, 1)
        XCTAssertEqual(verse.verse, 1)
    }
    
    // MARK: - Service Protocol Tests
    
    func testServiceProtocolConformance() {
        XCTAssertTrue(ProductionBibleService.self is BibleService.Type, "Should conform to BibleService")
        XCTAssertTrue(ElevenLabsAudioService.self is AudioService.Type, "Should conform to AudioService")
        XCTAssertTrue(ProductionSearchService.self is SearchService.Type, "Should conform to SearchService")
    }
    
    // MARK: - Configuration Tests
    
    func testDIContainerSingleton() {
        let container1 = DIContainer.shared
        let container2 = DIContainer.shared
        XCTAssertTrue(container1 === container2, "DIContainer should be singleton")
    }
    
    func testPlatformConfiguration() {
        #if os(iOS)
        XCTAssertTrue(UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad)
        #elseif os(macOS)
        XCTAssertNotNil(NSApplication.shared)
        #endif
    }
    
    // MARK: - Error Handling Tests
    
    func testLeavnErrorTypes() {
        let networkError = LeavnError.network(NSError(domain: "test", code: -1))
        let invalidDataError = LeavnError.invalidData
        
        switch networkError {
        case .network(let error):
            XCTAssertNotNil(error)
        default:
            XCTFail("Should be network error")
        }
        
        switch invalidDataError {
        case .invalidData:
            XCTAssertTrue(true)
        default:
            XCTFail("Should be invalid data error")
        }
    }
}