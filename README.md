# Leavn - Modern Leave Management System

A comprehensive, multi-platform leave management application built with SwiftUI for iOS, iPadOS, macOS, watchOS, and visionOS.

## Project Overview

Leavn is a modern leave management system designed to streamline the process of requesting, approving, and tracking employee time off. Built with SwiftUI and leveraging the latest Apple technologies, it provides a seamless experience across all Apple platforms.

### Key Features
- 📱 Universal app supporting iPhone, iPad, Mac, Apple Watch, and Vision Pro
- ☁️ CloudKit sync for seamless data synchronization across devices
- 🔔 Push notifications for leave status updates
- 📊 Comprehensive leave analytics and reporting
- 🎨 Beautiful, native UI following Apple's Human Interface Guidelines
- 🌙 Full dark mode support
- ♿ Complete accessibility support with VoiceOver

## Setup Instructions

### Prerequisites
- Xcode 26 beta or later (iOS 26 SDK)
- macOS 26 or later
- Swift 6.2 with Swift 6 language mode
- Apple Developer account (for device testing and CloudKit)
- Swift Package Manager (SPM)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/LeavnOfficial.git
   cd LeavnOfficial
   ```

2. **Open in Xcode**
   ```bash
   open Leavn.xcodeproj
   ```

3. **Configure Signing & Capabilities**
   - Select the project in Xcode
   - Go to "Signing & Capabilities" tab
   - Select your development team
   - Ensure automatic signing is enabled

4. **Configure CloudKit**
   - Enable CloudKit capability
   - Create a new CloudKit container or select existing
   - Configure record types in CloudKit Dashboard

5. **Install Dependencies** (if using CocoaPods)
   ```bash
   pod install
   open Leavn.xcworkspace
   ```

6. **Build and Run**
   - Select your target device/simulator
   - Press ⌘R to build and run

### Environment Configuration

Create a `Config.xcconfig` file in the project root:
```
// Development
API_BASE_URL = https://api-dev.leavn.com
CLOUDKIT_CONTAINER = iCloud.com.yourcompany.leavn.dev

// Production
// API_BASE_URL = https://api.leavn.com
// CLOUDKIT_CONTAINER = iCloud.com.yourcompany.leavn
```

## Architecture Overview

### Project Structure
```
Leavn/
├── Sources/
│   ├── Models/
│   │   ├── Leave.swift
│   │   ├── Employee.swift
│   │   └── Department.swift
│   ├── Services/
│   │   ├── CloudKitService.swift
│   │   ├── NotificationService.swift
│   │   └── AuthenticationService.swift
│   ├── Utilities/
│   │   ├── DateFormatter+Extensions.swift
│   │   └── Color+Theme.swift
│   └── Views/
│       ├── Shared/
│       │   ├── Components/
│       │   └── Modifiers/
│       ├── iOS/
│       │   ├── Dashboard/
│       │   ├── LeaveRequest/
│       │   └── Settings/
│       ├── macOS/
│       │   ├── Sidebar/
│       │   └── DetailView/
│       ├── watchOS/
│       │   ├── ComplicationController.swift
│       │   └── NotificationView.swift
│       └── visionOS/
│           ├── ImmersiveView.swift
│           └── VolumeView.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Info.plist
└── Tests/
    ├── Unit/
    ├── UI/
    └── Integration/
```

### Architecture Pattern
- **MVVM** (Model-View-ViewModel) with SwiftUI
- **Repository Pattern** for data access
- **Dependency Injection** for testability
- **Combine** for reactive programming
- **Swift Concurrency** (async/await) for asynchronous operations

### Data Flow
1. **Views** observe ViewModels via `@StateObject` or `@ObservedObject`
2. **ViewModels** interact with Services/Repositories
3. **Services** handle business logic and external communications
4. **CloudKit** provides data persistence and sync
5. **Combine** publishers notify of data changes

## Platform Support Details

### iOS/iPadOS (15.0+)
- Adaptive layouts with size classes
- Split view support on iPad
- Widgets for quick leave balance view
- Siri Shortcuts for common actions
- Apple Watch companion app

### macOS (11.0+)
- Native Mac app with AppKit integration where needed
- Menu bar app for quick access
- Keyboard shortcuts for power users
- Touch Bar support (where available)

### watchOS (8.0+)
- Complications showing leave balance
- Quick leave request from watch
- Notification handling
- Health integration for sick leave tracking

### visionOS (1.0+)
- Immersive leave calendar view
- Spatial team availability visualization
- Hand gesture controls
- Shared space collaboration features

## Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint for code consistency
- Meaningful variable and function names
- Comprehensive documentation for public APIs

### Git Workflow
- Feature branches: `feature/description`
- Bug fixes: `bugfix/description`
- Hotfixes: `hotfix/description`
- Commit messages: Present tense, descriptive

### Testing Requirements
- Minimum 80% code coverage
- Unit tests for all ViewModels and Services
- UI tests for critical user flows
- Performance tests for data operations

### SwiftUI Best Practices
- Prefer `@StateObject` for owned objects
- Use `@EnvironmentObject` sparingly
- Extract reusable views into components
- Leverage ViewModifiers for common styling

### Performance Considerations
- Lazy load data where appropriate
- Use `List` with identifiable items
- Implement proper image caching
- Profile with Instruments regularly

## Key Technologies

- **SwiftUI** - Declarative UI framework
- **CloudKit** - Data persistence and sync
- **Combine** - Reactive programming
- **Core Data** - Local data caching
- **Push Notifications** - Real-time updates
- **WidgetKit** - Home screen widgets
- **WatchKit** - Apple Watch support
- **RealityKit** - visionOS 3D content

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

### Pull Request Guidelines
- Clear description of changes
- Screenshots for UI changes
- Test coverage for new features
- No merge conflicts
- Passes all CI checks

## Troubleshooting

### Common Issues

**Build Errors**
- Clean build folder: ⌥⌘K
- Delete derived data
- Reset package caches: File → Packages → Reset Package Caches

**CloudKit Sync Issues**
- Verify CloudKit entitlements
- Check network connectivity
- Review CloudKit Dashboard for errors

**Preview Crashes**
- Simplify preview code
- Check for missing mock data
- Use `.constant()` bindings in previews

## License

This project is proprietary software. All rights reserved.

## Contact

- Project Lead: [your-email@example.com]
- Technical Support: [support@leavn.com]
- Documentation: [docs.leavn.com]

---

Built with ❤️ using SwiftUI