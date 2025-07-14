# Leavn App Component Mapping - Phase 1: Discovery

## 1. VIEWS (UI Layer)

### Main Navigation Structure
- **LeavnApp.swift** → Entry point
- **ContentView.swift** → Wrapper for MainTabView
- **MainTabView.swift** → Tab navigation with 5 tabs:
  1. HomeView (house icon)
  2. BibleView (book icon)
  3. SearchView (magnifying glass)
  4. LibraryView (books vertical)
  5. CommunityView (person.3 icon)

### Feature Views

#### Home Module
- **HomeView.swift** - Main dashboard with devotions, verse of the day, stats, quick actions
  - Components: Devotion cards, Stats display, Quick action buttons
  - State: todaysDevotion, verseOfTheDay, readingStreak, userName
  - Uses @EnvironmentObject DIContainer

#### Bible Module
- **BibleView.swift** - Bible reader main view
- **BibleReaderView.swift** - Actual text display
- **BookPickerView.swift** - Book/chapter selection
- **VerseView.swift** - Individual verse display
- **VerseDetailView.swift** - Detailed verse view
- **DevotionReaderView.swift** - Devotion content reader
- **ReadingModeView.swift** - Reading mode interface
- **ReaderSettingsView.swift** - Reading preferences
- **VoiceoverModeView.swift** - Accessibility/voice features
- **OnboardingView.swift** - Bible-specific onboarding

#### Search Module
- **SearchView.swift** - Main search interface

#### Library Module
- **LibraryView.swift** - Saved content, bookmarks, notes

#### Community Module
- **CommunityView.swift** - Social features
- **NotificationCenterView.swift** - Notifications

#### Settings Module
- **SettingsView.swift** - Main settings
- **AboutView.swift** - About app
- **ThemePickerView.swift** - Theme selection
- **TranslationPickerView.swift** - Bible translation picker
- **TheologicalPerspectivePickerView.swift** - Theological preferences
- **AIProvidersView.swift** - AI settings
- **APIKeyInputView.swift** - API key management
- **DevelopmentAssistantView.swift** - Dev tools
- **HelpSupportView.swift** - Help/support

#### Authentication Module
- **SignInView.swift** - Login interface
- **AuthFormField.swift** - Reusable auth form component

#### Onboarding Module
- **OnboardingContainerView.swift** - Onboarding flow container
- **OnboardingSlideView.swift** - Individual slides
- **TranslationPreferenceView.swift** - Translation setup
- **ReadingGoalsView.swift** - Goals setup
- **PermissionsView.swift** - Permission requests
- **PreferencesSummaryView.swift** - Settings summary
- **TheologicalPerspectiveView.swift** - Theological setup

#### Map/Discover Module
- **DiscoverView.swift** - Discovery features
- **BiblicalAtlasView.swift** - Biblical maps
- **AncientMapView.swift** - Ancient world maps
- **SimpleAncientMapView.swift** - Simplified map view
- **LifeSituationsView.swift** - Life situation content

#### Platform-Specific Views
- **watchOS/WatchBibleView.swift** - Apple Watch Bible view
- **watchOS/ContentView.swift** - Watch app main view
- Platform variants for iOS, macOS, visionOS

#### Shared Components
- **LoadingView.swift** - Loading states
- **VerseAudioView.swift** - Audio controls
- **AudioPlayerView.swift** - Audio player
- **CalendarView.swift** - Calendar component
- **MainTabView.swift** - Tab bar (duplicate?)

## 2. VIEWMODELS (Presentation Layer)

### Active ViewModels
- **BibleViewModel.swift** - Bible view state management
  - Properties: selectedBook, selectedChapter, selectedTranslation, isLoading
  - Methods: loadBibleData(), selectBook(), selectChapter()
  - Currently has placeholder implementation

