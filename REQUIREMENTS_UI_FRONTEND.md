# Leavn App - UI/Frontend Requirements (Agent 2)

## Overview
This document outlines the UI/Frontend requirements for the Leavn Bible app, focusing on view and asset integrations as specified by Agent 2.

## Current UI Architecture

### Core UI Structure
- **Main Entry**: `MainTabView.swift` - Custom tab bar implementation with 5 main sections
  - Bible (book icon)
  - Search (magnifyingglass icon)
  - Library (books.vertical icon)
  - Community (person.3 icon)
  - Settings (gearshape icon)

### Design System
- **Theme**: `LeavnTheme.swift` - Vibrant, whimsical design system
  - Primary gradient: Light purple to deeper purple
  - Accent colors: Purple-based palette
  - Special colors: Jesus words (warm red), semantic colors (success/warning/error/info)
  - Glass morphism effects with ultra-thin materials
  - Rich motion system with spring animations

### Platform-Specific Views
Currently implemented platform-specific views:
- **macOS**: `MacBibleView.swift`, `MacBibleViewModel.swift`
- **visionOS**: `VisionBibleStudyView.swift`, `VisionBibleStudyViewModel.swift`, `VisionImmersiveSpaceView.swift`
- **watchOS**: `WatchBibleView.swift`, `WatchBibleViewModel.swift`

## Requirements for UI Manifest Integration

### Sub-agent 2.1: UI Manifest Requirements

#### Target Configuration for Project.swift
```swift
.target(
    name: "LeavnUI",
    dependencies: [
        "DesignSystem",
        "LeavnCore",
        "LeavnBible",
        "LeavnSearch",
        "LeavnLibrary",
        "LeavnCommunity",
        "LeavnSettings"
    ],
    sources: ["Sources/UI/**"],
    resources: [
        .process("Resources/Assets.xcassets"),
        .process("Resources/Fonts"),
        .process("Resources/Localizations")
    ]
)
```

#### Asset Integration Requirements
1. **Assets.xcassets Migration**
   - Move from `Leavn/Assets.xcassets` to structured resources
   - Ensure AccentColor and AppIcon sets are preserved
   - Add platform-specific icon variants

2. **Resource Processing**
   - Process all image assets for multiple resolutions
   - Include PDF vectors for scalable graphics
   - Optimize PNG assets for size

### Sub-agent 2.2: Platform-Specific View Requirements

#### Platform Conditional Dependencies
```swift
.target(
    name: "LeavnUI",
    destinations: [.iOS, .macOS, .watchOS, .visionOS, .tvOS],
    dependencies: [
        .target(name: "DesignSystem"),
        .product(name: "LeavnCore", package: "LeavnCore"),
        .product(name: "LeavnModules", package: "LeavnModules")
    ],
    sources: ["Sources/UI/**"],
    swiftSettings: [
        .define("PLATFORM_IOS", .when(platforms: [.iOS])),
        .define("PLATFORM_MACOS", .when(platforms: [.macOS])),
        .define("PLATFORM_WATCHOS", .when(platforms: [.watchOS])),
        .define("PLATFORM_VISIONOS", .when(platforms: [.visionOS]))
    ]
)
```

#### Migration Structure
```
Sources/UI/
├── Shared/
│   ├── MainTabView.swift
│   ├── ContentView.swift
│   └── Components/
├── iOS/
│   └── (iOS-specific views)
├── macOS/
│   ├── MacBibleView.swift
│   └── MacBibleViewModel.swift
├── watchOS/
│   ├── WatchBibleView.swift
│   └── WatchBibleViewModel.swift
└── visionOS/
    ├── VisionBibleStudyView.swift
    ├── VisionBibleStudyViewModel.swift
    └── VisionImmersiveSpaceView.swift
```

### Sub-agent 2.3: Manifest Generation and Editing

#### Required Manifests
1. **Package.swift Updates**
   - Add UI target with proper dependencies
   - Configure platform-specific compilation conditions
   - Set up resource processing rules

2. **Info.plist Requirements**
   - Scene configuration for multi-window support
   - Privacy descriptions for camera/photo library access
   - URL schemes for deep linking

3. **Entitlements**
   - Push notifications
   - CloudKit
   - App Groups (for widgets)

#### MainTabView.swift Updates Required
1. **Import Cleanup**
   - Remove duplicate/commented imports (lines 9-11)
   - Ensure all module imports are valid

2. **Platform Adaptations**
   ```swift
   #if os(iOS)
   // iOS-specific tab bar implementation
   #elseif os(macOS)
   // macOS sidebar implementation
   #elseif os(watchOS)
   // watchOS page-based navigation
   #elseif os(visionOS)
   // visionOS ornament-based navigation
   #endif
   ```

3. **Accessibility**
   - Add accessibility labels to all tab items
   - Support VoiceOver navigation
   - Include keyboard shortcuts for macOS

## Component Library Requirements

### Shared Components (from DesignSystem)
- **ActionButton**: Primary action buttons with vibrant styling
- **ErrorView**: Consistent error state display
- **LoadingView**: Animated loading states
- **LeavnCard**: Glass morphism card container
- **LeavnSearchBar**: Unified search input
- **LeavnTabBar**: Custom tab bar component
- **VibrantComponents**: Collection of animated UI elements

### Platform-Specific Components Needed
1. **iOS/iPadOS**
   - Adaptive split view for iPad
   - Context menus
   - Swipe actions

2. **macOS**
   - Window toolbar
   - Menu bar items
   - Keyboard shortcuts

3. **watchOS**
   - Complications
   - Digital Crown navigation
   - Glanceable views

4. **visionOS**
   - Ornaments
   - Immersive spaces
   - 3D content views

## Asset Requirements

### Required Assets
1. **App Icons**
   - iOS: 1024x1024 + all required sizes
   - macOS: 16x16 to 1024x1024
   - watchOS: Circular variants
   - visionOS: 3D layer variants

2. **Launch Assets**
   - Storyboard-based launch screens
   - Platform-specific splash screens

3. **Custom Fonts**
   - Georgia for Bible reading
   - SF Rounded for UI elements
   - Fallback system fonts

4. **Color Assets**
   - Dark/Light mode variants
   - High contrast accessibility variants
   - Platform-specific tints

## Tuist Integration Commands

### Required Commands
```bash
# Generate Xcode project
tuist generate

# Edit manifests in Xcode
tuist edit

# Fetch dependencies
tuist fetch

# Clean and regenerate
tuist clean
tuist generate
```

### Build Configuration
- Use xcconfig files for build settings
- Configure schemes for each platform
- Set up test targets

## Testing Requirements

### UI Testing Targets
```swift
.target(
    name: "LeavnUITests",
    dependencies: ["LeavnUI"],
    sources: ["Tests/UITests/**"]
)
```

### Snapshot Testing
- Configure for all platforms
- Test in light/dark modes
- Verify accessibility states

## Migration Checklist

- [ ] Create LeavnUI target in Project.swift
- [ ] Move views to appropriate platform folders
- [ ] Update imports in all view files
- [ ] Migrate Assets.xcassets to resources
- [ ] Configure platform-specific build settings
- [ ] Update MainTabView for platform adaptations
- [ ] Add accessibility identifiers
- [ ] Configure Info.plist for each platform
- [ ] Set up entitlements
- [ ] Run `tuist generate` and verify build
- [ ] Test on all target platforms

## Notes

- The app uses a vibrant, whimsical design language with purple gradients
- Glass morphism is a key visual element
- Custom tab bar provides unified navigation across platforms
- Platform-specific views should maintain design consistency while respecting platform conventions