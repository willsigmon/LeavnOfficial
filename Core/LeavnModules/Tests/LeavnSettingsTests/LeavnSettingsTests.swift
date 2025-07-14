import XCTest
@testable import LeavnSettings

final class LeavnSettingsTests: XCTestCase {
    var sut: SettingsViewModel!
    
    override func setUp() {
        super.setUp()
        sut = SettingsViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSettingsViewModelInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testDefaultSettings() throws {
        // Test default settings initialization
        XCTAssertNotNil(sut.userSettings)
    }
    
    func testUpdateTheme() async throws {
        // Test theme update functionality
        let newTheme = "dark"
        await sut.updateTheme(to: newTheme)
        XCTAssertEqual(sut.userSettings.theme, newTheme)
    }
}