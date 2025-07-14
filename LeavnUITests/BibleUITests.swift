import XCTest

class BibleUITests: LeavnUITests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launchArguments.append("--skip-onboarding")
        app.launch()
        
        // Navigate to Bible tab
        app.tabBars.buttons["bibleTab"].tap()
        let bibleView = app.otherElements["bibleView"]
        XCTAssertTrue(waitForElement(bibleView, timeout: 5), "Bible view should be visible")
    }
    
    func testBibleBookSelection() throws {
        // Tap book/chapter selector
        tapButton(withIdentifier: "bookChapterButton")
        
        // Verify book selector appears
        let bookSelector = app.otherElements["bookSelectorView"]
        XCTAssertTrue(waitForElement(bookSelector, timeout: 3), "Book selector should appear")
        
        // Select a book (e.g., Genesis)
        let genesisButton = app.buttons["book_Genesis"]
        if waitForElement(genesisButton, timeout: 2) {
            genesisButton.tap()
            
            // Verify chapter selector appears
            let chapterSelector = app.otherElements["chapterSelectorView"]
            XCTAssertTrue(waitForElement(chapterSelector, timeout: 3), "Chapter selector should appear")
            
            // Select chapter 1
            let chapter1Button = app.buttons["chapter_1"]
            if waitForElement(chapter1Button, timeout: 2) {
                chapter1Button.tap()
                
                // Verify Bible content is displayed
                let bibleContent = app.otherElements["bibleContentView"]
                XCTAssertTrue(waitForElement(bibleContent, timeout: 5), "Bible content should be displayed")
            }
        }
        
        takeScreenshot(name: "Bible_Reading_View")
    }
    
    func testBibleSearch() throws {
        // Tap search button
        tapButton(withIdentifier: "bibleSearchButton")
        
        // Verify search view appears
        let searchField = app.searchFields["bibleSearchField"]
        XCTAssertTrue(waitForElement(searchField, timeout: 3), "Bible search field should appear")
        
        // Type search query
        searchField.tap()
        searchField.typeText("love")
        
        // Tap search button or press return
        app.buttons["Search"].tap()
        
        // Verify search results appear
        let searchResults = app.otherElements["bibleSearchResults"]
        XCTAssertTrue(waitForElement(searchResults, timeout: 5), "Search results should appear")
        
        takeScreenshot(name: "Bible_Search_Results")
    }
    
    func testBibleVoiceMode() throws {
        // Tap voice mode button
        tapButton(withIdentifier: "voiceModeButton")
        
        // Verify voice mode UI appears
        let voiceModeView = app.otherElements["voiceModeView"]
        XCTAssertTrue(waitForElement(voiceModeView, timeout: 3), "Voice mode view should appear")
        
        // Test play/pause button
        let playPauseButton = app.buttons["playPauseButton"]
        if waitForElement(playPauseButton, timeout: 2) {
            playPauseButton.tap()
            sleep(1)
            playPauseButton.tap()
        }
        
        // Test close voice mode
        tapButton(withIdentifier: "closeVoiceModeButton")
        
        // Verify returned to normal reading view
        let bibleContent = app.otherElements["bibleContentView"]
        XCTAssertTrue(waitForElement(bibleContent, timeout: 3), "Should return to bible content view")
    }
    
    func testBibleTranslationPicker() throws {
        // Tap translation picker
        tapButton(withIdentifier: "translationPickerButton")
        
        // Verify translation list appears
        let translationList = app.otherElements["translationListView"]
        XCTAssertTrue(waitForElement(translationList, timeout: 3), "Translation list should appear")
        
        // Select a different translation
        let nivButton = app.buttons["translation_NIV"]
        if waitForElement(nivButton, timeout: 2) {
            nivButton.tap()
            
            // Verify translation changed
            let translationLabel = app.staticTexts["currentTranslationLabel"]
            XCTAssertTrue(translationLabel.label.contains("NIV"), "Translation should change to NIV")
        }
        
        takeScreenshot(name: "Bible_Translation_Changed")
    }
    
    func testBibleReaderSettings() throws {
        // Tap reader settings button
        tapButton(withIdentifier: "readerSettingsButton")
        
        // Verify settings sheet appears
        let settingsSheet = app.otherElements["readerSettingsSheet"]
        XCTAssertTrue(waitForElement(settingsSheet, timeout: 3), "Reader settings sheet should appear")
        
        // Test font size adjustment
        let fontSizeSlider = app.sliders["fontSizeSlider"]
        if waitForElement(fontSizeSlider, timeout: 2) {
            fontSizeSlider.adjust(toNormalizedSliderPosition: 0.7)
        }
        
        // Test theme toggle
        let themeToggle = app.switches["themeToggle"]
        if waitForElement(themeToggle, timeout: 2) {
            themeToggle.tap()
        }
        
        // Dismiss settings
        tapButton(withIdentifier: "doneButton")
        
        takeScreenshot(name: "Bible_Reader_Settings_Applied")
    }
    
    func testVerseSelection() throws {
        // Ensure we have Bible content
        let bibleContent = app.otherElements["bibleContentView"]
        XCTAssertTrue(waitForElement(bibleContent, timeout: 5))
        
        // Tap on a verse
        let firstVerse = app.staticTexts.matching(identifier: "verse_1").firstMatch
        if waitForElement(firstVerse, timeout: 3) {
            firstVerse.tap()
            
            // Verify verse action menu appears
            let verseActionMenu = app.otherElements["verseActionMenu"]
            XCTAssertTrue(waitForElement(verseActionMenu, timeout: 3), "Verse action menu should appear")
            
            // Test highlight action
            tapButton(withIdentifier: "highlightVerseButton")
            
            // Test note action
            tapButton(withIdentifier: "addNoteButton")
            
            // Verify note editor appears
            let noteEditor = app.otherElements["noteEditorView"]
            if waitForElement(noteEditor, timeout: 3) {
                let noteTextView = app.textViews["noteTextView"]
                noteTextView.tap()
                noteTextView.typeText("This is a test note")
                
                // Save note
                tapButton(withIdentifier: "saveNoteButton")
            }
        }
        
        takeScreenshot(name: "Bible_Verse_Actions")
    }
}