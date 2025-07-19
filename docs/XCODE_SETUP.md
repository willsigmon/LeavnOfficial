# Xcode Setup Guide

Complete guide for configuring Xcode for the Leavn Super Official project.

## Table of Contents

- [Xcode Installation](#xcode-installation)
- [Project Configuration](#project-configuration)
- [Build Settings](#build-settings)
- [Signing & Capabilities](#signing--capabilities)
- [Schemes and Targets](#schemes-and-targets)
- [Development Tools](#development-tools)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)

## Xcode Installation

### System Requirements

- **macOS**: 13.0+ (Ventura or later)
- **Xcode**: 15.0+ (15.2 recommended)
- **Storage**: ~15GB for Xcode + simulators
- **RAM**: 8GB minimum, 16GB recommended

### Installation Steps

1. **Mac App Store Method** (Recommended)
   ```
   1. Open Mac App Store
   2. Search "Xcode"
   3. Click "Get" or "Install"
   4. Wait for download (~7GB)
   ```

2. **Developer Portal Method**
   ```
   1. Visit developer.apple.com
   2. Sign in with Apple ID
   3. Downloads > More > Xcode 15.2
   4. Download .xip file
   5. Double-click to extract
   ```

3. **Command Line Tools**
   ```bash
   # Install command line tools
   xcode-select --install
   
   # Verify installation
   xcode-select -p
   # Should output: /Applications/Xcode.app/Contents/Developer
   ```

### First Launch Setup

1. **Accept License Agreement**
   ```bash
   sudo xcodebuild -license accept
   ```

2. **Install Additional Components**
   - iOS Simulators
   - Device Support Files
   - Documentation

3. **Configure Preferences**
   - Xcode > Settings > Accounts
   - Add your Apple ID
   - Download certificates

## Project Configuration

### Opening the Project

```bash
# Navigate to project directory
cd /path/to/LeavnSuperOfficial

# Open with Xcode
open Package.swift

# Or use xed command
xed .
```

### Initial Setup

1. **Wait for Package Resolution**
   - Xcode automatically fetches dependencies
   - Progress shown in Activity View
   - ~2-5 minutes depending on connection

2. **Select Development Team**
   ```
   1. Select project in navigator
   2. Select "Leavn" target
   3. Signing & Capabilities tab
   4. Team: Select your team
   ```

3. **Configure Bundle Identifier**
   ```
   Format: com.yourcompany.leavn
   Example: com.acme.leavn.dev
   ```

## Build Settings

### Recommended Settings

#### Swift Settings

| Setting | Debug | Release |
|---------|-------|---------|
| Swift Language Version | Swift 6 | Swift 6 |
| Optimization Level | None [-Onone] | Optimize for Speed [-O] |
| Compilation Mode | Incremental | Whole Module |
| Enable Testability | Yes | No |

#### Build Options

```
Build Active Architecture Only: 
  Debug: Yes
  Release: No

Enable Bitcode: No (deprecated)

Debug Information Format:
  Debug: DWARF with dSYM
  Release: DWARF with dSYM

Strip Debug Symbols: 
  Debug: No
  Release: Yes
```

#### Deployment

```
iOS Deployment Target: 18.0
Targeted Device Families: iPhone, iPad
Requires Full Screen: No
Status Bar Style: Default
```

### Custom Build Settings

1. **Add Custom Settings**
   ```
   1. Select project
   2. Build Settings tab
   3. Click + > Add User-Defined Setting
   ```

2. **Environment-Specific Settings**
   ```
   API_ENVIRONMENT[config=Debug] = development
   API_ENVIRONMENT[config=Release] = production
   API_ENVIRONMENT[config=TestFlight] = staging
   ```

## Signing & Capabilities

### Automatic Signing (Recommended)

1. **Enable Automatic Signing**
   ```
   ✓ Automatically manage signing
   Team: Your Development Team
   ```

2. **Provisioning Profiles**
   - Xcode manages automatically
   - Downloads as needed
   - Updates on expiration

### Manual Signing

1. **Development Certificate**
   ```
   1. Keychain Access > Certificate Assistant
   2. Request Certificate from Authority
   3. Upload to Developer Portal
   4. Download and install
   ```

2. **Provisioning Profiles**
   ```
   1. Developer Portal > Profiles
   2. Create Development/Distribution profiles
   3. Download and install
   4. Select in Xcode
   ```

### Capabilities

Enable required capabilities:

1. **Background Modes**
   - ✓ Audio, AirPlay, and Picture in Picture
   - ✓ Background fetch
   - ✓ Remote notifications

2. **App Groups** (if needed)
   ```
   group.com.yourcompany.leavn
   ```

3. **Keychain Sharing**
   ```
   com.yourcompany.leavn.keychain
   ```

4. **Push Notifications** (if implemented)

## Schemes and Targets

### Existing Schemes

1. **Leavn** (Main App)
   - Build Configuration: Debug/Release
   - Executable: Leavn.app
   - Tests: Included

2. **LeavnTests** (Unit Tests)
   - Test Target: LeavnAppTests
   - Code Coverage: Enabled

3. **LeavnUITests** (UI Tests)
   - Test Target: LeavnSuperOfficialUITests
   - Accessibility: Enabled

### Creating Custom Schemes

1. **Duplicate Existing Scheme**
   ```
   1. Product > Scheme > Manage Schemes
   2. Select scheme and duplicate
   3. Rename (e.g., "Leavn-Staging")
   ```

2. **Configure Build Configuration**
   ```
   Edit Scheme > Run > Build Configuration
   Options: Debug, Release, Custom
   ```

3. **Environment Variables**
   ```
   Edit Scheme > Run > Arguments > Environment Variables
   API_ENVIRONMENT = staging
   ENABLE_DEBUG_MENU = YES
   ```

### Build Configurations

#### Creating Custom Configuration

1. **Project Settings > Info**
2. **Configurations > +**
3. **Duplicate "Release" configuration**
4. **Name: "TestFlight"**

#### Configuration Settings

```swift
// In code
#if DEBUG
    let environment = "development"
#elseif TESTFLIGHT
    let environment = "staging"
#else
    let environment = "production"
#endif
```

## Development Tools

### SwiftUI Previews

1. **Enable Canvas**
   ```
   Editor > Canvas (Option+Cmd+Return)
   ```

2. **Preview Configuration**
   ```swift
   struct ContentView_Previews: PreviewProvider {
       static var previews: some View {
           ContentView()
               .previewDevice("iPhone 15 Pro")
               .preferredColorScheme(.dark)
               .previewInterfaceOrientation(.portrait)
       }
   }
   ```

3. **Multiple Previews**
   ```swift
   Group {
       ContentView()
           .previewDisplayName("iPhone")
       
       ContentView()
           .previewDevice("iPad Pro (12.9-inch)")
           .previewDisplayName("iPad")
   }
   ```

### Instruments

1. **Profile Build**
   ```
   Product > Profile (Cmd+I)
   ```

2. **Common Instruments**
   - Time Profiler
   - Allocations
   - Leaks
   - Network
   - Core Data

### Debug Tools

1. **View Hierarchy**
   ```
   Debug > View Debugging > Capture View Hierarchy
   ```

2. **Memory Graph**
   ```
   Debug > Memory Graph Debugger
   ```

3. **Environment Overrides**
   ```
   Debug bar > Environment Overrides
   - Text size
   - Dark/Light mode
   - Accessibility
   ```

## Performance Optimization

### Build Time Optimization

1. **Enable Build Timing**
   ```bash
   defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES
   ```

2. **Parallel Builds**
   ```
   File > Project Settings > Build System
   ✓ Use Modern Build System
   ```

3. **Optimize Build Settings**
   ```
   SWIFT_WHOLE_MODULE_OPTIMIZATION = YES (Release only)
   SWIFT_COMPILATION_MODE = incremental (Debug)
   COMPILER_INDEX_STORE_ENABLE = NO (for faster builds)
   ```

### Runtime Performance

1. **Optimization Levels**
   ```
   Debug: -Onone (No optimization)
   Release: -O (Optimize for speed)
   Size: -Osize (Optimize for size)
   ```

2. **Link-Time Optimization**
   ```
   LLVM_LTO = YES (Release only)
   ```

### Reducing App Size

1. **Strip Symbols**
   ```
   STRIP_INSTALLED_PRODUCT = YES
   STRIP_SWIFT_SYMBOLS = YES
   ```

2. **Asset Optimization**
   ```
   ASSETCATALOG_COMPILER_OPTIMIZATION = space
   ```

## Troubleshooting

### Common Issues

#### "No Such Module" Error

```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset packages
File > Packages > Reset Package Caches
```

#### Slow Indexing

```bash
# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Disable indexing temporarily
defaults write com.apple.dt.Xcode IDEIndexDisable 1
```

#### Simulator Issues

```bash
# Reset all simulators
xcrun simctl erase all

# Delete and re-download
xcrun simctl delete unavailable
```

### Build Failures

#### Code Signing

```
1. Revoke certificates in Developer Portal
2. Delete from Keychain
3. Xcode > Settings > Accounts > Download Manual Profiles
4. Clean build folder
5. Try again
```

#### Swift Package Manager

```bash
# Clear SPM cache
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .swiftpm

# Resolve packages
swift package resolve
```

### Performance Issues

#### Slow Builds

1. **Check Activity Monitor**
   - CPU usage
   - Memory pressure
   - Disk activity

2. **Optimize Settings**
   ```
   Build Active Architecture Only = YES (Debug)
   Enable Testability = NO (Release)
   ```

3. **Use Incremental Builds**
   ```
   File > Project Settings
   Shared Project Settings > Build System > Modern
   ```

## Xcode Shortcuts

### Essential Shortcuts

| Action | Shortcut |
|--------|----------|
| Build | Cmd+B |
| Run | Cmd+R |
| Test | Cmd+U |
| Clean | Shift+Cmd+K |
| Stop | Cmd+. |
| Search | Shift+Cmd+F |
| Open Quickly | Shift+Cmd+O |
| Jump to Definition | Ctrl+Cmd+Click |
| Documentation | Option+Click |
| Re-indent | Ctrl+I |

### Navigation

| Action | Shortcut |
|--------|----------|
| Navigator | Cmd+1-9 |
| Inspector | Option+Cmd+1-2 |
| Debug Area | Shift+Cmd+Y |
| Editor Only | Ctrl+Cmd+F |
| Assistant Editor | Ctrl+Option+Cmd+Return |

## Best Practices

1. **Regular Maintenance**
   - Clean DerivedData weekly
   - Update Xcode promptly
   - Keep simulators current

2. **Version Control**
   - Don't commit xcuserdata
   - Do commit xcshareddata
   - Use .gitignore properly

3. **Organization**
   - Use folders in Xcode
   - Match file system structure
   - Group related files

4. **Documentation**
   - Use Quick Help comments
   - Document complex logic
   - Keep README updated

---

For more help, see [Development Setup](DEVELOPMENT_SETUP.md) or [Troubleshooting](TROUBLESHOOTING.md).