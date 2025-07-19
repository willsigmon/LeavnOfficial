# Development Setup Guide

Complete guide for setting up your development environment for the Leavn Super Official iOS app.

## Table of Contents

- [System Requirements](#system-requirements)
- [Initial Setup](#initial-setup)
- [Project Configuration](#project-configuration)
- [API Keys Setup](#api-keys-setup)
- [Development Workflow](#development-workflow)
- [Debugging Setup](#debugging-setup)
- [Common Development Tasks](#common-development-tasks)
- [Troubleshooting Setup Issues](#troubleshooting-setup-issues)

## System Requirements

### Hardware Requirements

- **Mac**: Apple Silicon (M1/M2/M3) or Intel-based Mac
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 20GB free space for Xcode and development

### Software Requirements

- **macOS**: 13.0+ (Ventura) or later
- **Xcode**: 15.0+ (download from Mac App Store)
- **iOS Simulator**: Included with Xcode
- **Git**: Pre-installed or via Homebrew

### Optional Tools

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Recommended tools
brew install swiftlint       # Code linting
brew install xcbeautify      # Better xcodebuild output
brew install gh              # GitHub CLI

# Ruby for Fastlane
brew install rbenv ruby-build
rbenv install 3.0.0
rbenv global 3.0.0
```

## Initial Setup

### 1. Clone the Repository

```bash
# HTTPS (recommended)
git clone https://github.com/yourusername/LeavnSuperOfficial.git

# SSH
git clone git@github.com:yourusername/LeavnSuperOfficial.git

# Navigate to project
cd LeavnSuperOfficial
```

### 2. Install Dependencies

#### Swift Package Manager

Dependencies are automatically resolved when opening the project in Xcode:

1. Open `Package.swift` in Xcode
2. Wait for "Resolving Package Dependencies"
3. All packages will be downloaded and integrated

#### Fastlane Setup (Optional)

```bash
# Install bundler
gem install bundler

# Install Fastlane and dependencies
bundle install

# Initialize match for code signing (team members only)
fastlane match init
```

### 3. Open in Xcode

```bash
# Open the package file
open Package.swift

# Or open Xcode and select File > Open > Package.swift
```

### 4. Configure Signing

1. Select the project in the navigator
2. Select "Leavn" target
3. Go to "Signing & Capabilities" tab
4. Configure your development team:

```
Team: [Your Team]
Bundle Identifier: com.yourteam.leavn
Signing Certificate: Apple Development
```

## Project Configuration

### Build Configurations

The project includes several build configurations:

1. **Debug**: Development builds with debugging enabled
2. **Release**: Optimized production builds
3. **TestFlight**: Beta distribution builds

### Schemes

- **Leavn**: Main app scheme
- **LeavnTests**: Unit test scheme
- **LeavnUITests**: UI test scheme

### Environment Configuration

```swift
// AppEnvironment.swift
enum AppEnvironment {
    case development
    case staging
    case production
    
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}
```

## API Keys Setup

### 1. ESV API Key (Required)

1. Visit [api.esv.org](https://api.esv.org)
2. Create a free account
3. Generate an API key
4. Note the key for app configuration

### 2. ElevenLabs API Key (Optional)

1. Visit [elevenlabs.io](https://elevenlabs.io)
2. Create an account (free tier available)
3. Go to Profile > API Keys
4. Generate and copy your key

### 3. Configure Keys in App

During first launch or in Settings:

```swift
// The app will prompt for keys on first launch
// Or navigate to Settings > API Configuration

// Keys are stored securely in Keychain
// Never commit API keys to source control
```

### 4. Development Keys (Team Only)

For team development, use shared test keys:

```bash
# .env.development (DO NOT COMMIT)
ESV_API_KEY=your-test-key-here
ELEVENLABS_API_KEY=your-test-key-here
```

## Development Workflow

### 1. Branch Strategy

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Create bugfix branch
git checkout -b bugfix/issue-description

# Create hotfix branch
git checkout -b hotfix/critical-fix
```

### 2. Making Changes

1. **Write tests first** (TDD approach)
2. **Implement feature**
3. **Run tests locally**
4. **Update documentation**

### 3. Code Style

The project uses SwiftLint for code consistency:

```bash
# Run SwiftLint
swiftlint

# Auto-fix issues
swiftlint --fix

# Xcode integration (automatic)
# Build phases include SwiftLint
```

### 4. Committing Code

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: Add prayer request notifications"

# Follow conventional commits
# feat: New feature
# fix: Bug fix
# docs: Documentation
# style: Code style
# refactor: Code refactoring
# test: Tests
# chore: Maintenance
```

### 5. Testing

```bash
# Run all tests
swift test

# Run specific test
swift test --filter BibleReducerTests

# Run with coverage
swift test --enable-code-coverage

# Using xcodebuild
xcodebuild test \
  -scheme Leavn \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Debugging Setup

### 1. Console Logging

```swift
// Use structured logging
import OSLog

extension Logger {
    static let subsystem = "com.leavn.bible"
    
    static let general = Logger(subsystem: subsystem, category: "general")
    static let api = Logger(subsystem: subsystem, category: "api")
    static let ui = Logger(subsystem: subsystem, category: "ui")
}

// Usage
Logger.api.debug("Loading passage: \(reference)")
Logger.api.error("API error: \(error.localizedDescription)")
```

### 2. Breakpoints

```swift
// Conditional breakpoints
// Right-click breakpoint > Edit Breakpoint
// Condition: userId == "12345"

// Symbolic breakpoints
// Debug > Breakpoints > + > Symbolic Breakpoint
// Symbol: UIViewAlertForUnsatisfiableConstraints
```

### 3. View Debugging

1. Run app in simulator
2. Debug menu > View Debugging > Capture View Hierarchy
3. Inspect view properties and constraints

### 4. Network Debugging

```swift
// Enable network logging in scheme
// Edit Scheme > Run > Arguments
// Environment Variables:
// CFNETWORK_DIAGNOSTICS = 3

// Or use Charles Proxy / Proxyman
```

### 5. Memory Debugging

1. Product > Profile (Cmd+I)
2. Choose "Leaks" or "Allocations"
3. Monitor memory usage
4. Check for retain cycles

## Common Development Tasks

### Adding a New Feature

1. **Create feature branch**
   ```bash
   git checkout -b feature/new-feature
   ```

2. **Add feature module**
   ```swift
   // Features/NewFeature/NewFeatureReducer.swift
   @Reducer
   struct NewFeatureReducer {
       @ObservableState
       struct State: Equatable {
           // Feature state
       }
       
       enum Action {
           // Feature actions
       }
       
       var body: some ReducerOf<Self> {
           Reduce { state, action in
               // Handle actions
           }
       }
   }
   ```

3. **Create view**
   ```swift
   // Features/NewFeature/NewFeatureView.swift
   struct NewFeatureView: View {
       let store: StoreOf<NewFeatureReducer>
       
       var body: some View {
           // View implementation
       }
   }
   ```

4. **Add tests**
   ```swift
   // Tests/Features/NewFeature/NewFeatureReducerTests.swift
   @MainActor
   class NewFeatureReducerTests: XCTestCase {
       func testFeature() async {
           // Test implementation
       }
   }
   ```

### Updating Dependencies

```bash
# Update all packages
swift package update

# Update specific package
swift package update swift-composable-architecture

# Resolve package versions
swift package resolve
```

### Running on Device

1. Connect iOS device via USB
2. Trust computer on device
3. Select device in Xcode toolbar
4. Build and run (Cmd+R)

### Creating Debug Builds

```bash
# Build for testing
xcodebuild -scheme Leavn -configuration Debug

# Create IPA for testing
xcodebuild -exportArchive \
  -archivePath ./build/Leavn.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions-Dev.plist
```

## Troubleshooting Setup Issues

### Xcode Won't Open Project

```bash
# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset package caches
rm -rf .build
rm -rf .swiftpm
```

### Simulator Issues

```bash
# Reset simulator
xcrun simctl erase all

# Download specific runtime
xcodebuild -downloadPlatform iOS
```

### Code Signing Issues

1. Ensure Apple ID is added to Xcode
2. Xcode > Settings > Accounts
3. Add Apple ID
4. Download manual profiles if needed

### Swift Package Resolution Failed

```swift
// Check Package.swift syntax
swift package describe

// Validate package
swift package validate

// Clean and retry
swift package clean
swift package resolve
```

### Build Performance

```bash
# Enable build timing
defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

# Parallel builds
defaults write com.apple.dt.Xcode BuildSystemScheduleInherentlyParallelCommandsExclusively -bool NO

# Increase thread count
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks $(sysctl -n hw.ncpu)
```

## IDE Configuration

### Xcode Settings

1. **Text Editing**
   - Preferences > Text Editing
   - Enable "Automatically trim trailing whitespace"
   - Enable "Including whitespace-only lines"

2. **Key Bindings**
   - Preferences > Key Bindings
   - Customize as needed

3. **Behaviors**
   - Preferences > Behaviors
   - Configure build success/failure actions

### Recommended Extensions

1. **SwiftLint** - Integrated via build phase
2. **SF Symbols** - Browse system icons
3. **Reveal** - UI debugging (optional)

### Git Configuration

```bash
# Set up git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Configure git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

# Set up GPG signing (optional)
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

---

For additional help, see [Troubleshooting Guide](TROUBLESHOOTING.md) or contact the development team.