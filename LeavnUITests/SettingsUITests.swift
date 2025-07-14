import XCTest

class SettingsUITests: LeavnUITests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launchArguments.append("--skip-onboarding")
        app.launch()
        
        // Navigate to Settings tab
        app.tabBars.buttons["settingsTab"].tap()
        let settingsView = app.otherElements["settingsView"]
        XCTAssertTrue(waitForElement(settingsView, timeout: 5), "Settings view should be visible")
    }
    
    func testSettingsNavigation() throws {
        // Test Account Settings
        let accountButton = app.cells["accountSettingsCell"]
        if waitForElement(accountButton, timeout: 3) {
            accountButton.tap()
            
            let accountView = app.otherElements["accountSettingsView"]
            XCTAssertTrue(waitForElement(accountView, timeout: 3), "Account settings view should appear")
            
            // Navigate back
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        // Test Notifications Settings
        let notificationsButton = app.cells["notificationSettingsCell"]
        if waitForElement(notificationsButton, timeout: 3) {
            notificationsButton.tap()
            
            let notificationsView = app.otherElements["notificationSettingsView"]
            XCTAssertTrue(waitForElement(notificationsView, timeout: 3), "Notification settings view should appear")
            
            // Test notification toggles
            let dailyVerseToggle = app.switches["dailyVerseNotificationToggle"]
            if waitForElement(dailyVerseToggle, timeout: 2) {
                let initialValue = dailyVerseToggle.value as? String == "1"
                dailyVerseToggle.tap()
                let newValue = dailyVerseToggle.value as? String == "1"
                XCTAssertNotEqual(initialValue, newValue, "Toggle value should change")
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        takeScreenshot(name: "Settings_Main_View")
    }
    
    func testAppearanceSettings() throws {
        let appearanceButton = app.cells["appearanceSettingsCell"]
        if waitForElement(appearanceButton, timeout: 3) {
            appearanceButton.tap()
            
            let appearanceView = app.otherElements["appearanceSettingsView"]
            XCTAssertTrue(waitForElement(appearanceView, timeout: 3), "Appearance settings view should appear")
            
            // Test theme selection
            let darkModeButton = app.buttons["darkThemeButton"]
            if waitForElement(darkModeButton, timeout: 2) {
                darkModeButton.tap()
                takeScreenshot(name: "Settings_Dark_Theme")
            }
            
            let lightModeButton = app.buttons["lightThemeButton"]
            if waitForElement(lightModeButton, timeout: 2) {
                lightModeButton.tap()
                takeScreenshot(name: "Settings_Light_Theme")
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    func testPrivacySettings() throws {
        let privacyButton = app.cells["privacySettingsCell"]
        if waitForElement(privacyButton, timeout: 3) {
            privacyButton.tap()
            
            let privacyView = app.otherElements["privacySettingsView"]
            XCTAssertTrue(waitForElement(privacyView, timeout: 3), "Privacy settings view should appear")
            
            // Test analytics toggle
            let analyticsToggle = app.switches["analyticsToggle"]
            if waitForElement(analyticsToggle, timeout: 2) {
                analyticsToggle.tap()
            }
            
            // Test privacy policy link
            let privacyPolicyButton = app.buttons["privacyPolicyButton"]
            if waitForElement(privacyPolicyButton, timeout: 2) {
                privacyPolicyButton.tap()
                
                // Verify web view or safari opens
                sleep(2)
                app.activate() // Return to app
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    func testAboutSection() throws {
        // Scroll to bottom to find About section
        app.tables.firstMatch.swipeUp()
        
        let aboutButton = app.cells["aboutCell"]
        if waitForElement(aboutButton, timeout: 3) {
            aboutButton.tap()
            
            let aboutView = app.otherElements["aboutView"]
            XCTAssertTrue(waitForElement(aboutView, timeout: 3), "About view should appear")
            
            // Verify version info exists
            let versionLabel = app.staticTexts["appVersionLabel"]
            XCTAssertTrue(waitForElement(versionLabel, timeout: 2), "App version should be displayed")
            
            takeScreenshot(name: "Settings_About")
            
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    func testSignOut() throws {
        // Scroll to find sign out button
        app.tables.firstMatch.swipeUp()
        
        let signOutButton = app.buttons["signOutButton"]
        if waitForElement(signOutButton, timeout: 3) {
            signOutButton.tap()
            
            // Verify confirmation alert
            let alert = app.alerts.firstMatch
            XCTAssertTrue(waitForElement(alert, timeout: 3), "Sign out confirmation should appear")
            
            // Cancel sign out
            let cancelButton = alert.buttons["Cancel"]
            if waitForElement(cancelButton, timeout: 2) {
                cancelButton.tap()
                
                // Verify still in settings
                let settingsView = app.otherElements["settingsView"]
                XCTAssertTrue(waitForElement(settingsView, timeout: 3), "Should remain in settings after canceling")
            }
        }
    }
    
    func testSettingsSearch() throws {
        // Check if settings has search
        let searchField = app.searchFields["settingsSearchField"]
        if waitForElement(searchField, timeout: 2) {
            searchField.tap()
            searchField.typeText("notification")
            
            // Verify filtered results
            let notificationCell = app.cells["notificationSettingsCell"]
            XCTAssertTrue(waitForElement(notificationCell, timeout: 3), "Notification settings should appear in search results")
            
            // Clear search
            let clearButton = app.buttons["Clear text"]
            if waitForElement(clearButton, timeout: 2) {
                clearButton.tap()
            }
        }
    }
}