- **BibleReaderViewModel.swift** - Reader state management
- **SearchViewModel.swift** - Search functionality
- **LibraryViewModel.swift** - Library management
- **CommunityViewModel.swift** - Community features
- **SettingsViewModel.swift** - Settings management
- **DevelopmentAssistantViewModel.swift** - Dev tools
- **AncientMapViewModel.swift** - Map interactions
- **LifeSituationsViewModel.swift** - Life situations
- **AuthViewModel.swift** - Authentication flow
- **AudioPlayerViewModel.swift** - Audio playback
- **WatchBibleViewModel.swift** - Watch app state

### Duplicate ViewModels (in Core/LeavnModules)
- Duplicates exist for Bible, Library, Settings, Search ViewModels
- Indicates modular architecture attempt

## 3. SERVICES (Data/Business Layer)

### Core Services
- **BibleService.swift** - Bible data fetching
  - Protocol: fetchVerse, fetchChapter, fetchTranslations, search
  - Models: BibleVerse, BibleChapter, BibleTranslation

- **AuthenticationService.swift** - User authentication
  - Methods: signIn, signUp, signOut, resetPassword
  - Properties: currentUser, isAuthenticated

- **AudioService.swift** - Audio playback
- **ElevenLabsService.swift** - Text-to-speech
- **VerseNarrationService.swift** - Verse narration
- **VoiceConfigurationService.swift** - Voice settings

### Infrastructure Services
- **BibleCacheManager.swift** - Bible content caching
- **HapticManager.swift** - Haptic feedback
- **ErrorRecoveryService.swift** - Error handling
- **UserDataManager.swift** - User data persistence
- **SafeAIService.swift** - AI integration
- **AIMonitoringService.swift** - AI usage tracking
- **ContentFilterService.swift** - Content filtering
- **BiblicalFactChecker.swift** - Fact verification
- **InMemoryCacheService.swift** - Memory caching
- **PasskeyAuthenticationService.swift** - Passkey auth

### Mock Services
- **MockCommunityService.swift** - Community placeholder
- **MockServices.swift** - Testing mocks

## 4. MODELS/DATA TYPES

### Core Models
- **BibleVerse, BibleChapter, BibleTranslation** - Bible data
- **AuthUser** - Authentication
- **LibraryItem, LibraryFilter** - Library content
- **SearchResult** - Search results
- **Devotion** - Daily devotions
- **LifeSituation** - Life situations

### Settings/Preferences
- **SettingsModels.swift** - App settings
- **PreferenceModels.swift** - User preferences
- **OnboardingModels.swift** - Onboarding data
- **AIProviderModels.swift** - AI configuration

### Data Structures
- **CoreDataModels.swift** - Core Data entities
- **LeavnDataModel.xcdatamodel** - Core Data schema

## 5. DEPENDENCY INJECTION

### DIContainer
- **Location**: Core/LeavnCore/Sources/LeavnServices/DIContainer.swift
- **Status**: Partially implemented, Factory dependency removed
- **Services Registered**:
  - configuration()
  - networkService()
  - analyticsService()
  - bibleService()
- **Issues**: Many services commented out due to missing Factory dependency

## 6. KEY OBSERVATIONS

### Architecture Issues
1. **Duplicate Components**: Multiple versions of ViewModels and Views exist
2. **Modular Structure**: Attempted but incomplete (Package.swift.disabled files)
3. **Service Connections**: Most ViewModels don't connect to actual services
4. **DIContainer**: Partially functional, needs Factory dependency

### Disconnected Components
1. **ViewModels**: Most use placeholder data instead of services
2. **Services**: Exist but not wired to ViewModels
3. **Navigation**: Basic tab navigation works, deeper navigation unclear
4. **State Management**: Mix of @StateObject, @EnvironmentObject patterns

### Missing Connections
1. BibleViewModel doesn't use BibleService
2. No service injection in most ViewModels
3. DIContainer not properly distributed through app
4. Authentication flow not connected
5. Caching services not utilized

### Next Steps for Phase 2
1. Map actual service usage in ViewModels
2. Trace data flow from Services → ViewModels → Views
3. Identify which components are fully connected vs placeholder
4. Document the intended vs actual architecture