import XCTest

final class BibleReadingFlowTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS": "1"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Bible Navigation Tests
    
    func testNavigateToBibleAndSelectBook() throws {
        // Navigate to Bible tab
        let bibleTab = app.tabBars.buttons["Bible"]
        XCTAssertTrue(bibleTab.exists)
        bibleTab.tap()
        
        // Open book selector
        let bookSelector = app.buttons["BookSelectorButton"]
        XCTAssertTrue(bookSelector.waitForExistence(timeout: 2))
        bookSelector.tap()
        
        // Select John from the book list
        let johnBook = app.buttons["Book_John"]
        XCTAssertTrue(johnBook.waitForExistence(timeout: 2))
        johnBook.tap()
        
        // Verify chapter selector appears
        let chapterSelector = app.collectionViews["ChapterSelector"]
        XCTAssertTrue(chapterSelector.waitForExistence(timeout: 2))
        
        // Select chapter 3
        let chapter3 = app.buttons["Chapter_3"]
        XCTAssertTrue(chapter3.exists)
        chapter3.tap()
        
        // Verify Bible reader shows John 3
        let bibleReader = app.scrollViews["BibleReader"]
        XCTAssertTrue(bibleReader.waitForExistence(timeout: 3))
        
        let titleLabel = app.staticTexts["ChapterTitle"]
        XCTAssertTrue(titleLabel.exists)
        XCTAssertEqual(titleLabel.label, "John 3")
    }
    
    func testSwipeToNavigateChapters() throws {
        // Navigate to Bible and select a book
        navigateToBible()
        selectBook("Genesis", chapter: 2)
        
        let bibleReader = app.scrollViews["BibleReader"]
        XCTAssertTrue(bibleReader.waitForExistence(timeout: 3))
        
        // Swipe left to go to next chapter
        bibleReader.swipeLeft()
        
        // Verify we're on Genesis 3
        let titleLabel = app.staticTexts["ChapterTitle"]
        XCTAssertTrue(titleLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(titleLabel.label, "Genesis 3")
        
        // Swipe right to go to previous chapter
        bibleReader.swipeRight()
        
        // Verify we're back on Genesis 2
        XCTAssertTrue(titleLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(titleLabel.label, "Genesis 2")
    }
    
    // MARK: - Verse Interaction Tests
    
    func testHighlightVerse() throws {
        navigateToBible()
        selectBook("John", chapter: 3)
        
        // Long press on verse 16
        let verse16 = app.staticTexts["Verse_16"]
        XCTAssertTrue(verse16.waitForExistence(timeout: 3))
        verse16.press(forDuration: 1.0)
        
        // Select yellow highlight from the menu
        let yellowHighlight = app.buttons["Highlight_Yellow"]
        XCTAssertTrue(yellowHighlight.waitForExistence(timeout: 2))
        yellowHighlight.tap()
        
        // Verify verse is highlighted
        XCTAssertTrue(verse16.isSelected)
        
        // Check that highlight appears in highlights list
        navigateToLibrary()
        let highlightsButton = app.buttons["Highlights"]
        highlightsButton.tap()
        
        let highlightCell = app.cells["Highlight_John_3_16"]
        XCTAssertTrue(highlightCell.waitForExistence(timeout: 2))
    }
    
    func testAddNoteToVerse() throws {
        navigateToBible()
        selectBook("Romans", chapter: 8)
        
        // Long press on verse 28
        let verse28 = app.staticTexts["Verse_28"]
        XCTAssertTrue(verse28.waitForExistence(timeout: 3))
        verse28.press(forDuration: 1.0)
        
        // Select add note option
        let addNoteButton = app.buttons["AddNote"]
        XCTAssertTrue(addNoteButton.waitForExistence(timeout: 2))
        addNoteButton.tap()
        
        // Type note
        let noteTextView = app.textViews["NoteTextView"]
        XCTAssertTrue(noteTextView.waitForExistence(timeout: 2))
        noteTextView.tap()
        noteTextView.typeText("All things work together for good!")
        
        // Save note
        let saveButton = app.buttons["SaveNote"]
        saveButton.tap()
        
        // Verify note indicator appears
        let noteIndicator = app.images["NoteIndicator_28"]
        XCTAssertTrue(noteIndicator.waitForExistence(timeout: 2))
    }
    
    func testBookmarkChapter() throws {
        navigateToBible()
        selectBook("Psalms", chapter: 23)
        
        // Tap bookmark button
        let bookmarkButton = app.buttons["BookmarkButton"]
        XCTAssertTrue(bookmarkButton.waitForExistence(timeout: 2))
        bookmarkButton.tap()
        
        // Verify bookmark is added
        XCTAssertTrue(bookmarkButton.isSelected)
        
        // Check bookmarks in library
        navigateToLibrary()
        let bookmarksButton = app.buttons["Bookmarks"]
        bookmarksButton.tap()
        
        let bookmarkCell = app.cells["Bookmark_Psalms_23"]
        XCTAssertTrue(bookmarkCell.waitForExistence(timeout: 2))
    }
    
    // MARK: - Search Tests
    
    func testSearchBible() throws {
        navigateToBible()
        
        // Tap search button
        let searchButton = app.buttons["SearchButton"]
        XCTAssertTrue(searchButton.exists)
        searchButton.tap()
        
        // Type search query
        let searchField = app.searchFields["BibleSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("love")
        
        // Wait for results
        let searchResults = app.tables["SearchResults"]
        XCTAssertTrue(searchResults.waitForExistence(timeout: 3))
        
        // Verify results appear
        let firstResult = searchResults.cells.firstMatch
        XCTAssertTrue(firstResult.waitForExistence(timeout: 2))
        
        // Tap on result
        firstResult.tap()
        
        // Verify we navigate to the verse
        let bibleReader = app.scrollViews["BibleReader"]
        XCTAssertTrue(bibleReader.waitForExistence(timeout: 2))
    }
    
    // MARK: - Audio Tests
    
    func testPlayAudioForChapter() throws {
        navigateToBible()
        selectBook("Matthew", chapter: 5)
        
        // Tap audio play button
        let audioButton = app.buttons["AudioPlayButton"]
        XCTAssertTrue(audioButton.waitForExistence(timeout: 2))
        audioButton.tap()
        
        // Verify audio controls appear
        let audioControls = app.views["AudioControls"]
        XCTAssertTrue(audioControls.waitForExistence(timeout: 2))
        
        // Check play/pause button state
        let pauseButton = app.buttons["AudioPauseButton"]
        XCTAssertTrue(pauseButton.exists)
        
        // Test pause
        pauseButton.tap()
        let playButton = app.buttons["AudioPlayButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 1))
        
        // Test playback speed
        let speedButton = app.buttons["PlaybackSpeedButton"]
        speedButton.tap()
        
        let speed15x = app.buttons["Speed_1.5x"]
        XCTAssertTrue(speed15x.waitForExistence(timeout: 1))
        speed15x.tap()
        
        // Verify speed changed
        XCTAssertEqual(speedButton.label, "1.5x")
    }
    
    // MARK: - Settings Integration Tests
    
    func testChangeFontSize() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Go to Appearance settings
        let appearanceButton = app.buttons["AppearanceSettings"]
        appearanceButton.tap()
        
        // Change font size to Large
        let fontSizeSlider = app.sliders["FontSizeSlider"]
        fontSizeSlider.adjust(toNormalizedSliderPosition: 0.75)
        
        // Go back to Bible
        app.navigationBars.buttons.firstMatch.tap()
        navigateToBible()
        
        // Verify text size changed
        let verseText = app.staticTexts["Verse_1"]
        XCTAssertTrue(verseText.waitForExistence(timeout: 2))
        // In a real test, we would verify the actual font size
    }
    
    func testToggleDarkMode() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Go to Appearance settings
        let appearanceButton = app.buttons["AppearanceSettings"]
        appearanceButton.tap()
        
        // Toggle dark mode
        let darkModeSwitch = app.switches["DarkModeSwitch"]
        darkModeSwitch.tap()
        
        // Verify UI updated to dark mode
        // In a real test, we would verify color changes
        XCTAssertTrue(darkModeSwitch.isSelected)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToBible() {
        let bibleTab = app.tabBars.buttons["Bible"]
        if bibleTab.exists {
            bibleTab.tap()
        }
    }
    
    private func navigateToLibrary() {
        let libraryTab = app.tabBars.buttons["Library"]
        if libraryTab.exists {
            libraryTab.tap()
        }
    }
    
    private func selectBook(_ bookName: String, chapter: Int) {
        let bookSelector = app.buttons["BookSelectorButton"]
        if bookSelector.waitForExistence(timeout: 2) {
            bookSelector.tap()
        }
        
        let book = app.buttons["Book_\(bookName)"]
        if book.waitForExistence(timeout: 2) {
            book.tap()
        }
        
        let chapterButton = app.buttons["Chapter_\(chapter)"]
        if chapterButton.waitForExistence(timeout: 2) {
            chapterButton.tap()
        }
    }
}

// MARK: - Performance UI Tests
extension BibleReadingFlowTests {
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    func testBibleNavigationPerformance() throws {
        measure {
            navigateToBible()
            selectBook("John", chapter: 1)
            
            // Navigate through several chapters
            for _ in 1...5 {
                let bibleReader = app.scrollViews["BibleReader"]
                if bibleReader.waitForExistence(timeout: 2) {
                    bibleReader.swipeLeft()
                }
            }
        }
    }
}