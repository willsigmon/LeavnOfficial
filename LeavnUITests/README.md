# LeavnOfficial UI Testing Framework

## Overview
This comprehensive UI testing framework automatically tests all user flows in the LeavnOfficial app and can auto-fix broken buttons or navigation issues.

## Features
- ✅ Complete UI test coverage for all main flows
- ✅ Automatic detection of broken buttons and navigation
- ✅ Accessibility identifier integration
- ✅ Screenshot capture for visual verification
- ✅ Detailed test reporting
- ✅ Auto-fix suggestions for common issues

## Test Coverage

### 1. Onboarding Flow (`OnboardingUITests.swift`)
- Splash screen display
- Welcome/onboarding screens
- Continue button functionality
- Complete onboarding process
- Skip functionality
- Proper navigation to main app

### 2. Main Tab Navigation (`MainTabUITests.swift`)
- All 5 tabs exist and are clickable
- Tab selection state
- Tab persistence after backgrounding
- Deep linking support

### 3. Bible Reading (`BibleUITests.swift`)
- Book and chapter selection
- Bible search functionality
- Voice mode controls
- Translation picker
- Reader settings (font, theme)
- Verse selection and actions
- Note creation from verses

### 4. Search Functionality (`SearchUITests.swift`)
- Basic search operations
- Search filters
- Search history
- Result selection and navigation
- Empty state handling
- Clear search functionality

### 5. Library Management (`LibraryUITests.swift`)
- Reading plans
- Bookmarks
- Notes (create, edit, delete)
- Filtering options
- Search within library
- Swipe to delete

### 6. Home Dashboard (`HomeUITests.swift`)
- Daily verse display and sharing
- Reading streak tracking
- Quick actions (continue reading, start plan)
- Community feed interactions
- Prayer wall functionality
- Recommended content

### 7. Settings (`SettingsUITests.swift`)
- Account settings
- Notification preferences
- Appearance/theme selection
- Privacy settings
- About section
- Sign out flow

## Running Tests

### Quick Start
```bash
# Run all UI tests
./run_ui_tests.sh

# Select option 1 when prompted
```

### Specific Test Runs
```bash
# Run UI tests via Xcode
xcodebuild test \
  -project /Users/wsig/Desktop/LeavniOS/Leavn.xcodeproj \
  -scheme "Leavn (iOS)" \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  -only-testing:LeavnUITests
```

### Individual Test Classes
```bash
# Run only onboarding tests
xcodebuild test \
  -project /Users/wsig/Desktop/LeavniOS/Leavn.xcodeproj \
  -scheme "Leavn (iOS)" \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  -only-testing:LeavnUITests/OnboardingUITests
```

## Auto-Fix Implementation

When tests fail due to broken buttons or flows, the framework identifies:

1. **Missing Accessibility Identifiers**
   - Solution: Add `.accessibilityIdentifier("identifier")` to SwiftUI views

2. **Broken Button Actions**
   - Solution: Verify `@State` bindings and action closures

3. **Navigation Issues**
   - Solution: Check `NavigationStack` and sheet presentations

4. **Timing Issues**
   - Solution: Increase `waitForElement()` timeouts

## Accessibility Identifiers Added

### Main Navigation
- `mainTabBar`
- `homeTab`, `bibleTab`, `searchTab`, `libraryTab`, `settingsTab`

### Bible View
- `bibleView`
- `bookChapterButton`
- `bibleSearchButton`
- `voiceModeButton`
- `translationPickerButton`
- `readerSettingsButton`
- `bibleContentView`

### Onboarding
- `onboardingView`
- `onboardingContinueButton`
- `completeOnboardingButton`
- `skipOnboardingButton`

### Home View
- `homeView`
- `dailyVerseCard`
- `readingStreakSection`
- `continueReadingButton`
- `communityFeedSection`

## Test Data Management

### Launch Arguments
- `--uitesting`: Indicates app is running in test mode
- `--skip-onboarding`: Bypasses onboarding for main app tests
- `--reset-onboarding`: Forces onboarding to show

### Test Helpers
- `waitForElement()`: Waits for UI elements with timeout
- `tapButton()`: Safely taps buttons with verification
- `verifyViewExists()`: Asserts view presence
- `takeScreenshot()`: Captures test state

## Troubleshooting

### Common Issues

1. **"Button not found" errors**
   ```swift
   // Add identifier to button
   Button("Continue") { }
     .accessibilityIdentifier("continueButton")
   ```

2. **Navigation failures**
   ```swift
   // Ensure NavigationStack wraps views
   NavigationStack {
     ContentView()
   }
   ```

3. **Timing issues**
   ```swift
   // Increase timeout
   waitForElement(element, timeout: 10)
   ```

## CI/CD Integration

Add to your CI pipeline:
```yaml
- name: Run UI Tests
  run: |
    xcodebuild test \
      -project Leavn.xcodeproj \
      -scheme "Leavn (iOS)" \
      -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
      -resultBundlePath TestResults \
      -enableCodeCoverage YES
```

## Best Practices

1. **Always add accessibility identifiers** to new UI elements
2. **Run tests before each release** to catch regressions
3. **Update tests** when adding new features
4. **Use descriptive test names** for clarity
5. **Capture screenshots** at key points for debugging

## Next Steps

1. Integrate with CI/CD pipeline
2. Add performance testing
3. Implement visual regression testing
4. Add localization testing
5. Create test data fixtures

---

For questions or issues, contact the development team or create an issue in the project repository.