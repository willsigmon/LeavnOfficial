# Leavn Hidden/Orphaned Features Audit

## Executive Summary
This audit reveals that many features have been implemented in the codebase but are not accessible through the main navigation. The app shows only 5 tabs (Home, Bible, Search, Library, Settings) but many more features exist.

## Visible Features (In MainTabView)
1. **Home** - Shows daily devotion, verse of the day, reading stats
2. **Bible** - Bible reader with translations, bookmarks, notes
3. **Search** - Bible search functionality  
4. **Library** - Bookmarks, notes, highlights, reading plans
5. **Settings** - User preferences, translations, themes

## Hidden/Orphaned Features

### 1. **Community Features** ⚠️ HIDDEN
- **Location**: `Modules/Community/`
- **Components**:
  - `CommunityView.swift` - Full community hub with Feed, Groups, Challenges
  - `NotificationCenterView.swift` - Notification center
  - `CommunityViewModel.swift` - Community logic
- **Status**: Implemented but commented out with "Community features temporarily disabled for build"
- **Features Include**:
  - Community Feed with posts, likes, comments
  - Groups (Bible Study Groups)
  - Challenges (30 Day Prayer Challenge, etc.)
  - Prayer Wall functionality
  - Member interactions

### 2. **Discover Tab** ⚠️ HIDDEN
- **Location**: `Modules/Discover/Views/DiscoverView.swift`
- **Features**:
  - Featured devotions and content
  - Reading Plans browser
  - Browse by topics (Faith, Love, Hope, Prayer, Wisdom, Peace)
  - Devotion reader
- **Status**: Fully implemented but not in navigation

### 3. **Life Situations Engine** ⚠️ HIDDEN
- **Location**: `Packages/LeavnCore/Sources/LeavnServices/LifeSituationsEngine.swift`
- **Components**:
  - `LifeSituationsEngine` - Service registered in DIContainer
  - `LifeSituationTypes.swift` - Data models
- **Status**: Backend implemented, no UI found
- **Purpose**: Contextual Bible verses for life situations

### 4. **Ancient Maps/Biblical Atlas** ⚠️ HIDDEN
- **Location**: `Modules/Map/`
- **Components**:
  - `AncientMapView.swift` - Map visualization
  - `SimpleAncientMapView.swift` - Simplified map view
  - `AncientMapViewModel.swift` - Map logic
  - `BiblicalLocation.swift`, `BiblicalRoutes.swift`, `ExtendedBiblicalLocations.swift`
- **Status**: Fully implemented but not accessible through navigation

### 5. **AI Features** ✅ PARTIALLY VISIBLE
- **Backend Services** (Active):
  - `AIService` - Main AI service
  - `AIGuardrails` - Safety features
  - `AIMonitoringService` - Usage monitoring
  - `SafeAIService` - Wrapped service with guardrails
- **UI Components**:
  - `AIProvidersView.swift` - In Settings (visible)
  - AI-powered search in SearchView (integrated)
- **Status**: Backend active, limited UI exposure

### 6. **Platform-Specific Features** ⚠️ HIDDEN
- **watchOS**:
  - `WatchBibleView.swift`
  - `WatchBibleViewModel.swift`
- **visionOS**:
  - `VisionBibleStudyView.swift`
  - `VisionBibleStudyViewModel.swift`
  - `VisionImmersiveSpaceView.swift`
- **macOS**:
  - `MacBibleView.swift`
  - `MacBibleViewModel.swift`
- **Status**: Implemented but not integrated into respective platform builds

### 7. **Authentication** ⚠️ HIDDEN
- **Location**: `Modules/Authentication/SignInView.swift`
- **Features**: Sign-in view exists but app doesn't show authentication flow
- **Related Services**:
  - `PasskeyAuthenticationService`
  - `AppleAuthService`

### 8. **Advanced Bible Features** ✅ PARTIALLY VISIBLE
- **Visible**:
  - Basic reading, bookmarks, notes
  - Translation picker
- **Hidden**:
  - `VerseComparisonView` - Compare verses across translations
  - `VoiceoverModeView` - Audio narration mode
  - `DevotionReaderView` - Dedicated devotion reader
  - Parallel Bible view capabilities

### 9. **Onboarding Flow** ⚠️ CONDITIONALLY VISIBLE
- **Location**: `Modules/Onboarding/`
- **Components**:
  - Full onboarding flow with customization
  - Reading goals setup
  - Theological perspective selection
  - Translation preferences
- **Status**: Only shown to new users

### 10. **Development Tools** ✅ VISIBLE (Debug only)
- `DevelopmentAssistantView.swift` - Available in Settings for debug builds

## Services Without UI

These services are initialized but have no user-facing interface:

1. **NotificationService** - Push notifications
2. **FirebaseService** - Analytics and backend (being removed)
3. **IlluminateService** - Content enhancement
4. **BackgroundTaskManager** - Background sync
5. **HapticManager** - Haptic feedback
6. **ThemeManager** - Advanced theming

## Recommendations

1. **Enable Community Tab**: Add Community to MainTabView
2. **Enable Discover Tab**: Add Discover to MainTabView or merge with Home
3. **Surface Life Situations**: Create UI for life situations in Home or Bible tab
4. **Add Maps Access**: Add "Biblical Atlas" option in Bible or Library tab
5. **Platform Features**: Properly configure platform-specific targets
6. **Feature Flags**: Implement feature flags to control feature visibility
7. **Navigation Enhancement**: Add these destinations to NavigationCoordinator

## Quick Implementation Guide

To enable Community tab:
```swift
// In MainTabView.swift, add to enum:
case home = 0, bible, search, library, community, settings

// Add tab item:
NavigationStack(path: bindingForTab(.community)) {
    CommunityView()
}
.tag(MainTab.community)
.tabItem {
    Image(systemName: "person.2.fill")
    Text("Community")
}
```

To enable Discover:
- Either add as 6th tab or integrate into Home view
- Or add as navigation destination from Home

To enable Maps:
- Add navigation from Bible book info sheets
- Or add "Atlas" section in Library