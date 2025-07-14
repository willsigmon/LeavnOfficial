import XCTest
@testable import Leavn

final class LeavnTests: XCTestCase {
    
    func testAppLaunch() throws {
        // Test app launch
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    func testAppConfiguration() throws {
        // Test app configuration
        XCTAssertNotNil(Bundle.main.bundleIdentifier)
        XCTAssertNotNil(Bundle.main.infoDictionary?["CFBundleShortVersionString"])
    }
}