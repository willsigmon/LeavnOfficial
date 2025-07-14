import XCTest

class SearchUITests: LeavnUITests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launchArguments.append("--skip-onboarding")
        app.launch()
        
        // Navigate to Search tab
        app.tabBars.buttons["searchTab"].tap()
        let searchView = app.otherElements["searchView"]
        XCTAssertTrue(waitForElement(searchView, timeout: 5), "Search view should be visible")
    }
    
    func testSearchBasicFunctionality() throws {
        // Find search field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(waitForElement(searchField, timeout: 3), "Search field should be visible")
        
        // Tap and enter search query
        searchField.tap()
        searchField.typeText("faith")
        
        // Tap search button or press return
        app.buttons["Search"].tap()
        
        // Verify search results appear
        let searchResults = app.otherElements["searchResultsView"]
        XCTAssertTrue(waitForElement(searchResults, timeout: 5), "Search results should appear")
        
        // Verify at least one result exists
        let firstResult = app.cells.firstMatch
        XCTAssertTrue(waitForElement(firstResult, timeout: 3), "At least one search result should appear")
        
        takeScreenshot(name: "Search_Results")
    }
    
    func testSearchFilters() throws {
        // Enter search query first
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("love")
        
        // Open filter options
        tapButton(withIdentifier: "searchFiltersButton")
        
        // Verify filter sheet appears
        let filterSheet = app.otherElements["searchFiltersSheet"]
        XCTAssertTrue(waitForElement(filterSheet, timeout: 3), "Search filters sheet should appear")
        
        // Test book filter
        let bookFilterButton = app.buttons["bookFilterButton"]
        if waitForElement(bookFilterButton, timeout: 2) {
            bookFilterButton.tap()
            
            // Select specific book
            let johnButton = app.buttons["filter_John"]
            if waitForElement(johnButton, timeout: 2) {
                johnButton.tap()
            }
        }
        
        // Apply filters
        tapButton(withIdentifier: "applyFiltersButton")
        
        // Verify filtered results
        let searchResults = app.otherElements["searchResultsView"]
        XCTAssertTrue(waitForElement(searchResults, timeout: 5), "Filtered search results should appear")
        
        takeScreenshot(name: "Search_Filtered_Results")
    }
    
    func testSearchHistory() throws {
        // Tap search field
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        
        // Check if search history appears
        let searchHistory = app.otherElements["searchHistoryView"]
        if waitForElement(searchHistory, timeout: 2) {
            // Tap a history item
            let historyItem = app.cells["searchHistoryItem"].firstMatch
            if waitForElement(historyItem, timeout: 2) {
                historyItem.tap()
                
                // Verify search is performed
                let searchResults = app.otherElements["searchResultsView"]
                XCTAssertTrue(waitForElement(searchResults, timeout: 5), "Search should be performed from history")
            }
        }
        
        takeScreenshot(name: "Search_History")
    }
    
    func testSearchResultSelection() throws {
        // Perform a search
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("grace")
        app.buttons["Search"].tap()
        
        // Wait for results
        let searchResults = app.otherElements["searchResultsView"]
        XCTAssertTrue(waitForElement(searchResults, timeout: 5))
        
        // Tap first result
        let firstResult = app.cells.firstMatch
        if waitForElement(firstResult, timeout: 3) {
            firstResult.tap()
            
            // Verify navigation to Bible view
            let bibleView = app.otherElements["bibleView"]
            XCTAssertTrue(waitForElement(bibleView, timeout: 5), "Should navigate to Bible view with selected verse")
            
            // Verify the Bible tab is now selected
            XCTAssertTrue(app.tabBars.buttons["bibleTab"].isSelected, "Bible tab should be selected after selecting search result")
        }
        
        takeScreenshot(name: "Search_Result_Navigation")
    }
    
    func testClearSearch() throws {
        // Enter search query
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("test query")
        
        // Find and tap clear button
        let clearButton = app.buttons["Clear text"]
        if waitForElement(clearButton, timeout: 2) {
            clearButton.tap()
            
            // Verify search field is empty
            XCTAssertEqual(searchField.value as? String, "Search", "Search field should be empty after clearing")
        }
    }
    
    func testEmptySearchResults() throws {
        // Enter search query that should return no results
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("xyzabc123notfound")
        app.buttons["Search"].tap()
        
        // Verify empty state appears
        let emptyState = app.otherElements["searchEmptyStateView"]
        XCTAssertTrue(waitForElement(emptyState, timeout: 5), "Empty state should appear for no results")
        
        takeScreenshot(name: "Search_Empty_State")
    }
}