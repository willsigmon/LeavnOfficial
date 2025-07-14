# Comprehensive Testing Guide

## Overview

This guide provides a complete testing strategy for the Leavn application across all platforms (iOS, iPadOS, macOS, watchOS, visionOS). We follow a test-driven development (TDD) approach with comprehensive coverage requirements.

## Testing Philosophy

- **Test Early, Test Often**: Write tests before or alongside feature development
- **Comprehensive Coverage**: Aim for >80% code coverage
- **Platform Parity**: Ensure consistent behavior across all platforms
- **Automated Testing**: Minimize manual testing through automation
- **Continuous Integration**: All tests must pass before merging

## Unit Testing Approach

### Test Structure
```swift
import XCTest
@testable import Leavn

class LeaveViewModelTests: XCTestCase {
    var sut: LeaveViewModel! // System Under Test
    var mockService: MockLeaveService!
    
    override func setUp() {
        super.setUp()
        mockService = MockLeaveService()
        sut = LeaveViewModel(service: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    func testLeaveRequestCreation() async throws {
        // Given
        let leave = Leave(type: .annual, startDate: Date(), endDate: Date().addingDays(5))
        mockService.createLeaveResult = .success(leave)
        
        // When
        try await sut.createLeaveRequest(leave)
        
        // Then
        XCTAssertEqual(sut.leaves.count, 1)
        XCTAssertEqual(sut.leaves.first?.id, leave.id)
        XCTAssertTrue(mockService.createLeaveCalled)
    }
}
```

### Mock Objects
```swift
// Mocks/MockLeaveService.swift
class MockLeaveService: LeaveServiceProtocol {
    var createLeaveCalled = false
    var createLeaveResult: Result<Leave, Error> = .success(Leave())
    
    func createLeave(_ leave: Leave) async throws -> Leave {
        createLeaveCalled = true
        switch createLeaveResult {
        case .success(let leave):
            return leave
        case .failure(let error):
            throw error
        }
    }
}
```

### Testing ViewModels
```swift
class EmployeeViewModelTests: XCTestCase {
    func testFetchEmployees() async throws {
        // Given
        let mockEmployees = [
            Employee(id: "1", name: "John Doe"),
            Employee(id: "2", name: "Jane Smith")
        ]
        mockService.employees = mockEmployees
        
        // When
        try await sut.fetchEmployees()
        
        // Then
        XCTAssertEqual(sut.employees.count, 2)
        XCTAssertEqual(sut.employees.first?.name, "John Doe")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchEmployeesError() async {
        // Given
        mockService.shouldThrowError = true
        
        // When
        await sut.fetchEmployees()
        
        // Then
        XCTAssertTrue(sut.employees.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
}
```

### Testing Services
```swift
class CloudKitServiceTests: XCTestCase {
    var mockContainer: MockCKContainer!
    var sut: CloudKitService!
    
    func testSaveRecord() async throws {
        // Given
        let leave = Leave(type: .annual)
        let record = leave.toCKRecord()
        mockContainer.saveResult = .success(record)
        
        // When
        let saved = try await sut.save(leave)
        
        // Then
        XCTAssertEqual(saved.id, leave.id)
        XCTAssertTrue(mockContainer.saveCalled)
    }
    
    func testFetchRecords() async throws {
        // Given
        let predicate = NSPredicate(value: true)
        let mockRecords = createMockRecords(count: 5)
        mockContainer.fetchResult = .success(mockRecords)
        
        // When
        let leaves: [Leave] = try await sut.fetch(predicate: predicate)
        
        // Then
        XCTAssertEqual(leaves.count, 5)
        XCTAssertTrue(mockContainer.fetchCalled)
    }
}
```

## UI Testing Guidelines

### SwiftUI View Testing
```swift
class LeaveRequestViewTests: XCTestCase {
    func testLeaveRequestFormDisplay() {
        // Given
        let viewModel = LeaveViewModel()
        let view = LeaveRequestView(viewModel: viewModel)
        
        // When
        let controller = UIHostingController(rootView: view)
        
        // Then
        XCTAssertNotNil(controller.view)
        
        // Verify form elements
        let exp = expectation(description: "View loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
```

