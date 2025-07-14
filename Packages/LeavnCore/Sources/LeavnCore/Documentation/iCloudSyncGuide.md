# iCloud Sync Implementation Guide

## Overview

The Leavn app features a comprehensive iCloud sync system that automatically synchronizes user data across all devices using Core Data + CloudKit integration. This ensures users have access to their reading progress, preferences, bookmarks, and notes on any device where they're signed in with their Apple ID.

## Architecture

### Core Components

1. **PersistenceController**: Manages Core Data stack with CloudKit integration
2. **UserDataManager**: Handles user-specific data operations and sync coordination
3. **Core Data Model**: Defines entities for user data with CloudKit compatibility
4. **Apple Sign-In Integration**: Seamless authentication with iCloud sync

### Data Model

The Core Data model includes the following CloudKit-enabled entities:

- **UserProfile**: User information, statistics, and Apple ID integration
- **UserPreferences**: App settings, theme, translation, AI preferences
- **ReadingProgress**: Book/chapter/verse tracking per user
- **Bookmark**: Saved verses with notes and tags
- **Note**: User-created notes linked to specific verses
- **ReadingSession**: Reading time tracking and statistics

## Key Features

### Automatic Migration

- Seamlessly migrates existing UserDefaults data to Core Data
- Preserves user preferences and reading progress
- One-time migration with safety checks

### Real-time Sync

- Automatic background synchronization
- Remote change notifications
- Conflict resolution with CloudKit

### Apple Sign-In Integration

- Secure authentication with Apple ID
- No password management required
- TestFlight and production compatibility

### Offline Support

- Local data persistence
- Sync when network becomes available
- Graceful degradation without internet

## TestFlight Considerations

### CloudKit Configuration

- Production environment configured for TestFlight
- Private database scope for user data privacy
- Automatic schema deployment

### Entitlements

```xml
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
    <string>CloudDocuments</string>
</array>
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.leavn.app</string>
</array>
```

### Testing Guidelines

1. **Fresh Install**: Test with new Apple ID accounts
2. **Multi-Device**: Verify sync across iPhone, iPad, Mac
3. **Network Conditions**: Test offline/online scenarios
4. **Account Changes**: Test signing out and back in

## Implementation Details

### Core Data + CloudKit Setup

```swift
let container = NSPersistentCloudKitContainer(name: "LeavnDataModel")
description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
    containerIdentifier: "iCloud.com.leavn.app"
)
description.cloudKitContainerOptions?.databaseScope = .private
```

### User Data Migration

```swift
private func performUserDefaultsMigration() async {
    // Migrates existing UserDefaults to Core Data
    // Preserves user preferences and reading progress
    // One-time operation with completion tracking
}
```

### Sync Status Monitoring

The Settings screen provides real-time sync status:

- iCloud account status
- Last sync timestamp
- Manual sync trigger
- Error reporting

## Error Handling

### Common Scenarios

1. **No iCloud Account**: Graceful fallback to local storage
2. **Network Unavailable**: Queue operations for later sync
3. **CloudKit Quota**: Inform user of storage limits
4. **Permissions**: Guide user to enable iCloud Drive

### Recovery Strategies

- Automatic retry with exponential backoff
- User-initiated manual sync
- Local data preservation
- Clear error messaging

## Privacy & Security

### Data Protection

- All data stored in user's private CloudKit database
- End-to-end encryption via CloudKit
- No server-side data access by developers
- GDPR and privacy regulation compliant

### User Control

- Users can disable iCloud sync
- Local data always available
- Easy data export/deletion
- Transparent sync status

## Performance Optimization

### Efficient Syncing

- Incremental updates only
- Background queue operations
- Batched operations for large datasets
- Smart conflict resolution

### Memory Management

- Lazy loading of large datasets
- Proper Core Data context management
- Release of unused resources
- Optimized fetch requests

## Troubleshooting

### Common Issues

1. **Sync Not Working**
   - Check iCloud account status
   - Verify network connectivity
   - Force manual sync

2. **Data Not Appearing**
   - Wait for background sync
   - Check CloudKit status
   - Verify Apple ID consistency

3. **TestFlight Specific**
   - Ensure production entitlements
   - Test with fresh Apple ID
   - Verify CloudKit container access

### Debug Tools

- Comprehensive logging via OSLog
- CloudKit status monitoring
- Sync progress indicators
- Error reporting and recovery

## Future Enhancements

### Planned Features

- Sync progress indicators
- Conflict resolution UI
- Advanced backup options
- Cross-platform compatibility

### Performance Improvements

- Optimized batch operations
- Smart prefetching
- Background app refresh
- Reduced memory footprint

## Support

For issues related to iCloud sync:

1. Check Settings > iCloud Sync status
2. Try manual sync
3. Verify iCloud account settings
4. Contact support with sync logs

---

*This implementation ensures robust, secure, and user-friendly data synchronization across all Apple devices while maintaining privacy and performance standards.* 