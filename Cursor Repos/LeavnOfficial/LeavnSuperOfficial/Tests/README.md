# LeavnSuperOfficial Testing Suite

This directory contains the comprehensive testing suite for the Leavn Bible app, ensuring production-ready quality through multiple testing strategies.

## Test Structure

```
Tests/
├── LeavnAppTests/
│   ├── Features/           # Feature-specific tests
│   │   ├── Bible/         # Bible feature tests
│   │   ├── Settings/      # Settings feature tests
│   │   └── ...
│   ├── Services/          # Service layer tests
│   ├── Integration/       # End-to-end integration tests
│   ├── Performance/       # Performance and load tests
│   ├── Snapshot/          # Visual regression tests
│   └── TestUtilities/     # Shared test helpers and mocks
├── LeavnSuperOfficialUITests/  # UI automation tests
└── TestPlan.xctestplan    # Xcode test plan configuration
```

## Test Categories

### 1. Unit Tests
- **Coverage**: All TCA reducers, services, models, and utilities
- **Focus**: Business logic, state management, data transformations
- **Location**: `LeavnAppTests/Features/`, `LeavnAppTests/Services/`

### 2. Integration Tests
- **Coverage**: API integration, database operations, service interactions
- **Focus**: Component integration, data flow, external dependencies
- **Location**: `LeavnAppTests/Integration/`

### 3. UI Tests
- **Coverage**: Critical user flows, navigation, user interactions
- **Focus**: End-user experience, accessibility, device compatibility
- **Location**: `LeavnSuperOfficialUITests/`

### 4. Performance Tests
- **Coverage**: App launch, memory usage, network operations
- **Focus**: Speed, efficiency, resource utilization
- **Location**: `LeavnAppTests/Performance/`

### 5. Snapshot Tests
- **Coverage**: UI components, screens, visual states
- **Focus**: Visual regression, dark mode, different device sizes
- **Location**: `LeavnAppTests/Snapshot/`

## Running Tests

### Command Line

```bash
# Run all tests
./Scripts/run-tests.sh all

# Run specific test suite
./Scripts/run-tests.sh unit
./Scripts/run-tests.sh integration
./Scripts/run-tests.sh performance
./Scripts/run-tests.sh ui
./Scripts/run-tests.sh snapshot
```

### Xcode

1. Open the project in Xcode
2. Select the test plan from the scheme editor
3. Press `⌘U` to run tests

### Test Plans

- **Unit Tests**: Fast, isolated component tests
- **Integration Tests**: Tests with real dependencies
- **Performance Tests**: Metrics and benchmarks
- **UI Tests**: User interface automation

## Writing Tests

### Unit Test Example

```swift
@MainActor
func testBookSelection() async {
    let store = makeTestStore(
        initialState: BibleReducer.State(),
        reducer: BibleReducer.init,
        dependencies: {
            $0.bibleService = .mock
        }
    )
    
    await store.send(.selectBook(.john)) {
        $0.selectedBook = .john
        $0.selectedChapter = 1
    }
}
```

### Integration Test Example

```swift
func testRealAPIIntegration() async throws {
    guard let apiKey = ProcessInfo.processInfo.environment["ESV_API_KEY"] else {
        throw XCTSkip("ESV_API_KEY not set")
    }
    
    // Test with real API
    let chapter = try await service.fetchPassage(reference)
    XCTAssertFalse(chapter.verses.isEmpty)
}
```

### UI Test Example

```swift
func testNavigateToBibleAndSelectBook() throws {
    let app = XCUIApplication()
    app.launch()
    
    app.tabBars.buttons["Bible"].tap()
    app.buttons["BookSelectorButton"].tap()
    app.buttons["Book_John"].tap()
    
    XCTAssertTrue(app.staticTexts["John 1"].exists)
}
```

## Test Utilities

### Mock Dependencies
- `MockDependencies.swift`: Pre-configured mock services
- `TestFixtures.swift`: Sample data for testing
- `XCTestCase+Extensions.swift`: Helper methods

### Custom Assertions
```swift
// Async test helper
await waitForAsync {
    try await someAsyncOperation()
}

// Performance measurement
measureAsync {
    try await performExpensiveOperation()
}
```

## Continuous Integration

### GitHub Actions
```yaml
- name: Run Tests
  run: ./Scripts/run-tests.sh all
  env:
    ESV_API_KEY: ${{ secrets.ESV_API_KEY }}
```

### Code Coverage
- Minimum threshold: 80%
- Reports generated in `coverage/` directory
- View detailed report: `open coverage/coverage.json`

## Best Practices

1. **Test Naming**: Use descriptive names that explain what is being tested
2. **Isolation**: Each test should be independent and not rely on other tests
3. **Mock External Dependencies**: Use mock services for unit tests
4. **Real Dependencies for Integration**: Test with actual services when appropriate
5. **Performance Baselines**: Set and monitor performance metrics
6. **Visual Regression**: Update snapshots when UI intentionally changes

## Troubleshooting

### Common Issues

1. **Simulator Issues**
   ```bash
   xcrun simctl shutdown all
   xcrun simctl erase all
   ```

2. **Test Flakiness**
   - Add appropriate timeouts
   - Use `waitForExistence` for UI elements
   - Ensure proper test isolation

3. **API Key Missing**
   ```bash
   export ESV_API_KEY="your-api-key"
   ```

## Environment Variables

- `ESV_API_KEY`: Required for ESV API integration tests
- `UITEST_DISABLE_ANIMATIONS`: Set to "1" to disable animations in UI tests
- `CI`: Set when running in continuous integration

## Test Data

Test data is managed through:
- In-memory Core Data for database tests
- Mock JSON responses for API tests
- Fixture data in `TestFixtures.swift`

## Contributing

When adding new features:
1. Write unit tests for all new reducers and services
2. Add integration tests for external dependencies
3. Include UI tests for critical user paths
4. Update snapshot tests for UI changes
5. Ensure all tests pass before submitting PR