### UI Test Automation
```swift
import XCTest

class LeavnUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testCreateLeaveRequest() {
        // Navigate to leave request
        app.buttons["New Leave Request"].tap()
        
        // Fill form
        let startDatePicker = app.datePickers["startDate"]
        startDatePicker.tap()
        // Select date
        
        let endDatePicker = app.datePickers["endDate"]
        endDatePicker.tap()
        // Select date
        
        app.textFields["reason"].tap()
        app.textFields["reason"].typeText("Family vacation")
        
        // Submit
        app.buttons["Submit Request"].tap()
        
        // Verify success
        XCTAssertTrue(app.staticTexts["Request submitted successfully"].exists)
    }
    
    func testLeaveApprovalFlow() {
        // Login as manager
        loginAsManager()
        
        // Navigate to pending requests
        app.tabBars.buttons["Approvals"].tap()
        
        // Select first request
        let firstRequest = app.tables.cells.firstMatch
        firstRequest.tap()
        
        // Approve request
        app.buttons["Approve"].tap()
        app.buttons["Confirm"].tap()
        
        // Verify approval
        XCTAssertTrue(app.staticTexts["Request approved"].exists)
    }
}
```

### Accessibility Testing
```swift
class AccessibilityTests: XCTestCase {
    func testVoiceOverLabels() {
        let app = XCUIApplication()
        app.launch()
        
        // Verify accessibility labels
        XCTAssertEqual(
            app.buttons["New Leave Request"].label,
            "Create new leave request"
        )
        
        XCTAssertEqual(
            app.staticTexts["leaveBalance"].label,
            "Annual leave balance: 15 days remaining"
        )
    }
    
    func testDynamicTypeSupport() {
        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        
        // Verify text scaling
        let titleLabel = app.staticTexts["Dashboard"]
        XCTAssertTrue(titleLabel.frame.height > 50)
    }
}
```

## Platform-Specific Testing

### iOS/iPadOS Testing
```swift
class iPadLayoutTests: XCTestCase {
    func testSplitViewLayout() {
        let app = XCUIApplication()
        app.launchArguments = ["--ipad"]
        app.launch()
        
        // Verify split view
        XCTAssertTrue(app.splitGroups.firstMatch.exists)
        
        // Test landscape orientation
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.navigationBars.count >= 2)
    }
}
```

### macOS Testing
```swift
class MacMenuBarTests: XCTestCase {
    func testMenuBarActions() {
        let app = XCUIApplication()
        app.launch()
        
        // Test File menu
        app.menuBars.menuItems["File"].click()
        app.menuItems["New Leave Request"].click()
        
        XCTAssertTrue(app.windows["New Leave Request"].exists)
        
        // Test keyboard shortcuts
        app.typeKey("n", modifierFlags: .command)
        XCTAssertEqual(app.windows.count, 2)
    }
}
```

### watchOS Testing
```swift
class WatchComplicationTests: XCTestCase {
    func testComplicationData() {
        let complication = ComplicationController()
        let template = complication.getCurrentTimelineEntry(for: .circularSmall) { entry in
            XCTAssertNotNil(entry)
            XCTAssertEqual(entry?.complicationTemplate.textProvider.text, "15")
        }
    }
}
```

### visionOS Testing
```swift
class VisionOSSpatialTests: XCTestCase {
    func testImmersiveSpaceTransition() {
        let app = XCUIApplication()
        app.launch()
        
        // Enter immersive space
        app.buttons["Enter Calendar View"].tap()
        
        // Verify spatial elements
        XCTAssertTrue(app.otherElements["ImmersiveSpace"].exists)
        
        // Test hand gestures
        app.performHandGesture(.pinch, at: CGPoint(x: 100, y: 100))
    }
}
```

## Test Coverage Requirements

### Coverage Targets
- **Overall**: >80%
- **ViewModels**: >90%
- **Services**: >85%
- **Utilities**: >95%
- **Views**: >70%

