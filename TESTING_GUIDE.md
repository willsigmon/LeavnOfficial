# Leavn App Testing Guide

This guide provides comprehensive instructions for building, testing, and validating the Leavn app.

## Prerequisites

- Xcode 15.0 or later
- iOS 18.0 SDK
- macOS 13.0 or later
- iPhone 16 Pro Max simulator installed

## Quick Start

1. **Make scripts executable:**
   ```bash
   chmod +x Scripts/run_tests.sh
   chmod +x Scripts/feature_validation_checklist.sh
   ```

2. **Run all tests:**
   ```bash
   ./Scripts/run_tests.sh all
   ```

3. **Run specific test suites:**
   ```bash
   ./Scripts/run_tests.sh unit    # Unit tests only
   ./Scripts/run_tests.sh ui      # UI tests only
   ./Scripts/run_tests.sh manual  # Manual testing
   ```

## Simulator Setup

### Target Device: iPhone 16 Pro Max

1. **Open Xcode** and go to Window > Devices and Simulators
2. **Click the "+" button** to add a new simulator
3. **Select:**
   - Device Type: iPhone 16 Pro Max
   - OS Version: iOS 18.0

### Clean Build Environment

Always start with a clean environment:

```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Clean build folder
xcodebuild clean -project Leavn.xcodeproj -scheme Leavn
```

## Test Execution

### 1. Automated Tests

#### Unit Tests
Tests core business logic, models, and services:
```bash
xcodebuild test \
  -project Leavn.xcodeproj \
  -scheme Leavn \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
  -only-testing:LeavnTests
```

#### Integration Tests
Tests interaction between components:
```bash
xcodebuild test \
  -project Leavn.xcodeproj \
  -scheme Leavn \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
  -only-testing:LeavnIntegrationTests
```

#### UI Tests
Tests user interface and workflows:
```bash
xcodebuild test \
  -project Leavn.xcodeproj \
  -scheme Leavn \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
  -only-testing:LeavnUITests
```

### 2. Manual Feature Validation

Run the interactive testing script:
```bash
./Scripts/feature_validation_checklist.sh
```

This will guide you through testing:
- All 5 main tabs (Home, Bible, Library, Search, Community)
- Apocrypha book navigation
- Audio playback functionality
- LifeSituations feature
- Share sheets and modals

### 3. Critical Features Checklist

#### Tab Navigation
- [ ] Home tab loads with LifeSituations visible
- [ ] Bible tab shows book list
- [ ] Library tab displays saved content
- [ ] Search tab has functional search field
- [ ] Community tab loads community content

#### Bible Features
- [ ] Book selection works
- [ ] Chapter navigation functions
- [ ] Verse text displays correctly
- [ ] Apocrypha books are accessible
- [ ] Text can be selected and copied

#### Audio System
- [ ] Play button starts audio
- [ ] Pause button stops audio
- [ ] Seek bar allows navigation
- [ ] Background audio continues when app minimized
- [ ] Audio controls in Control Center work

#### Sharing
- [ ] Long press on verse shows share options
- [ ] Share sheet displays all options
- [ ] Copy to clipboard works
- [ ] Share to Messages/Mail works

#### LifeSituations
- [ ] Section appears on Home tab
- [ ] Categories are displayed
- [ ] Tapping category shows relevant content
- [ ] Navigation back to list works

## Performance Benchmarks

The app should meet these targets:

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Launch Time | < 3 seconds | Time from tap to home screen |
| Memory (Idle) | < 100 MB | Check in Xcode Debug Navigator |
| Memory (Active) | < 200 MB | During heavy navigation |
| Tab Switching | < 0.5 seconds | Time between tab taps |

## Test Reporting

### Generate Test Report

After testing, create a report:

```bash
cp QA_TEST_REPORT_TEMPLATE.md TestReports/QA_REPORT_$(date +%Y%m%d).md
```

Fill in:
- Test results for each feature
- Performance metrics
- Screenshots of any issues
- Recommendations for fixes

### Screenshot Capture

During manual testing, capture screenshots:

```bash
# From Terminal while simulator is running
xcrun simctl io booted screenshot screenshot_name.png
```

## Continuous Integration

The project includes a GitHub Actions workflow (`ci_test_pipeline.yml`) that:

1. **Builds the app** for iPhone 16 Pro Max
2. **Runs all test suites** automatically
3. **Generates test reports**
4. **Uploads artifacts** for review

To use in your CI:
```bash
cp Scripts/ci_test_pipeline.yml .github/workflows/
```

## Troubleshooting

### Common Issues

1. **Simulator not found:**
   ```bash
   # List available simulators
   xcrun simctl list devices
   
   # Create if missing
   xcrun simctl create "iPhone 16 Pro Max" \
     com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max \
     com.apple.CoreSimulator.SimRuntime.iOS-18-0
   ```

2. **Build failures:**
   - Clean derived data
   - Reset simulator: Device > Erase All Content and Settings
   - Restart Xcode

3. **Test timeouts:**
   - Increase timeout values in test code
   - Check for deadlocks or infinite loops
   - Verify simulator has enough resources

### Debug Mode

Run with verbose output:
```bash
xcodebuild test -verbose \
  -project Leavn.xcodeproj \
  -scheme Leavn \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro Max"
```

## Best Practices

1. **Always test on clean simulator** - Reset content and settings before major test runs
2. **Document failures immediately** - Include steps to reproduce
3. **Take screenshots** - Visual evidence helps debugging
4. **Test after every major change** - Catch regressions early
5. **Run full test suite before commits** - Ensure nothing is broken

## Additional Resources

- [Apple Testing Documentation](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [XCTest Framework Reference](https://developer.apple.com/documentation/xctest)
- [UI Testing Best Practices](https://developer.apple.com/documentation/xctest/user_interface_tests)

---

For questions or issues, please refer to the project documentation or contact the development team.