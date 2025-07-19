# Architecture Overview

This document provides a comprehensive overview of the Leavn Super Official iOS app architecture, patterns, and design decisions.

## Table of Contents

- [Core Architecture](#core-architecture)
- [The Composable Architecture (TCA)](#the-composable-architecture-tca)
- [Module Structure](#module-structure)
- [Data Flow](#data-flow)
- [Dependency Management](#dependency-management)
- [State Management](#state-management)
- [Navigation](#navigation)
- [Testing Strategy](#testing-strategy)
- [Performance Considerations](#performance-considerations)
- [Security Architecture](#security-architecture)

## Core Architecture

The app follows a modular, unidirectional architecture built on The Composable Architecture (TCA) framework. This provides:

- **Predictable State Management**: All state changes flow through reducers
- **Testability**: Pure functions and dependency injection
- **Modularity**: Features are self-contained modules
- **Type Safety**: Leveraging Swift's type system

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI Views                         │
├─────────────────────────────────────────────────────────────┤
│                    TCA Store & Reducers                      │
├─────────────────────────────────────────────────────────────┤
│                        Dependencies                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   API    │  │   Data   │  │  Audio   │  │ Offline  │   │
│  │ Clients  │  │   Base   │  │ Service  │  │ Service  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
├─────────────────────────────────────────────────────────────┤
│                     External Services                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ ESV API  │  │ElevenLabs│  │Community │  │   Core   │   │
│  │          │  │   API    │  │   API    │  │   Data   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## The Composable Architecture (TCA)

### Core Concepts

1. **State**: Describes the entire state of a feature
2. **Action**: All possible actions that can occur
3. **Reducer**: Pure function that evolves state
4. **Store**: Runtime that drives the feature
5. **Effect**: Describes asynchronous work

### Example Feature Structure

```swift
@Reducer
struct BibleReducer {
    @ObservableState
    struct State: Equatable {
        var currentBook: Book
        var currentChapter: Int
        var verses: [Verse]
        var isLoading: Bool
    }
    
    enum Action {
        case viewAppeared
        case bookSelected(Book)
        case chapterSelected(Int)
        case versesResponse(Result<[Verse], Error>)
    }
    
    @Dependency(\.bibleService) var bibleService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                state.isLoading = true
                return .run { send in
                    await send(.versesResponse(
                        Result { try await bibleService.loadVerses() }
                    ))
                }
            // ... other cases
            }
        }
    }
}
```

## Module Structure

### Source Organization

```
Sources/
├── App/                      # App entry point
│   └── LeavnSuperOfficialApp.swift
└── LeavnApp/                # Main app module
    ├── Core/                # Core architecture
    │   ├── AppReducer.swift
    │   ├── AppView.swift
    │   └── Configuration/
    ├── Features/            # Feature modules
    │   ├── Bible/
    │   ├── Community/
    │   ├── Library/
    │   ├── Settings/
    │   └── Onboarding/
    ├── Models/              # Domain models
    ├── Services/            # Service layer
    ├── DesignSystem/        # UI components
    └── Utils/               # Utilities
```

### Feature Module Structure

Each feature follows a consistent structure:

```
Bible/
├── BibleReducer.swift       # Feature logic
├── BibleView.swift          # Main view
└── Components/              # Sub-components
    ├── BibleReaderView.swift
    ├── BookSelectorView.swift
    └── AudioControlsOverlay.swift
```

## Data Flow

### Unidirectional Data Flow

1. **User Action** → View sends action to Store
2. **Reducer** → Processes action, updates state
3. **Effect** → Performs side effects (API calls, etc.)
4. **State Update** → New state flows back to View
5. **View Update** → SwiftUI re-renders with new state

### Example Flow: Loading Bible Chapter

```
User taps chapter
    ↓
View: .send(.chapterSelected(3))
    ↓
Reducer: state.currentChapter = 3
         state.isLoading = true
    ↓
Effect: bibleService.loadChapter(3)
    ↓
API Response
    ↓
Reducer: .versesResponse(verses)
         state.verses = verses
         state.isLoading = false
    ↓
View: Updates to show verses
```

## Dependency Management

### Dependency Injection Pattern

All external dependencies are injected using TCA's dependency system:

```swift
// Define dependency
struct BibleService {
    var loadPassage: (Book, Int) async throws -> [Verse]
    var search: (String) async throws -> [SearchResult]
}

// Register dependency
extension BibleService: DependencyKey {
    static let liveValue = Self(
        loadPassage: { book, chapter in
            // Real implementation
        },
        search: { query in
            // Real implementation
        }
    )
}

// Use in reducer
@Dependency(\.bibleService) var bibleService
```

### Key Dependencies

- **APIKeyManager**: Secure storage of API credentials
- **UserDefaults**: User preferences
- **DatabaseClient**: Core Data operations
- **AudioService**: Audio playback management
- **NetworkLayer**: HTTP networking
- **OfflineService**: Offline content management

## State Management

### Global State

The app maintains a global state tree rooted in `AppReducer`:

```swift
struct AppReducer.State {
    var bible: BibleReducer.State
    var community: CommunityReducer.State
    var library: LibraryReducer.State
    var settings: SettingsReducer.State
    var selectedTab: Tab
}
```

### Local State

Features manage their own local state, which can include:

- UI state (loading, errors)
- Domain data (verses, notes)
- Navigation state
- Form data

### State Persistence

- **UserDefaults**: Simple preferences
- **Core Data**: Complex domain data
- **Keychain**: Sensitive information
- **File System**: Downloaded content

## Navigation

### Tab-Based Navigation

Primary navigation uses SwiftUI's TabView:

```swift
TabView(selection: $store.selectedTab) {
    BibleView(store: store.scope(state: \.bible, action: \.bible))
        .tabItem { Label("Bible", systemImage: "book.fill") }
        .tag(Tab.bible)
    // ... other tabs
}
```

### Deep Linking

The app supports deep links for navigation:

- `leavn://bible/john/3/16` - Navigate to verse
- `leavn://community/prayer/123` - View prayer request
- `leavn://library/note/456` - Open specific note

### Modal Presentation

Modals are managed through state:

```swift
struct State {
    @Presents var bookSelector: BookSelectorReducer.State?
}
```

## Testing Strategy

### Unit Tests

- **Reducers**: Test state transitions
- **Dependencies**: Mock implementations
- **Models**: Data validation

### Integration Tests

- **API Integration**: Real API calls
- **Database Operations**: Core Data tests
- **Service Layer**: End-to-end flows

### UI Tests

- **Critical Paths**: User journeys
- **Accessibility**: VoiceOver support
- **Performance**: Scroll performance

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load content as needed
2. **Caching**: In-memory and disk caching
3. **Pagination**: Large data sets
4. **Background Processing**: Heavy operations
5. **Image Optimization**: Proper sizing and formats

### Memory Management

- Weak references for delegates
- Proper cleanup in effects
- Limited in-memory cache sizes
- Background memory warnings

## Security Architecture

### API Key Security

```swift
// Stored in Keychain, never in code
@Dependency(\.apiKeyManager) var apiKeyManager

let apiKey = try await apiKeyManager.getESVAPIKey()
```

### Network Security

- Certificate pinning for critical endpoints
- App Transport Security enforcement
- Request signing where applicable

### Data Protection

- Core Data encryption
- Keychain access control
- File protection attributes
- No sensitive data in logs

### Privacy

- Minimal data collection
- Anonymous mode support
- Clear data management
- GDPR compliance ready

## Architecture Decision Records (ADRs)

### ADR-001: Choice of TCA

**Status**: Accepted  
**Context**: Need for predictable state management  
**Decision**: Use The Composable Architecture  
**Consequences**: Learning curve but better testability

### ADR-002: Swift Concurrency

**Status**: Accepted  
**Context**: Modern async patterns needed  
**Decision**: Use async/await throughout  
**Consequences**: Cleaner code, iOS 15+ requirement

### ADR-003: Core Data for Persistence

**Status**: Accepted  
**Context**: Need robust local storage  
**Decision**: Use Core Data with CloudKit  
**Consequences**: Complex but powerful persistence

## Best Practices

1. **State Shape**: Keep state normalized and minimal
2. **Action Naming**: Use descriptive, domain-specific names
3. **Effect Management**: Always handle cancellation
4. **Dependency Design**: Keep interfaces focused
5. **Testing First**: Write tests alongside features
6. **Documentation**: Document complex business logic

## Monitoring and Analytics

### Crash Reporting

- Integration with crash reporting service
- Symbolication for release builds
- User privacy respected

### Performance Monitoring

- API response times
- Screen load times
- Memory usage tracking
- Battery impact analysis

### Usage Analytics

- Feature adoption rates
- User flow analysis
- Error rate tracking
- Performance metrics

---

For specific implementation details, refer to the source code and inline documentation.