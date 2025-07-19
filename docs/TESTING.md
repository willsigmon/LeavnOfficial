# Testing Strategy Guide

Comprehensive testing guide for the Leavn Super Official iOS app, covering unit tests, integration tests, UI tests, and best practices.

## Table of Contents

- [Testing Philosophy](#testing-philosophy)
- [Test Structure](#test-structure)
- [Unit Testing](#unit-testing)
- [Integration Testing](#integration-testing)
- [UI Testing](#ui-testing)
- [Snapshot Testing](#snapshot-testing)
- [Performance Testing](#performance-testing)
- [Test Utilities](#test-utilities)
- [Continuous Integration](#continuous-integration)
- [Best Practices](#best-practices)

## Testing Philosophy

### Core Principles

1. **Test Behavior, Not Implementation** - Focus on what the code does, not how
2. **Fast and Reliable** - Tests should run quickly and consistently
3. **Isolated** - Each test should be independent
4. **Readable** - Tests serve as documentation
5. **Maintainable** - Easy to update as code evolves

### Testing Pyramid

```
         ╱ UI Tests ╲        (Few)
       ╱─────────────╲
     ╱ Integration    ╲      (Some)
   ╱───────────────────╲
 ╱    Unit Tests        ╲    (Many)
╱───────────────────────╲
```

## Test Structure

### Directory Organization

```
Tests/
├── LeavnAppTests/
│   ├── Features/           # Feature-specific tests
│   │   ├── Bible/
│   │   ├── Community/
│   │   ├── Library/
│   │   └── Settings/
│   ├── Services/           # Service layer tests
│   ├── Models/             # Model tests
│   ├── Integration/        # Integration tests
│   ├── Performance/        # Performance tests
│   ├── Snapshot/          # Snapshot tests
│   └── TestUtilities/     # Shared test helpers
└── TestPlan.xctestplan   # Test configuration
```

## Unit Testing

### Testing Reducers

Reducers are pure functions, making them ideal for unit testing:

```swift
import ComposableArchitecture
import XCTest
@testable import LeavnApp

@MainActor
class BibleReducerTests: XCTestCase {
    func testLoadingPassage() async {
        let store = TestStore(
            initialState: BibleReducer.State(
                currentBook: .john,
                currentChapter: 3,
                verses: []
            ),
            reducer: { BibleReducer() }
        )
        
        // Configure dependencies
        store.dependencies.esvClient = .mock
        
        // Test action
        await store.send(.loadPassage) {
            $0.isLoading = true
        }
        
        // Test response
        await store.receive(.passageResponse(.success(mockVerses))) {
            $0.isLoading = false
            $0.verses = mockVerses
        }
    }
    
    func testLoadingPassageFailure() async {
        let store = TestStore(
            initialState: BibleReducer.State(),
            reducer: { BibleReducer() }
        )
        
        struct TestError: Error {}
        store.dependencies.esvClient.getPassage = { _, _, _ in
            throw TestError()
        }
        
        await store.send(.loadPassage) {
            $0.isLoading = true
        }
        
        await store.receive(.passageResponse(.failure(TestError()))) {
            $0.isLoading = false
            $0.error = "Failed to load passage"
        }
    }
}
```

### Testing Models

```swift
class BookmarkTests: XCTestCase {
    func testBookmarkCreation() {
        let bookmark = Bookmark(
            id: UUID(),
            reference: BibleReference(book: .john, chapter: 3, verse: 16),
            note: "God's love",
            dateCreated: Date()
        )
        
        XCTAssertEqual(bookmark.reference.book, .john)
        XCTAssertEqual(bookmark.reference.chapter, 3)
        XCTAssertEqual(bookmark.reference.verse, 16)
        XCTAssertEqual(bookmark.note, "God's love")
    }
    
    func testBookmarkEquality() {
        let id = UUID()
        let date = Date()
        
        let bookmark1 = Bookmark(
            id: id,
            reference: BibleReference(book: .john, chapter: 3, verse: 16),
            note: "Note",
            dateCreated: date
        )
        
        let bookmark2 = Bookmark(
            id: id,
            reference: BibleReference(book: .john, chapter: 3, verse: 16),
            note: "Note",
            dateCreated: date
        )
        
        XCTAssertEqual(bookmark1, bookmark2)
    }
}
```

### Testing Services

```swift
class BibleServiceTests: XCTestCase {
    var service: BibleService!
    var mockClient: ESVClient!
    
    override func setUp() {
        super.setUp()
        mockClient = .mock
        service = BibleService(client: mockClient)
    }
    
    func testCaching() async throws {
        // First call - hits API
        let verses1 = try await service.getVerses(book: .john, chapter: 3)
        XCTAssertEqual(verses1.count, 36)
        
        // Second call - uses cache
        let verses2 = try await service.getVerses(book: .john, chapter: 3)
        XCTAssertEqual(verses1, verses2)
        
        // Verify only one API call
        XCTAssertEqual(mockClient.callCount, 1)
    }
}
```

## Integration Testing

### API Integration Tests

```swift
class ESVAPIIntegrationTests: XCTestCase {
    var client: ESVClient!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Use test API key
        let testKey = try XCTUnwrap(ProcessInfo.processInfo.environment["ESV_TEST_API_KEY"])
        
        client = ESVClient.live
        client.dependencies.apiKeyManager.esvAPIKey = testKey
    }
    
    func testRealAPICall() async throws {
        let response = try await client.getPassage(.genesis, 1, 1)
        
        XCTAssertEqual(response.query, "Genesis 1:1")
        XCTAssertTrue(response.text.contains("In the beginning"))
        XCTAssertTrue(response.text.contains("God created"))
    }
    
    func testSearchAPI() async throws {
        let results = try await client.search("love")
        
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertTrue(results.first?.text.lowercased().contains("love") ?? false)
    }
}
```

### Database Integration Tests

```swift
class CoreDataIntegrationTests: XCTestCase {
    var container: NSPersistentContainer!
    var databaseClient: DatabaseClient!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // In-memory store for testing
        container = NSPersistentContainer(name: "LeavnModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        databaseClient = DatabaseClient(container: container)
    }
    
    func testSaveAndLoadBookmark() async throws {
        let bookmark = Bookmark(
            reference: BibleReference(book: .john, chapter: 3, verse: 16),
            note: "Test note"
        )
        
        // Save
        try await databaseClient.save(bookmark)
        
        // Load
        let loaded = try await databaseClient.loadBookmarks()
        
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.note, "Test note")
    }
}
```

## UI Testing

### Critical User Flows

```swift
class BibleReadingFlowTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testNavigateToBibleVerse() {
        // Skip onboarding if shown
        if app.buttons["Skip"].exists {
            app.buttons["Skip"].tap()
        }
        
        // Navigate to Bible tab
        app.tabBars.buttons["Bible"].tap()
        
        // Open book selector
        app.buttons["Select Book"].tap()
        
        // Select John
        app.cells["John"].tap()
        
        // Select chapter 3
        app.cells["Chapter 3"].tap()
        
        // Verify verse 16 is visible
        let verse16 = app.staticTexts["[16]"]
        XCTAssertTrue(verse16.waitForExistence(timeout: 5))
        
        // Test highlighting
        verse16.press(forDuration: 1.0)
        app.buttons["Highlight"].tap()
        
        // Verify highlight applied
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "[16]").element.isSelected)
    }
    
    func testSearchFunctionality() {
        app.tabBars.buttons["Bible"].tap()
        app.searchFields["Search Bible"].tap()
        app.searchFields["Search Bible"].typeText("love")
        app.buttons["Search"].tap()
        
        // Wait for results
        let firstResult = app.cells.firstMatch
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Tap result
        firstResult.tap()
        
        // Verify navigation
        XCTAssertTrue(app.navigationBars["Search Results"].exists)
    }
}
```

### Accessibility Testing

```swift
class AccessibilityTests: XCTestCase {
    func testVoiceOverLabels() {
        let app = XCUIApplication()
        app.launch()
        
        // Bible tab
        let bibleTab = app.tabBars.buttons["Bible"]
        XCTAssertEqual(bibleTab.label, "Bible")
        XCTAssertEqual(bibleTab.accessibilityHint, "Navigate to Bible reading")
        
        // Verify all interactive elements have labels
        let buttons = app.buttons.allElementsBoundByIndex
        for i in 0..<buttons.count {
            let button = buttons[i]
            XCTAssertFalse(button.label.isEmpty, "Button at index \(i) missing label")
        }
    }
}
```

## Snapshot Testing

### View Snapshot Tests

```swift
import SnapshotTesting
import SwiftUI
@testable import LeavnApp

class SnapshotTests: XCTestCase {
    func testBibleReaderView() {
        let view = BibleReaderView(
            store: Store(
                initialState: BibleReducer.State(
                    currentBook: .john,
                    currentChapter: 3,
                    verses: mockVerses
                ),
                reducer: { BibleReducer() }
            )
        )
        
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13Pro)))
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPad)))
    }
    
    func testDarkModeSnapshots() {
        let view = SettingsView(
            store: Store(
                initialState: SettingsReducer.State(theme: .dark),
                reducer: { SettingsReducer() }
            )
        )
        
        assertSnapshot(
            matching: view,
            as: .image(layout: .device(config: .iPhone13Pro), traits: .init(userInterfaceStyle: .dark))
        )
    }
}
```

## Performance Testing

### Measure Block Tests

```swift
class PerformanceTests: XCTestCase {
    var service: BibleService!
    
    override func setUp() {
        super.setUp()
        service = BibleService()
    }
    
    func testSearchPerformance() {
        let expectation = expectation(description: "Search completes")
        
        measure {
            Task {
                _ = try? await service.search("God")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10)
        }
    }
    
    func testDatabaseQueryPerformance() {
        let client = DatabaseClient()
        
        measure {
            let expectation = expectation(description: "Query completes")
            
            Task {
                _ = try? await client.loadBookmarks(limit: 1000)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5)
        }
    }
}
```

### Memory Testing

```swift
class MemoryTests: XCTestCase {
    func testNoMemoryLeaks() {
        autoreleasepool {
            var store: TestStore<BibleReducer.State, BibleReducer.Action>? = TestStore(
                initialState: BibleReducer.State(),
                reducer: { BibleReducer() }
            )
            
            // Use store
            Task {
                await store?.send(.loadPassage)
            }
            
            // Should deallocate
            store = nil
        }
        
        // Verify deallocation
        XCTAssertTrue(true) // Use memory graph debugger
    }
}
```

## Test Utilities

### Mock Dependencies

```swift
extension DependencyValues {
    static let test = {
        var dependencies = Self()
        dependencies.esvClient = .mock
        dependencies.elevenLabsClient = .mock
        dependencies.databaseClient = .mock
        dependencies.apiKeyManager = .mock
        dependencies.date = .constant(Date(timeIntervalSinceReferenceDate: 0))
        dependencies.uuid = .incrementing
        return dependencies
    }()
}
```

### Test Helpers

```swift
extension XCTestCase {
    func waitForAsync(
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line,
        _ block: () async throws -> Void
    ) {
        let expectation = expectation(description: "Async operation")
        
        Task {
            do {
                try await block()
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed: \(error)", file: file, line: line)
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
}
```

### Fixture Data

```swift
enum TestFixtures {
    static let mockVerses = [
        Verse(number: 16, text: "For God so loved the world..."),
        Verse(number: 17, text: "For God did not send his Son...")
    ]
    
    static let mockPrayer = Prayer(
        id: UUID(),
        title: "Test Prayer",
        content: "Please pray for...",
        author: "TestUser",
        prayerCount: 5,
        dateCreated: Date()
    )
    
    static func mockBookmarks(count: Int) -> [Bookmark] {
        (0..<count).map { i in
            Bookmark(
                reference: BibleReference(book: .genesis, chapter: i + 1, verse: 1),
                note: "Note \(i)",
                dateCreated: Date()
            )
        }
    }
}
```

## Continuous Integration

### CI Test Configuration

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-13
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Run tests
      run: |
        xcodebuild test \
          -scheme "Leavn" \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
          -resultBundlePath TestResults \
          -enableCodeCoverage YES
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        xcode: true
        xcode_archive_path: TestResults.xcresult
```

### Test Plans

```json
{
  "configurations": [
    {
      "name": "Unit Tests",
      "options": {
        "targetForVariableExpansion": {
          "name": "LeavnApp"
        }
      },
      "testTargets": [
        {
          "target": {
            "name": "LeavnAppTests"
          },
          "skippedTests": [
            "IntegrationTests",
            "PerformanceTests"
          ]
        }
      ]
    },
    {
      "name": "All Tests",
      "options": {
        "environmentVariableEntries": [
          {
            "key": "ESV_TEST_API_KEY",
            "value": "$(ESV_TEST_API_KEY)"
          }
        ]
      }
    }
  ]
}
```

## Best Practices

### 1. Test Naming

```swift
// ✅ Good: Descriptive, follows pattern
func test_loadingPassage_whenAPISucceeds_updatesStateWithVerses()

// ❌ Bad: Vague
func testLoad()
```

### 2. Arrange-Act-Assert

```swift
func testBookmarkCreation() {
    // Arrange
    let reference = BibleReference(book: .john, chapter: 3, verse: 16)
    let note = "Important verse"
    
    // Act
    let bookmark = Bookmark(reference: reference, note: note)
    
    // Assert
    XCTAssertEqual(bookmark.reference, reference)
    XCTAssertEqual(bookmark.note, note)
}
```

### 3. One Assertion Per Test

```swift
// ✅ Good: Focused test
func testBookmarkHasCorrectReference() {
    let bookmark = createBookmark()
    XCTAssertEqual(bookmark.reference.book, .john)
}

func testBookmarkHasCorrectChapter() {
    let bookmark = createBookmark()
    XCTAssertEqual(bookmark.reference.chapter, 3)
}

// ❌ Bad: Testing multiple things
func testBookmark() {
    let bookmark = createBookmark()
    XCTAssertEqual(bookmark.reference.book, .john)
    XCTAssertEqual(bookmark.reference.chapter, 3)
    XCTAssertNotNil(bookmark.note)
    XCTAssertTrue(bookmark.dateCreated < Date())
}
```

### 4. Use Test Doubles Appropriately

- **Stub**: Provides canned responses
- **Mock**: Verifies interactions
- **Fake**: Working implementation for testing
- **Spy**: Records interactions for verification

### 5. Keep Tests Fast

- Use in-memory databases
- Mock network calls
- Avoid sleep/wait
- Run slow tests separately

### 6. Test Edge Cases

```swift
func testEmptySearchQuery() async {
    let results = try? await service.search("")
    XCTAssertNil(results)
}

func testVeryLongSearchQuery() async {
    let longQuery = String(repeating: "a", count: 1000)
    let results = try? await service.search(longQuery)
    XCTAssertNil(results)
}
```

### 7. Maintain Test Coverage

- Aim for >80% code coverage
- Focus on critical paths
- Don't test generated code
- Quality over quantity

---

For more examples, see the test implementations in `Tests/LeavnAppTests/`.