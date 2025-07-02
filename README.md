# Leavn - Bible Study App

A modern, multi-platform Bible study application built with SwiftUI and Swift 6.

## 📱 Features

- **Universal App**: Runs on iOS, iPadOS, macOS, watchOS, and visionOS
- **Bible Reading**: Access multiple translations with offline support
- **Study Tools**: Notes, highlights, bookmarks, and cross-references
- **Prayer Journal**: Track prayers and devotionals
- **AI Insights**: Get contextual insights and explanations
- **CloudKit Sync**: Seamless sync across all devices
- **Sign in with Apple**: Secure authentication

## 🏗️ Project Structure

```
Leavn/
├── Leavn/                    # Main app target
│   ├── App/                   # App lifecycle
│   ├── Views/                 # App-specific views
│   └── Platform/              # Platform-specific code
│
├── Packages/                  # Local Swift packages
│   └── LeavnCore/
│       └── Sources/
│           ├── LeavnCore/     # Core utilities & models
│           ├── LeavnServices/ # Service layer
│           └── DesignSystem/  # Shared UI components
│
├── Modules/                   # Feature modules
│   ├── Bible/
│   ├── Prayer/
│   ├── Study/
│   └── Settings/
│
├── Configurations/            # Build configurations
├── Tests/                     # Test suites
└── Leavn.xcworkspace        # Use this to open the project
```

## 🚀 Getting Started

### Prerequisites

- Xcode 16.0+
- macOS 15.0+
- Apple Developer Account (for device testing)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Leavn.git
   cd Leavn
   ```

2. Install development tools:
   ```bash
   make setup
   ```

3. Open in Xcode:
   ```bash
   make open
   ```

4. Build and run:
   - Select your target device
   - Press ⌘R to build and run

## 🛠️ Development

### Common Commands

```bash
make help      # Show all available commands
make build     # Build the project
make test      # Run tests
make lint      # Run SwiftLint
make format    # Format code with swift-format
make clean     # Clean build artifacts
```

### Code Quality

- **SwiftLint**: Enforces Swift style and conventions
- **Swift Format**: Automatic code formatting
- **Strict Concurrency**: Full Swift 6 concurrency checking

### Build Configurations

- **Debug**: Fast builds with debugging enabled
- **Release**: Optimized builds for distribution

### Adding New Features

1. Create a new module in `Modules/`
2. Add the module to `project.yml`
3. Run `make generate` to update Xcode project
4. Import `LeavnCore` and `DesignSystem` as needed

## 📦 Architecture

### Core Packages

- **LeavnCore**: Shared models, utilities, and protocols
- **LeavnServices**: Service layer with API clients and data management
- **DesignSystem**: Reusable UI components and theming

### Key Technologies

- **SwiftUI**: Modern declarative UI
- **Swift 6**: Latest language features and concurrency
- **CloudKit**: Cross-device synchronization
- **Sign in with Apple**: Secure authentication
- **Combine**: Reactive programming

## 🧪 Testing

Run all tests:
```bash
make test
```

Test coverage is gathered automatically and can be viewed in Xcode.

## 📱 Supported Platforms

- iOS 18.0+
- iPadOS 18.0+
- macOS 15.0+
- watchOS 11.0+
- visionOS 2.0+

## 🔧 Troubleshooting

### Module Import Errors

1. Clean build folder: ⌘⇧K
2. Reset package cache: File → Packages → Reset Package Caches
3. Rebuild: ⌘B

### Xcode Not Recognizing Packages

1. Close Xcode
2. Run `make clean`
3. Run `make open`

## 📝 License

Copyright © 2024. All rights reserved.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Run tests and linting
4. Submit a pull request

---

Built with ❤️ using SwiftUI and Swift 6
