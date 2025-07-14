import XCTest

class HomeUITests: LeavnUITests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.launchArguments.append("--skip-onboarding")
        app.launch()
        
        // Ensure we're on Home tab
        app.tabBars.buttons["homeTab"].tap()
        let homeView = app.otherElements["homeView"]
        XCTAssertTrue(waitForElement(homeView, timeout: 5), "Home view should be visible")
    }
    
    func testDailyVerseCard() throws {
        // Find daily verse card
        let dailyVerseCard = app.otherElements["dailyVerseCard"]
        XCTAssertTrue(waitForElement(dailyVerseCard, timeout: 3), "Daily verse card should be visible")
        
        // Test share button
        let shareButton = app.buttons["shareDailyVerseButton"]
        if waitForElement(shareButton, timeout: 2) {
            shareButton.tap()
            
            // Verify share sheet appears
            let shareSheet = app.otherElements["ActivityListView"]
            XCTAssertTrue(waitForElement(shareSheet, timeout: 3), "Share sheet should appear")
            
            // Dismiss share sheet
            app.otherElements["PopoverDismissRegion"].tap()
        }
        
        // Test read more button
        let readMoreButton = app.buttons["readDailyVerseButton"]
        if waitForElement(readMoreButton, timeout: 2) {
            readMoreButton.tap()
            
            // Should navigate to Bible view
            let bibleView = app.otherElements["bibleView"]
            XCTAssertTrue(waitForElement(bibleView, timeout: 5), "Should navigate to Bible view")
            
            // Return to home
            app.tabBars.buttons["homeTab"].tap()
        }
        
        takeScreenshot(name: "Home_Daily_Verse")
    }
    
    func testReadingStreak() throws {
        // Find reading streak section
        let streakSection = app.otherElements["readingStreakSection"]
        if waitForElement(streakSection, timeout: 3) {
            // Verify streak count is displayed
            let streakLabel = app.staticTexts["streakCountLabel"]
            XCTAssertTrue(waitForElement(streakLabel, timeout: 2), "Streak count should be displayed")
            
            takeScreenshot(name: "Home_Reading_Streak")
        }
    }
    
    func testQuickActions() throws {
        // Test Continue Reading button
        let continueReadingButton = app.buttons["continueReadingButton"]
        if waitForElement(continueReadingButton, timeout: 3) {
            continueReadingButton.tap()
            
            // Should navigate to Bible view at last read position
            let bibleView = app.otherElements["bibleView"]
            XCTAssertTrue(waitForElement(bibleView, timeout: 5), "Should navigate to Bible view")
            
            app.tabBars.buttons["homeTab"].tap()
        }
        
        // Test Start Reading Plan button
        let readingPlanButton = app.buttons["startReadingPlanButton"]
        if waitForElement(readingPlanButton, timeout: 3) {
            readingPlanButton.tap()
            
            // Should show reading plan selection
            let planSelectionView = app.otherElements["readingPlanSelectionView"]
            XCTAssertTrue(waitForElement(planSelectionView, timeout: 3), "Reading plan selection should appear")
            
            // Dismiss or navigate back
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            } else {
                app.buttons["Cancel"].tap()
            }
        }
        
        takeScreenshot(name: "Home_Quick_Actions")
    }
    
    func testCommunityFeed() throws {
        // Scroll to community section
        app.scrollViews.firstMatch.swipeUp()
        
        let communitySection = app.otherElements["communityFeedSection"]
        if waitForElement(communitySection, timeout: 3) {
            // Test interaction with community post
            let firstPost = app.cells["communityPostCell"].firstMatch
            if waitForElement(firstPost, timeout: 2) {
                // Test like button
                let likeButton = firstPost.buttons["likeButton"]
                if waitForElement(likeButton, timeout: 2) {
                    likeButton.tap()
                    sleep(1) // Wait for animation
                }
                
                // Test comment button
                let commentButton = firstPost.buttons["commentButton"]
                if waitForElement(commentButton, timeout: 2) {
                    commentButton.tap()
                    
                    // Verify comment view appears
                    let commentView = app.otherElements["commentView"]
                    XCTAssertTrue(waitForElement(commentView, timeout: 3), "Comment view should appear")
                    
                    // Dismiss comment view
                    app.buttons["Done"].tap()
                }
            }
            
            takeScreenshot(name: "Home_Community_Feed")
        }
    }
    
    func testPrayerWall() throws {
        // Scroll to prayer wall section
        app.scrollViews.firstMatch.swipeUp()
        
        let prayerWallSection = app.otherElements["prayerWallSection"]
        if waitForElement(prayerWallSection, timeout: 3) {
            // Test add prayer request button
            let addPrayerButton = app.buttons["addPrayerRequestButton"]
            if waitForElement(addPrayerButton, timeout: 2) {
                addPrayerButton.tap()
                
                // Verify prayer request form appears
                let prayerForm = app.otherElements["prayerRequestForm"]
                XCTAssertTrue(waitForElement(prayerForm, timeout: 3), "Prayer request form should appear")
                
                // Fill out form
                let titleField = app.textFields["prayerTitleField"]
                if waitForElement(titleField, timeout: 2) {
                    titleField.tap()
                    titleField.typeText("Test Prayer Request")
                }
                
                let descriptionField = app.textViews["prayerDescriptionField"]
                if waitForElement(descriptionField, timeout: 2) {
                    descriptionField.tap()
                    descriptionField.typeText("This is a test prayer request.")
                }
                
                // Cancel instead of submitting
                app.buttons["Cancel"].tap()
            }
            
            // Test pray button on existing prayer
            let prayButton = app.buttons["prayButton"].firstMatch
            if waitForElement(prayButton, timeout: 2) {
                prayButton.tap()
                sleep(1) // Wait for animation
            }
            
            takeScreenshot(name: "Home_Prayer_Wall")
        }
    }
    
    func testRecommendedContent() throws {
        // Scroll to bottom for recommended content
        app.scrollViews.firstMatch.swipeUp()
        
        let recommendedSection = app.otherElements["recommendedContentSection"]
        if waitForElement(recommendedSection, timeout: 3) {
            // Test tapping on recommended item
            let recommendedItem = app.cells["recommendedContentCell"].firstMatch
            if waitForElement(recommendedItem, timeout: 2) {
                recommendedItem.tap()
                
                // Verify content view appears
                let contentView = app.otherElements["contentDetailView"]
                XCTAssertTrue(waitForElement(contentView, timeout: 3), "Content detail view should appear")
                
                // Navigate back
                app.navigationBars.buttons.firstMatch.tap()
            }
            
            takeScreenshot(name: "Home_Recommended_Content")
        }
    }
}