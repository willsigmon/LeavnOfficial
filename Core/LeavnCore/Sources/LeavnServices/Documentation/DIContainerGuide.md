# Dependency Injection Container Guide

## Overview

The Leavn app uses Factory for dependency injection, providing a type-safe, testable architecture for managing dependencies across the application.

## Architecture

### Service Protocols
All services are defined by protocols in `ServiceProtocols.swift`, ensuring:
- Clear contracts between modules
- Easy testing with mock implementations
- Type safety throughout the app

### Container Structure
```swift
public extension Container {
    var serviceName: Factory<ServiceProtocol> {
        self { ServiceImplementation() }
            .singleton // or .cached, .unique
    }
}
```

## Core Services

### Network Service
**Protocol**: `NetworkServiceProtocol`
**Purpose**: Handles all HTTP communication
**Features**:
- Async/await API
- Type-safe request/response handling
- Network reachability monitoring
- Automatic retry logic

### Analytics Service
**Protocol**: `AnalyticsServiceProtocol`
**Purpose**: Tracks user events and app usage
**Features**:
- Multiple provider support
- Error tracking
- User identification
- Debug console logging

### Bible Service
**Protocol**: `BibleServiceProtocol`
**Purpose**: Manages Bible content retrieval
**Features**:
- Multiple translation support
- Chapter and verse fetching
- Search functionality
- Daily verse selection

### Audio Service
**Protocol**: `AudioServiceProtocol`
**Purpose**: Text-to-speech and audio playback
**Features**:
- ElevenLabs integration
- Voice configuration
- Progress tracking
- Caching support

### Authentication Service
**Protocol**: `AuthenticationServiceProtocol`
**Purpose**: User authentication and session management
**Features**:
- Email/password authentication
- Token management (Keychain storage)
- Session persistence
- Password reset

### Storage Services

#### User Defaults Storage
- Non-sensitive app preferences
- Quick access settings
- Lightweight data

#### Keychain Storage
- Secure credential storage
- Authentication tokens
- Sensitive user data

#### File Storage
- Document persistence
- Large data sets
- Import/export functionality

#### Cache Storage
- Hybrid memory/disk caching
- Automatic eviction
- Performance optimization

## Module-Specific Services

### Library Module
- `LibraryRepositoryProtocol`: Manages saved content
- Use cases for CRUD operations
- Collection management
- Sync functionality

### Settings Module
- `SettingsRepositoryProtocol`: App configuration
- Settings validation and migration
- Backup/restore functionality
- Change tracking

### Search Module
- `SearchRepositoryProtocol`: Content search
- Recent searches
- Multi-source search
- Result ranking

## Conditional Compilation

Services use conditional compilation for optional modules:

```swift
var service: Factory<ServiceProtocol> {
    self {
        #if canImport(ModuleName)
        RealImplementation()
        #else
        MockImplementation()
        #endif
    }
}
```

This allows:
- Building without all modules present
- Platform-specific implementations
- Feature flag support

## Dependency Injection Patterns

### Direct Injection
```swift
class MyViewModel {
    @Injected(\.bibleService) var bibleService
}
```

### Lazy Injection
```swift
class MyService {
    @LazyInjected(\.expensiveService) var service
}
```

### Manual Resolution
```swift
let service = Container.shared.networkService()
```

## Testing

### Mock Services
All protocols have corresponding mock implementations:
- `MockNetworkService`
- `MockAnalyticsService`
- `MockBibleService`
- etc.

### Test Container Setup
```swift
Container.shared.reset()
Container.shared.networkService.register { 
    MockNetworkService() 
}
```

### Integration Testing
```swift
func testServiceIntegration() async throws {
    let bible = Container.shared.bibleService()
    let verse = try await bible.getDailyVerse()
    XCTAssertNotNil(verse)
}
```

## Configuration

### Environment-Based
```swift
let config = LeavnConfiguration(
    environment: .development,
    apiKey: "dev-key"
)
ServiceLocator.shared.configure(with: config)
```

### Feature Flags
```swift
if Container.shared.configuration().features.enableAudioBible {
    // Enable audio features
}
```

## Best Practices

1. **Always use protocols** - Never depend on concrete types
2. **Scope appropriately** - Use `.singleton` for stateless services
3. **Handle errors gracefully** - Services should fail safely
4. **Document dependencies** - Clear comments for complex setups
5. **Test with mocks** - Every service should be testable
6. **Avoid circular dependencies** - Use lazy injection if needed

## Troubleshooting

### Missing Module Errors
- Ensure all required packages are included in the target
- Check conditional compilation flags
- Verify import statements

### Type Mismatch Errors
- Confirm protocol conformance
- Check Factory return types
- Verify type casting in view models

### Singleton Issues
- Use `.singleton` for shared state
- Consider `.cached` for user-scoped data
- Use `.unique` for fresh instances

## Future Enhancements

1. **Cloud Storage Adapter** - For settings sync
2. **Offline Queue Service** - For sync operations
3. **Push Notification Service** - For engagement
4. **Widget Service** - For home screen widgets
5. **Machine Learning Service** - For personalization