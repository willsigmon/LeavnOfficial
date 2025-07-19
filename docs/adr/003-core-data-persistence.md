# ADR-003: Use Core Data for Local Persistence

## Status
Accepted

## Context
The app needs robust local storage for:
- Bookmarks and notes
- Downloaded Bible content for offline reading
- User preferences and settings
- Reading history and progress
- Cached API responses

We need a persistence solution that is reliable, performant, and integrates well with iOS.

## Decision
We will use Core Data as our primary persistence layer, with potential CloudKit integration for sync.

## Rationale

### Pros
- **Native Framework**: First-party Apple solution with deep iOS integration
- **Performance**: Optimized for iOS with lazy loading and faulting
- **CloudKit Sync**: Built-in support for iCloud synchronization
- **Migrations**: Robust schema migration support
- **Querying**: Powerful NSPredicate-based queries
- **Memory Management**: Automatic object graph management
- **SwiftUI Integration**: Works well with @FetchRequest

### Cons
- **Complexity**: Steeper learning curve than simple solutions
- **Concurrency**: Requires careful context management
- **Debugging**: Can be challenging to debug issues
- **Verbosity**: More boilerplate than modern alternatives

## Alternatives Considered

### SwiftData (New)
- Pros: Modern Swift-first API, simpler syntax
- Cons: iOS 17+ only, less mature, limited features

### SQLite Direct
- Pros: Full control, portable, well-understood
- Cons: Manual everything, no object mapping

### Realm
- Pros: Simple API, good performance
- Cons: Third-party dependency, larger binary size

### UserDefaults + File System
- Pros: Dead simple for small data
- Cons: Not scalable, no querying, manual management

## Implementation

### Core Data Stack
```swift
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "LeavnModel")
        
        // Enable CloudKit sync
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, 
            forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
}
```

### Entity Design
```swift
// Bookmark Entity
@objc(CDBookmark)
class CDBookmark: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var bookName: String
    @NSManaged var chapter: Int32
    @NSManaged var verse: Int32
    @NSManaged var note: String?
    @NSManaged var dateCreated: Date
    @NSManaged var color: String
}
```

### TCA Integration
```swift
struct DatabaseClient {
    var saveBookmark: (Bookmark) async throws -> Void
    var loadBookmarks: () async throws -> [Bookmark]
    var deleteBookmark: (UUID) async throws -> Void
}
```

## Consequences

### Positive
- Reliable, battle-tested persistence
- Free iCloud sync with CloudKit
- Good performance for our data size
- Integrates well with SwiftUI

### Negative
- More complex than needed for simple data
- Team needs Core Data knowledge
- Potential for threading issues if not careful
- Migrations can be tricky

## Best Practices

1. **Use NSPersistentContainer** for modern Core Data stack
2. **Background contexts** for heavy operations
3. **Batch operations** for bulk updates
4. **Proper error handling** for all operations
5. **Test migrations** thoroughly
6. **Monitor performance** with Instruments

## Migration Strategy

1. Start with simple entities (Bookmarks, Notes)
2. Add CloudKit sync after local storage works
3. Implement proper migration paths
4. Test with large datasets
5. Monitor crash reports related to Core Data

## References
- [Core Data Documentation](https://developer.apple.com/documentation/coredata)
- [Core Data Best Practices](https://developer.apple.com/videos/play/wwdc2019/230/)
- [CloudKit + Core Data](https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit)