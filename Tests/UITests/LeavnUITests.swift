import XCTest

final class LeavnUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Add UI test assertions here
    }
}