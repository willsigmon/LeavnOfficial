import XCTest

class MainTabUITests: LeavnUITests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Skip onboarding for main app tests
        app.launchArguments.append("--skip-onboarding")
        app.launch()
    }
    
    func testAllTabsExistAndAreClickable() throws {
        // Wait for main tab view
        let mainTabBar = app.tabBars["mainTabBar"]
        XCTAssertTrue(waitForElement(mainTabBar, timeout: 5), "Main tab bar should be visible")
        
        // Test Home Tab
        let homeTab = app.tabBars.buttons["homeTab"]
        XCTAssertTrue(homeTab.exists, "Home tab should exist")
        homeTab.tap()
        verifyViewExists(withIdentifier: "homeView")
        takeScreenshot(name: "Home_Tab")
        
        // Test Bible Tab
        let bibleTab = app.tabBars.buttons["bibleTab"]
        XCTAssertTrue(bibleTab.exists, "Bible tab should exist")
        bibleTab.tap()
        verifyViewExists(withIdentifier: "bibleView")
        takeScreenshot(name: "Bible_Tab")
        
        // Test Search Tab
        let searchTab = app.tabBars.buttons["searchTab"]
        XCTAssertTrue(searchTab.exists, "Search tab should exist")
        searchTab.tap()
        verifyViewExists(withIdentifier: "searchView")
        takeScreenshot(name: "Search_Tab")
        
        // Test Library Tab
        let libraryTab = app.tabBars.buttons["libraryTab"]
        XCTAssertTrue(libraryTab.exists, "Library tab should exist")
        libraryTab.tap()
        verifyViewExists(withIdentifier: "libraryView")
        takeScreenshot(name: "Library_Tab")
        
        // Test Settings Tab
        let settingsTab = app.tabBars.buttons["settingsTab"]
        XCTAssertTrue(settingsTab.exists, "Settings tab should exist")
        settingsTab.tap()
        verifyViewExists(withIdentifier: "settingsView")
        takeScreenshot(name: "Settings_Tab")
    }
    
    func testTabSelection() throws {
        let mainTabBar = app.tabBars["mainTabBar"]
        XCTAssertTrue(waitForElement(mainTabBar, timeout: 5))
        
        // Select each tab and verify it's selected
        let tabs = ["homeTab", "bibleTab", "searchTab", "libraryTab", "settingsTab"]
        
        for tabIdentifier in tabs {
            let tab = app.tabBars.buttons[tabIdentifier]
            tab.tap()
            
            // Verify tab is selected
            XCTAssertTrue(tab.isSelected, "\(tabIdentifier) should be selected after tapping")
            
            // Verify other tabs are not selected
            for otherTabId in tabs where otherTabId != tabIdentifier {
                let otherTab = app.tabBars.buttons[otherTabId]
                XCTAssertFalse(otherTab.isSelected, "\(otherTabId) should not be selected")
            }
        }
    }
    
    func testTabPersistence() throws {
        // Select a specific tab
        app.tabBars.buttons["bibleTab"].tap()
        
        // Force app to background and foreground
        XCUIDevice.shared.press(.home)
        sleep(1)
        app.activate()
        
        // Verify same tab is still selected
        XCTAssertTrue(app.tabBars.buttons["bibleTab"].isSelected, "Bible tab should remain selected after backgrounding")
    }
}