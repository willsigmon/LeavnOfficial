# ADR-002: Adopt Swift Concurrency (async/await)

## Status
Accepted

## Context
The app needs to handle numerous asynchronous operations:
- API calls to ESV and ElevenLabs
- Database operations with Core Data
- File I/O for offline content
- Network requests for community features

We need a consistent, modern approach to asynchronous programming.

## Decision
We will use Swift Concurrency (async/await) throughout the application instead of callbacks or Combine publishers for asynchronous operations.

## Rationale

### Pros
- **Readability**: Linear code flow is easier to understand
- **Error Handling**: Native Swift error handling with try/catch
- **Performance**: Efficient thread management by Swift runtime
- **Future-Proof**: Apple's recommended approach going forward
- **Type Safety**: Compile-time checks for concurrent code
- **Structured Concurrency**: Clear lifecycle management

### Cons
- **iOS 15+**: Requires iOS 15 minimum deployment target
- **Learning Curve**: New concepts like actors and sendability
- **Migration**: Existing callback-based code needs updating
- **Debugging**: Different debugging patterns than traditional GCD

## Alternatives Considered

### Combine
- Pros: Reactive programming, good for streams
- Cons: Steep learning curve, being superseded by async/await

### Grand Central Dispatch (GCD)
- Pros: Well-understood, battle-tested
- Cons: Callback hell, manual thread management

### PromiseKit/Other Libraries
- Pros: Nice API, proven patterns
- Cons: Third-party dependency, not native

## Implementation

### API Calls
```swift
func loadPassage(book: Book, chapter: Int) async throws -> [Verse] {
    let response = try await urlSession.data(for: request)
    return try decoder.decode([Verse].self, from: response.0)
}
```

### TCA Integration
```swift
return .run { send in
    do {
        let verses = try await bibleService.loadPassage(book, chapter)
        await send(.passageLoaded(verses))
    } catch {
        await send(.loadingFailed(error))
    }
}
```

### Actor for Thread Safety
```swift
actor CacheManager {
    private var cache: [String: Data] = [:]
    
    func get(_ key: String) -> Data? {
        cache[key]
    }
    
    func set(_ key: String, data: Data) {
        cache[key] = data
    }
}
```

## Consequences

### Positive
- Cleaner, more maintainable code
- Better performance through automatic optimization
- Reduced bugs from race conditions
- Easier testing with async test methods

### Negative
- Requires iOS 15+ (acceptable for new app)
- Team needs to learn new concurrency model
- Some third-party libraries may not support async/await yet

## Migration Strategy

1. New code uses async/await exclusively
2. Wrap existing callbacks in continuations
3. Gradually migrate critical paths
4. Use `@MainActor` for UI updates

## References
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [WWDC21: Meet async/await](https://developer.apple.com/videos/play/wwdc2021/10132/)
- [Swift Evolution SE-0296](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md)