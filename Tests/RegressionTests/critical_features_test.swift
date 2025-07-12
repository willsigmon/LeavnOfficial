import XCTest
@testable import Leavn

/// Critical Features Regression Test Suite
/// Ensures all major app features remain functional across updates
final class CriticalFeaturesTests: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Tab Navigation Tests
    
    func testAllTabsAreAccessible() throws {
        // Test each tab is present and tappable
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
        
        let tabs = [
            ("Home", "home"),
            ("Bible", "book"),
            ("Library", "books.vertical"),
            ("Search", "magnifyingglass"),
            ("Community", "person.3")
        ]
        
        for (title, icon) in tabs {
            let tab = tabBar.buttons[title]
            XCTAssertTrue(tab.exists, "\(title) tab should exist")
            
            tab.tap()
            
            // Verify we're on the correct screen
            let navTitle = app.navigationBars.firstMatch.identifier
            XCTAssertTrue(navTitle.contains(title) || app.staticTexts[title].exists,
                         "Should navigate to \(title) screen")
        }
    }
    
    // MARK: - Bible Feature Tests
    
    func testBibleBookNavigation() throws {
        // Navigate to Bible tab
        app.tabBars.buttons["Bible"].tap()
        
        // Wait for book list to load
        let bookList = app.collectionViews.firstMatch
        XCTAssertTrue(bookList.waitForExistence(timeout: 5), "Bible book list should appear")
        
        // Test selecting a book
        let genesisCell = bookList.cells.containing(.staticText, identifier: "Genesis").firstMatch
        XCTAssertTrue(genesisCell.exists, "Genesis should be in book list")
        
        genesisCell.tap()
        
        // Verify chapter list appears
        let chapterList = app.collectionViews["ChapterList"]
        XCTAssertTrue(chapterList.waitForExistence(timeout: 3), "Chapter list should appear")
        
        // Select chapter 1
        let chapter1 = chapterList.cells.containing(.staticText, identifier: "1").firstMatch
        chapter1.tap()
        
        // Verify Bible text appears
        let bibleText = app.scrollViews.containing(.staticText, identifier: "In the beginning").firstMatch
        XCTAssertTrue(bibleText.waitForExistence(timeout: 5), "Bible text should load")
    }
    
    func testApocryphaAccess() throws {
        // Navigate to Bible tab
        app.tabBars.buttons["Bible"].tap()
        
        // Look for Apocrypha section or toggle
        let apocryphaToggle = app.switches["Show Apocrypha"]
        if apocryphaToggle.exists {
            apocryphaToggle.tap()
        }
        
        // Check for an Apocryphal book
        let bookList = app.collectionViews.firstMatch
        let tobitCell = bookList.cells.containing(.staticText, identifier: "Tobit").firstMatch
        
        XCTAssertTrue(tobitCell.waitForExistence(timeout: 3), "Apocryphal books should be accessible")
    }
    
    // MARK: - Audio Feature Tests
    
    func testAudioPlayback() throws {
        // Navigate to Bible and open a chapter
        app.tabBars.buttons["Bible"].tap()
        
        let bookList = app.collectionViews.firstMatch
        bookList.cells.firstMatch.tap()
        
        let chapterList = app.collectionViews["ChapterList"]
        chapterList.cells.firstMatch.tap()
        
        // Look for audio controls
        let playButton = app.buttons["Play Audio"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5), "Audio play button should exist")
        
        // Test play functionality
        playButton.tap()
        
        // Verify audio controls appear
        let pauseButton = app.buttons["Pause Audio"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 3), "Pause button should appear when playing")
        
        // Test pause
        pauseButton.tap()
        XCTAssertTrue(playButton.waitForExistence(timeout: 3), "Play button should reappear when paused")
    }
    
    // MARK: - LifeSituations Tests
    
    func testLifeSituationsDisplay() throws {
        // Go to Home tab
        app.tabBars.buttons["Home"].tap()
        
        // Look for LifeSituations section
        let scrollView = app.scrollViews.firstMatch
        let lifeSituationsHeader = scrollView.staticTexts["Life Situations"]
        
        // Scroll to find it if needed
        var attempts = 0
        while !lifeSituationsHeader.exists && attempts < 5 {
            scrollView.swipeUp()
            attempts += 1
        }
        
        XCTAssertTrue(lifeSituationsHeader.exists, "LifeSituations section should be on Home tab")
        
        // Check for at least one situation card
        let situationCard = scrollView.cells.firstMatch
        XCTAssertTrue(situationCard.exists, "Should have at least one life situation card")
        
        // Test tapping a situation
        situationCard.tap()
        
        // Verify detail view appears
        let detailView = app.scrollViews["LifeSituationDetail"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 3), "Life situation detail should open")
    }
    
    // MARK: - Share Feature Tests
    
    func testShareFunctionality() throws {
        // Navigate to Bible verse
        app.tabBars.buttons["Bible"].tap()
        
        let bookList = app.collectionViews.firstMatch
        bookList.cells.firstMatch.tap()
        
        let chapterList = app.collectionViews["ChapterList"]
        chapterList.cells.firstMatch.tap()
        
        // Long press on a verse to get share options
        let verseText = app.staticTexts.matching(identifier: "VerseText").firstMatch
        verseText.press(forDuration: 1.0)
        
        // Look for share button in context menu
        let shareButton = app.buttons["Share"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 3), "Share option should appear")
        
        shareButton.tap()
        
        // Verify share sheet appears
        let shareSheet = app.otherElements["ActivityListView"]
        XCTAssertTrue(shareSheet.waitForExistence(timeout: 3), "Share sheet should appear")
        
        // Verify common share options
        XCTAssertTrue(app.cells["Copy"].exists, "Copy option should be available")
        XCTAssertTrue(app.cells["Messages"].exists || app.cells["Mail"].exists,
                     "Messaging options should be available")
        
        // Dismiss share sheet
        app.buttons["Close"].tap()
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    func testTabSwitchingPerformance() throws {
        let tabBar = app.tabBars.firstMatch
        
        measure {
            // Cycle through all tabs
            tabBar.buttons["Bible"].tap()
            tabBar.buttons["Library"].tap()
            tabBar.buttons["Search"].tap()
            tabBar.buttons["Community"].tap()
            tabBar.buttons["Home"].tap()
        }
    }
    
    // MARK: - Search Tests
    
    func testSearchFunctionality() throws {
        // Navigate to Search tab
        app.tabBars.buttons["Search"].tap()
        
        // Find search field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3), "Search field should exist")
        
        // Type a search query
        searchField.tap()
        searchField.typeText("love")
        
        // Tap search button
        app.buttons["Search"].tap()
        
        // Verify results appear
        let resultsTable = app.tables["SearchResults"]
        XCTAssertTrue(resultsTable.waitForExistence(timeout: 5), "Search results should appear")
        
        // Verify at least one result
        XCTAssertGreaterThan(resultsTable.cells.count, 0, "Should have search results for 'love'")
    }
    
    // MARK: - Library Tests
    
    func testLibraryFunctionality() throws {
        // Navigate to Library tab
        app.tabBars.buttons["Library"].tap()
        
        // Check for library sections
        let savedSection = app.staticTexts["Saved Verses"]
        let notesSection = app.staticTexts["Notes"]
        let bookmarksSection = app.staticTexts["Bookmarks"]
        
        let sectionsExist = savedSection.exists || notesSection.exists || bookmarksSection.exists
        XCTAssertTrue(sectionsExist, "Library should have organized sections")
    }
    
    // MARK: - Modal Tests
    
    func testModalPresentations() throws {
        // Go to Home
        app.tabBars.buttons["Home"].tap()
        
        // Look for settings button
        let settingsButton = app.navigationBars.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()
            
            // Verify settings modal appears
            let settingsView = app.tables["SettingsTable"]
            XCTAssertTrue(settingsView.waitForExistence(timeout: 3), "Settings should open as modal")
            
            // Dismiss modal
            app.navigationBars.buttons["Done"].tap()
            XCTAssertFalse(settingsView.exists, "Settings modal should dismiss")
        }
    }
}

// MARK: - Test Helpers

extension XCUIElement {
    /// Helper to wait for element to not exist
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}