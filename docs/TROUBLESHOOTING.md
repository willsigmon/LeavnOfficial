# Troubleshooting Guide

Common issues and solutions for the Leavn Super Official iOS app.

## Table of Contents

- [Development Issues](#development-issues)
- [Build Errors](#build-errors)
- [Runtime Issues](#runtime-issues)
- [API Issues](#api-issues)
- [Performance Issues](#performance-issues)
- [UI/UX Issues](#uiux-issues)
- [Testing Issues](#testing-issues)
- [Deployment Issues](#deployment-issues)
- [Debug Tools](#debug-tools)

## Development Issues

### Swift Package Manager

#### Problem: Dependencies Won't Resolve

```
Failed to resolve dependencies
```

**Solutions:**

1. **Clear package cache**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   rm -rf .build
   ```

2. **Reset packages in Xcode**
   - File > Packages > Reset Package Caches
   - File > Packages > Resolve Package Versions

3. **Update dependencies**
   ```bash
   swift package update
   ```

#### Problem: Package Conflicts

```
multiple targets named 'X' in: Y, Z
```

**Solution:**
```swift
// In Package.swift, be explicit about products
.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
```

### Xcode Issues

#### Problem: "Cannot find type 'X' in scope"

**Solutions:**

1. **Clean build folder**
   - Product > Clean Build Folder (Shift+Cmd+K)

2. **Restart Xcode**
   - Quit Xcode completely
   - Delete DerivedData
   - Reopen project

3. **Check module imports**
   ```swift
   import ComposableArchitecture
   import SwiftUI
   @testable import LeavnApp
   ```

#### Problem: SwiftUI Previews Not Working

**Solutions:**

1. **Reset preview**
   - Click "Resume" or Opt+Cmd+P

2. **Check preview provider**
   ```swift
   struct BibleView_Previews: PreviewProvider {
       static var previews: some View {
           BibleView(
               store: Store(
                   initialState: BibleReducer.State(),
                   reducer: { BibleReducer() }
               )
           )
       }
   }
   ```

3. **Use preview-safe dependencies**
   ```swift
   store.dependencies = .preview
   ```

## Build Errors

### Signing & Capabilities

#### Problem: "Signing for 'X' requires a development team"

**Solution:**
1. Select project in navigator
2. Select target
3. Signing & Capabilities tab
4. Select team from dropdown

#### Problem: "Provisioning profile doesn't include entitlement"

**Solutions:**

1. **Regenerate profiles**
   ```bash
   fastlane match development --force
   fastlane match appstore --force
   ```

2. **Check entitlements file**
   ```xml
   <!-- Leavn.entitlements -->
   <key>com.apple.security.application-groups</key>
   <array>
       <string>group.com.leavn.bible</string>
   </array>
   ```

### Architecture Issues

#### Problem: "Building for iOS Simulator, but linking in object file built for iOS"

**Solution:**
```bash
# Exclude arm64 for simulator on M1 Macs
# In Build Settings
EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64
```

#### Problem: Minimum deployment target errors

**Solution:**
```swift
// In Package.swift
platforms: [
    .iOS(.v18)
]

// Check all dependencies support iOS 18
```

## Runtime Issues

### Crashes

#### Problem: "Fatal error: Unexpectedly found nil"

**Common causes and solutions:**

1. **Force unwrapping optionals**
   ```swift
   // ❌ Bad
   let text = verse.text!
   
   // ✅ Good
   guard let text = verse.text else { return }
   ```

2. **Missing mock data in tests**
   ```swift
   // Ensure all required fields are set
   let mockVerse = Verse(
       number: 1,
       text: "Test text",
       reference: .init(book: .genesis, chapter: 1, verse: 1)
   )
   ```

#### Problem: "Cannot find keypath"

**Solution:**
```swift
// Ensure state is @ObservableState
@Reducer
struct MyReducer {
    @ObservableState
    struct State: Equatable {
        // properties
    }
}
```

### Memory Issues

#### Problem: High memory usage

**Debugging steps:**

1. **Use Instruments**
   - Product > Profile
   - Select "Leaks" or "Allocations"

2. **Check for retain cycles**
   ```swift
   // ❌ Bad
   self.completion = {
       self.doSomething()
   }
   
   // ✅ Good
   self.completion = { [weak self] in
       self?.doSomething()
   }
   ```

3. **Monitor image loading**
   ```swift
   // Use Nuke for efficient image loading
   LazyImage(url: imageURL) { state in
       if let image = state.image {
           image
               .resizable()
               .aspectRatio(contentMode: .fit)
       }
   }
   ```

## API Issues

### ESV API

#### Problem: "401 Unauthorized"

**Solutions:**

1. **Check API key**
   ```swift
   // Verify key is stored
   let hasKey = await apiKeyManager.hasESVAPIKey()
   
   // Re-enter key if needed
   try await apiKeyManager.setESVAPIKey("new-key")
   ```

2. **Verify header format**
   ```swift
   request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
   ```

#### Problem: "Rate limit exceeded"

**Solutions:**

1. **Implement caching**
   ```swift
   struct CachedBibleService {
       private let cache = NSCache<NSString, ESVResponse>()
       
       func getPassage(_ reference: String) async throws -> ESVResponse {
           if let cached = cache.object(forKey: reference as NSString) {
               return cached
           }
           
           let response = try await api.getPassage(reference)
           cache.setObject(response, forKey: reference as NSString)
           return response
       }
   }
   ```

2. **Add rate limiting**
   ```swift
   actor RateLimiter {
       private var lastRequestTime: Date?
       private let minimumInterval: TimeInterval = 0.2 // 5 requests/second
       
       func throttle() async {
           if let last = lastRequestTime {
               let elapsed = Date().timeIntervalSince(last)
               if elapsed < minimumInterval {
                   try? await Task.sleep(nanoseconds: UInt64((minimumInterval - elapsed) * 1_000_000_000))
               }
           }
           lastRequestTime = Date()
       }
   }
   ```

### ElevenLabs API

#### Problem: "Insufficient credits"

**Solution:**
```swift
// Check quota before request
let quota = try await elevenLabsClient.getQuota()
if quota.charactersRemaining < text.count {
    throw AudioError.insufficientCredits
}
```

#### Problem: Audio playback issues

**Solutions:**

1. **Configure audio session**
   ```swift
   try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
   try AVAudioSession.sharedInstance().setActive(true)
   ```

2. **Handle interruptions**
   ```swift
   NotificationCenter.default.addObserver(
       self,
       selector: #selector(handleInterruption),
       name: AVAudioSession.interruptionNotification,
       object: nil
   )
   ```

## Performance Issues

### Slow Launch Time

#### Debugging:

1. **Profile launch**
   - Edit Scheme > Diagnostics > Logging
   - Enable "Launch Time Profile"

2. **Defer heavy operations**
   ```swift
   // ❌ Bad
   .onAppear {
       loadAllData()
   }
   
   // ✅ Good
   .task {
       await loadInitialData()
   }
   .task(priority: .background) {
       await preloadAdditionalData()
   }
   ```

### Scroll Performance

#### Problem: Jerky scrolling in lists

**Solutions:**

1. **Use lazy loading**
   ```swift
   ScrollView {
       LazyVStack {
           ForEach(verses) { verse in
               VerseRow(verse: verse)
           }
       }
   }
   ```

2. **Optimize view complexity**
   ```swift
   // Use simple views in lists
   struct VerseRow: View {
       let verse: Verse
       
       var body: some View {
           HStack {
               Text("[\(verse.number)]")
                   .font(.caption)
               Text(verse.text)
                   .font(.body)
           }
       }
   }
   ```

## UI/UX Issues

### Layout Issues

#### Problem: Content cut off on smaller devices

**Solution:**
```swift
ScrollView {
    content
}
.safeAreaInset(edge: .bottom) {
    // Account for tab bar
    Color.clear.frame(height: 49)
}
```

#### Problem: Dark mode colors not working

**Solution:**
```swift
// Use semantic colors
Color(.label)           // Adapts to dark/light
Color(.systemBackground) // Adapts to dark/light

// Or define adaptive colors
Color("AdaptiveBlue")   // In Assets.xcassets
```

### SwiftUI State Issues

#### Problem: View not updating

**Solutions:**

1. **Check state is observable**
   ```swift
   @ObservableState
   struct State: Equatable {
       var value: String
   }
   ```

2. **Ensure Equatable conformance**
   ```swift
   struct MyModel: Equatable {
       let id: UUID
       let name: String
       
       static func == (lhs: Self, rhs: Self) -> Bool {
           lhs.id == rhs.id && lhs.name == rhs.name
       }
   }
   ```

## Testing Issues

### Test Failures

#### Problem: "Test crashed with signal SIGABRT"

**Common causes:**

1. **Missing mocks**
   ```swift
   store.dependencies.esvClient = .mock
   store.dependencies.databaseClient = .mock
   ```

2. **Async timing issues**
   ```swift
   // Use proper async testing
   await store.send(.loadData)
   await store.receive(.dataLoaded(mockData))
   ```

#### Problem: Flaky tests

**Solutions:**

1. **Use controlled dependencies**
   ```swift
   store.dependencies.date = .constant(testDate)
   store.dependencies.uuid = .incrementing
   ```

2. **Add timeouts**
   ```swift
   await store.receive(.response, timeout: .seconds(2))
   ```

## Deployment Issues

### Upload Failures

#### Problem: "Invalid Swift Support"

**Solution:**
```bash
# Ensure using latest Xcode
sudo xcode-select -s /Applications/Xcode.app

# Archive with proper Swift support
xcodebuild archive \
  -scheme "Leavn" \
  -archivePath ./build/Leavn.xcarchive \
  -destination "generic/platform=iOS" \
  ENABLE_BITCODE=NO
```

#### Problem: "Missing Push Notification Entitlement"

**Solution:**
1. Enable Push Notifications in Capabilities
2. Regenerate provisioning profiles
3. Ensure entitlements file includes:
   ```xml
   <key>aps-environment</key>
   <string>production</string>
   ```

## Debug Tools

### Console Debugging

```swift
// Structured logging
import OSLog

extension Logger {
    static let bible = Logger(subsystem: "com.leavn.bible", category: "Bible")
    static let api = Logger(subsystem: "com.leavn.bible", category: "API")
}

// Usage
Logger.bible.debug("Loading chapter \(chapter)")
Logger.api.error("API request failed: \(error)")
```

### Debug Menu

```swift
#if DEBUG
struct DebugMenu: View {
    @Dependency(\.apiKeyManager) var apiKeyManager
    
    var body: some View {
        List {
            Button("Clear API Keys") {
                Task {
                    try? await apiKeyManager.clearAll()
                }
            }
            
            Button("Reset User Defaults") {
                UserDefaults.standard.removePersistentDomain(
                    forName: Bundle.main.bundleIdentifier!
                )
            }
            
            Button("Simulate Crash") {
                fatalError("Debug crash")
            }
        }
    }
}
#endif
```

### Network Debugging

```swift
// URLSession logging
extension URLSession {
    static let logged: URLSession = {
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(LoggingURLProtocol.self, at: 0)
        return URLSession(configuration: config)
    }()
}

class LoggingURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        print("🌐 \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
        return false
    }
}
```

### Memory Debugging

```swift
// Track object lifecycle
class MyClass {
    init() {
        print("✅ \(Self.self) initialized")
    }
    
    deinit {
        print("♻️ \(Self.self) deallocated")
    }
}
```

---

For additional support, contact the development team or check the project wiki.