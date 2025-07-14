import XCTest

class LibraryUITests: LeavnUITests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launchArguments.append("--skip-onboarding")
        app.launch()
        
        // Navigate to Library tab
        app.tabBars.buttons["libraryTab"].tap()
        let libraryView = app.otherElements["libraryView"]
        XCTAssertTrue(waitForElement(libraryView, timeout: 5), "Library view should be visible")
    }
    
    func testLibrarySections() throws {
        // Test Reading Plans section
        let readingPlansSection = app.otherElements["readingPlansSection"]
        if waitForElement(readingPlansSection, timeout: 3) {
            // Tap on a reading plan
            let firstPlan = app.cells["readingPlanCell"].firstMatch
            if waitForElement(firstPlan, timeout: 2) {
                firstPlan.tap()
                
                let planDetailView = app.otherElements["readingPlanDetailView"]
                XCTAssertTrue(waitForElement(planDetailView, timeout: 3), "Reading plan detail view should appear")
                
                // Navigate back
                app.navigationBars.buttons.firstMatch.tap()
            }
        }
        
        // Test Bookmarks section
        let bookmarksSection = app.otherElements["bookmarksSection"]
        if waitForElement(bookmarksSection, timeout: 3) {
            let firstBookmark = app.cells["bookmarkCell"].firstMatch
            if waitForElement(firstBookmark, timeout: 2) {
                firstBookmark.tap()
                
                // Should navigate to Bible view
                let bibleView = app.otherElements["bibleView"]
                XCTAssertTrue(waitForElement(bibleView, timeout: 5), "Should navigate to Bible view from bookmark")
                
                // Return to library
                app.tabBars.buttons["libraryTab"].tap()
            }
        }
        
        // Test Notes section
        let notesSection = app.otherElements["notesSection"]
        if waitForElement(notesSection, timeout: 3) {
            let firstNote = app.cells["noteCell"].firstMatch
            if waitForElement(firstNote, timeout: 2) {
                firstNote.tap()
                
                let noteDetailView = app.otherElements["noteDetailView"]
                XCTAssertTrue(waitForElement(noteDetailView, timeout: 3), "Note detail view should appear")
                
                app.navigationBars.buttons.firstMatch.tap()
            }
        }
        
        takeScreenshot(name: "Library_Main_View")
    }
    
    func testCreateNewNote() throws {
        // Tap add note button
        tapButton(withIdentifier: "addNoteButton")
        
        // Verify note editor appears
        let noteEditor = app.otherElements["noteEditorView"]
        XCTAssertTrue(waitForElement(noteEditor, timeout: 3), "Note editor should appear")
        
        // Enter note content
        let titleField = app.textFields["noteTitleField"]
        if waitForElement(titleField, timeout: 2) {
            titleField.tap()
            titleField.typeText("Test Note Title")
        }
        
        let contentTextView = app.textViews["noteContentTextView"]
        if waitForElement(contentTextView, timeout: 2) {
            contentTextView.tap()
            contentTextView.typeText("This is a test note created during UI testing.")
        }
        
        // Save note
        tapButton(withIdentifier: "saveNoteButton")
        
        // Verify returned to library
        let libraryView = app.otherElements["libraryView"]
        XCTAssertTrue(waitForElement(libraryView, timeout: 3), "Should return to library after saving note")
        
        takeScreenshot(name: "Library_Note_Created")
    }
    
    func testFilterLibraryItems() throws {
        // Tap filter button
        tapButton(withIdentifier: "libraryFilterButton")
        
        // Verify filter options appear
        let filterSheet = app.otherElements["libraryFilterSheet"]
        XCTAssertTrue(waitForElement(filterSheet, timeout: 3), "Library filter sheet should appear")
        
        // Select notes only
        let notesOnlyButton = app.buttons["filterNotesOnly"]
        if waitForElement(notesOnlyButton, timeout: 2) {
            notesOnlyButton.tap()
        }
        
        // Apply filter
        tapButton(withIdentifier: "applyFilterButton")
        
        // Verify only notes are shown
        let noteCell = app.cells["noteCell"].firstMatch
        XCTAssertTrue(waitForElement(noteCell, timeout: 3), "Notes should be visible")
        
        let bookmarkCell = app.cells["bookmarkCell"].firstMatch
        XCTAssertFalse(bookmarkCell.exists, "Bookmarks should not be visible when filtered to notes only")
        
        takeScreenshot(name: "Library_Filtered_Notes")
    }
    
    func testSearchLibrary() throws {
        // Tap search field
        let searchField = app.searchFields["librarySearchField"]
        if waitForElement(searchField, timeout: 3) {
            searchField.tap()
            searchField.typeText("test")
            
            // Verify search results
            sleep(1) // Wait for search to complete
            
            let searchResults = app.otherElements["librarySearchResults"]
            XCTAssertTrue(waitForElement(searchResults, timeout: 3), "Search results should appear")
            
            takeScreenshot(name: "Library_Search_Results")
        }
    }
    
    func testDeleteLibraryItem() throws {
        // Find a deletable item (note or bookmark)
        let noteCell = app.cells["noteCell"].firstMatch
        if waitForElement(noteCell, timeout: 3) {
            // Swipe to delete
            noteCell.swipeLeft()
            
            // Tap delete button
            let deleteButton = app.buttons["Delete"]
            if waitForElement(deleteButton, timeout: 2) {
                deleteButton.tap()
                
                // Confirm deletion
                let confirmAlert = app.alerts.firstMatch
                if waitForElement(confirmAlert, timeout: 2) {
                    confirmAlert.buttons["Delete"].tap()
                }
            }
        }
    }
}