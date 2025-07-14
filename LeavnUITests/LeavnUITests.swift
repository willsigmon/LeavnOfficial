import XCTest

final class LeavnUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testBibleNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test Bible tab navigation
        let bibleTab = app.tabBars.buttons["Bible"]
        XCTAssertTrue(bibleTab.exists)
        bibleTab.tap()
        
        // Verify Bible screen is displayed
        let bibleTitle = app.navigationBars["Bible"]
        XCTAssertTrue(bibleTitle.exists)
    }
    
    func testSearchFunctionality() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test Search tab
        let searchTab = app.tabBars.buttons["Search"]
        XCTAssertTrue(searchTab.exists)
        searchTab.tap()
        
        // Test search field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("love")
        
        // Verify search results appear
        let searchResults = app.tables.firstMatch
        XCTAssertTrue(searchResults.waitForExistence(timeout: 5))
    }
}