### Measuring Coverage
```bash
# Generate coverage report
xcodebuild test \
  -scheme Leavn \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult

# View coverage
xcrun xcov report TestResults.xcresult
```

### Coverage Configuration
```swift
// .xcovignore
- "*/Tests/*"
- "*/Mocks/*"
- "*/Generated/*"
- "*/Resources/*"
- "*View.swift" // Exclude if testing ViewModels instead
```

## CI/CD Integration

### GitHub Actions Configuration
```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-14
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_26.app
    
    - name: Run Unit Tests
      run: |
        xcodebuild test \
          -scheme Leavn \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
          -only-testing:LeavnTests
    
    - name: Run UI Tests
      run: |
        xcodebuild test \
          -scheme Leavn \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
          -only-testing:LeavnUITests
    
    - name: Generate Coverage Report
      run: |
        xcrun xcov report \
          --project Leavn.xcodeproj \
          --scheme Leavn \
          --output_directory coverage_report
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage_report/coverage.xml
```

### Fastlane Integration
```ruby
# fastlane/Fastfile
platform :ios do
  desc "Run all tests"
  lane :test do
    run_tests(
      scheme: "Leavn",
      devices: ["iPhone 15 Pro", "iPad Pro (12.9-inch)"],
      code_coverage: true,
      xcargs: "-parallel-testing-enabled YES"
    )
  end
  
  desc "Run UI tests only"
  lane :ui_tests do
    run_tests(
      scheme: "Leavn",
      only_testing: ["LeavnUITests"],
      devices: ["iPhone 15 Pro"]
    )
  end
end
```

## Performance Testing

### XCTest Performance
```swift
class PerformanceTests: XCTestCase {
    func testLargeDatassetLoading() {
        measure {
            let leaves = (0..<1000).map { i in
                Leave(id: "\(i)", type: .annual)
            }
            
            let viewModel = LeaveViewModel()
            viewModel.processLeaves(leaves)
        }
    }
    
    func testSyncPerformance() {
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        
        measure(options: options) {
            let expectation = expectation(description: "Sync complete")
            
            Task {
                try await SyncService.shared.performSync()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10)
        }
    }
}
```

## Testing Best Practices

### 1. Test Naming Convention
```swift
func test_MethodName_StateUnderTest_ExpectedBehavior() {
    // Example:
    func test_createLeave_withValidData_savesSuccessfully()
    func test_fetchEmployees_whenNetworkFails_showsError()
}
```

### 2. Arrange-Act-Assert Pattern
```swift
func testExample() {
    // Arrange
    let input = prepareTestData()
    
    // Act
    let result = sut.processData(input)
    
    // Assert
    XCTAssertEqual(result, expectedOutput)
}
```

### 3. Test Data Builders
```swift
extension Leave {
    static func testLeave(
        id: String = UUID().uuidString,
        type: LeaveType = .annual,
        status: LeaveStatus = .pending
    ) -> Leave {
        Leave(id: id, type: type, status: status)
    }
}
```

### 4. Async Testing
```swift
func testAsyncOperation() async throws {
    // Use async/await for cleaner async tests
    let result = try await sut.performAsyncOperation()
    XCTAssertNotNil(result)
}
```

### 5. Test Isolation
```swift
class TestableLeaveService: LeaveService {
    override init() {
        super.init()
        // Use in-memory database for tests
        self.database = InMemoryDatabase()
    }
}
```

## Debugging Failed Tests

### 1. Enable Verbose Logging
```swift
// In test setUp
UserDefaults.standard.set(true, forKey: "EnableTestLogging")
```

### 2. Capture Screenshots on Failure
```swift
override func tearDown() {
    if let failureCount = testRun?.failureCount, failureCount > 0 {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Failure Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    super.tearDown()
}
```

### 3. Test Artifacts
```bash
# Locate test artifacts
open ~/Library/Developer/Xcode/DerivedData/Leavn-*/Logs/Test/
```

## Conclusion

Comprehensive testing ensures the Leavn application maintains high quality across all platforms. Follow these guidelines to write effective tests that catch bugs early and provide confidence in your code.