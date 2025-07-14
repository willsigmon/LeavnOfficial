# iOS 26 / Swift 6.2 Migration Checklist for Leavn

## ✅ Completed Tasks

### 1. Module Dependencies Fixed
- [x] All test targets have correct paths specified
- [x] Package.swift properly declares all dependencies
- [x] Removed circular imports between modules
- [x] Consolidated duplicate type definitions

### 2. Type System Cleanup
- [x] Moved shared types to LeavnCore
- [x] Fixed ambiguous type references
- [x] Added missing protocol definitions

### 3. Build Configuration
- [x] Fixed trailing newline/whitespace issues
- [x] App icons generated for all platforms
- [x] Info.plist optimized for iOS 26

## 🚀 Next Steps for Full iOS 26 Compliance

### 1. **Adopt @Observable Macro** (High Priority)
Replace @ObservableObject with @Observable for all ViewModels:
```swift
// Old (iOS 17-)
class BibleViewModel: ObservableObject {
    @Published var verses: [Verse] = []
}

// New (iOS 26+)
@Observable
class BibleViewModel {
    var verses: [Verse] = []
}
```

### 2. **Update SwiftUI Navigation**
Use new NavigationStack and NavigationSplitView APIs:
```swift
NavigationStack {
    BibleView()
        .navigationDestination(for: Verse.self) { verse in
            VerseDetailView(verse: verse)
        }
}
```

### 3. **Implement Liquid Glass Design**
Apply new iOS 26 design modifiers:
```swift
.glassEffect()
.contextualRadius()
.adaptiveCorners()
```

### 4. **Add Swift 6 Concurrency Compliance**
- Mark all async closures as @Sendable
- Use actors for shared mutable state
- Enable strict concurrency checking

### 5. **Accessibility Enhancements**
- Add .accessibilityLabel() to all interactive elements
- Support Dynamic Type with .dynamicTypeSize()
- Test with VoiceOver and Voice Control

### 6. **Testing Infrastructure**
- Add ViewInspector for SwiftUI testing
- Implement 80%+ code coverage
- Add UI tests for critical flows

### 7. **CI/CD Updates**
- Update GitHub Actions to use Xcode 26
- Add SPM cache for faster builds
- Enable parallel testing

### 8. **Performance Optimizations**
- Implement lazy loading for Bible text
- Use .task {} for async work
- Profile with Instruments

## 📋 Module-Specific Tasks

### LeavnCore
- [ ] Update to use @Observable for shared state
- [ ] Add Sendable conformance to all types
- [ ] Document all public APIs

### LeavnServices
- [ ] Convert to async/await throughout
- [ ] Add proper error handling with typed throws
- [ ] Implement retry logic for network calls

### DesignSystem
- [ ] Apply iOS 26 design language
- [ ] Add dark mode support
- [ ] Create reusable glass effect components

### UI Modules (Bible, Search, Library, etc.)
- [ ] Update to new navigation APIs
- [ ] Add accessibility support
- [ ] Implement adaptive layouts

## 🔧 Build Commands

```bash
# Clean and rebuild
make clean
make setup
make build-ios

# Run tests
make test

# Generate documentation
make docs

# Lint code
make lint
```

## 📚 References

- [Swift 6 Migration Guide](https://www.swift.org/migration/)
- [iOS 26 Design Guidelines](https://developer.apple.com/design/)
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui)