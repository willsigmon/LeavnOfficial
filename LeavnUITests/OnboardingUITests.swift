import XCTest

class OnboardingUITests: LeavnUITests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Force app to show onboarding
        app.launchArguments.append("--reset-onboarding")
        app.launch()
    }
    
    func testOnboardingFlow() throws {
        // Test splash screen appears
        let splashView = app.otherElements["splashView"]
        XCTAssertTrue(waitForElement(splashView, timeout: 2), "Splash screen should appear on launch")
        
        // Wait for onboarding to appear
        let onboardingView = app.otherElements["onboardingView"]
        XCTAssertTrue(waitForElement(onboardingView, timeout: 5), "Onboarding should appear after splash")
        
        // Test Continue button on first onboarding screen
        tapButton(withIdentifier: "onboardingContinueButton")
        
        // Test navigation through onboarding screens
        // (Add more specific tests based on your onboarding flow)
        
        // Test Complete Onboarding button
        tapButton(withIdentifier: "completeOnboardingButton")
        
        // Verify main tab view appears
        let mainTabView = app.tabBars["mainTabBar"]
        XCTAssertTrue(waitForElement(mainTabView, timeout: 5), "Main tab bar should appear after onboarding")
        
        // Verify all tabs are present
        XCTAssertTrue(app.tabBars.buttons["homeTab"].exists, "Home tab should exist")
        XCTAssertTrue(app.tabBars.buttons["bibleTab"].exists, "Bible tab should exist")
        XCTAssertTrue(app.tabBars.buttons["searchTab"].exists, "Search tab should exist")
        XCTAssertTrue(app.tabBars.buttons["libraryTab"].exists, "Library tab should exist")
        XCTAssertTrue(app.tabBars.buttons["settingsTab"].exists, "Settings tab should exist")
        
        takeScreenshot(name: "Onboarding_Complete")
    }
    
    func testSkipOnboarding() throws {
        // Test skip button if available
        let skipButton = app.buttons["skipOnboardingButton"]
        if waitForElement(skipButton, timeout: 3) {
            skipButton.tap()
            
            // Verify main view appears
            let mainTabView = app.tabBars["mainTabBar"]
            XCTAssertTrue(waitForElement(mainTabView, timeout: 5), "Main tab bar should appear after skipping onboarding")
        }
    }
    
    func testOnboardingDismissButton() throws {
        // Wait for onboarding
        let onboardingView = app.otherElements["onboardingView"]
        XCTAssertTrue(waitForElement(onboardingView, timeout: 5))
        
        // Test dismiss button if available
        let dismissButton = app.buttons["dismissOnboardingButton"]
        if waitForElement(dismissButton, timeout: 2) {
            dismissButton.tap()
            
            // Verify onboarding is dismissed
            let mainTabView = app.tabBars["mainTabBar"]
            XCTAssertTrue(waitForElement(mainTabView, timeout: 5), "Main view should appear after dismissing onboarding")
        }
    }
}