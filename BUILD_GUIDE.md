# 🏗️ Leavn Project Build Guide

## Project Overview
The Leavn project is an iOS application built with SwiftUI. Based on the project structure and build logs, the project is configured for iOS 26.0 SDK and has been successfully built for iPhone 16 Pro Max.

## Current Project Status
- ✅ Project file exists: `Leavn.xcodeproj`
- ✅ Build configuration files present
- ✅ Previous successful builds documented
- ✅ All dependencies properly configured
- ✅ Makefile available for easy building

## Quick Start

### Option 1: Using Xcode GUI (Recommended)
1. Open **Xcode**
2. Select **File > Open**
3. Navigate to `/Users/wsig/Cursor Repos/LeavnOfficial/`
4. Select `Leavn.xcodeproj` and click **Open**
5. In the scheme selector (top toolbar), ensure **"Leavn"** is selected
6. Select your target device:
   - For simulator: **iPhone 16 Pro Max**
   - For physical device: Connect your iPhone and select it
7. Press **⌘+B** to build or **⌘+R** to build and run

### Option 2: Using Terminal with xcodebuild
```bash
cd "/Users/wsig/Cursor Repos/LeavnOfficial"

# Clean previous builds
xcodebuild clean -project Leavn.xcodeproj -scheme Leavn

# Build for simulator
xcodebuild build \
    -project Leavn.xcodeproj \
    -scheme "Leavn" \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'
```

### Option 3: Using Makefile (Easiest)
```bash
cd "/Users/wsig/Cursor Repos/LeavnOfficial"

# Clean and build
make clean build

# Build for physical device
make device

# Quick setup for plane testing
make plane-ready
```

### Option 4: Using Existing Build Scripts
```bash
cd "/Users/wsig/Cursor Repos/LeavnOfficial"

# Run the test build script
./test_build.sh

# Or run the clean build script
./clean_build.sh
```

## Build Configuration

### SDK Requirements
- **Xcode**: 17.0 or later
- **iOS SDK**: iOS 26.0 (configured in project)
- **Swift**: 5.9 or later
- **Target devices**: iPhone, iPad

### Project Structure
```
LeavnOfficial/
├── Leavn.xcodeproj/          # Xcode project file
├── Leavn/                    # Main app source
│   ├── App/                  # App entry point
│   ├── Assets.xcassets/      # App icons and images
│   ├── Views/                # Main UI views
│   └── Configuration/        # App configuration
├── Modules/                  # Feature modules
│   ├── Bible/               # Bible reading features
│   ├── Search/              # Search functionality
│   ├── Library/             # User library
│   ├── Settings/            # App settings
│   └── Community/           # Community features
├── Packages/                 # Swift packages
│   └── LeavnCore/           # Core functionality
└── Makefile                 # Build automation
```

## Features Included
Based on the build logs and project structure:
- ✅ Bible reading with multiple translations
- ✅ Search functionality
- ✅ Personal library (bookmarks, notes, reading plans)
- ✅ Settings and preferences
- ✅ Community features
- ✅ Offline support

## Troubleshooting

### If build fails:
1. **Clean build artifacts**:
   ```bash
   make clean
   # or
   rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
   ```

2. **Reset package cache**:
   ```bash
   rm -rf ~/Library/Caches/org.swift.swiftpm
   ```

3. **Update dependencies**:
   ```bash
   make update
   ```

4. **Check Xcode version**:
   - Ensure you have Xcode 17.0 or later
   - Update if necessary from Mac App Store

### Common Issues:
- **"No such module" errors**: Run `make clean` then rebuild
- **Code signing errors**: Select your development team in project settings
- **Simulator not found**: Download iOS 18.0+ simulator in Xcode preferences

## Building for Physical Device

1. Connect your iPhone/iPad to your Mac
2. In Xcode, select your device from the device selector
3. You may need to:
   - Add your Apple ID in Xcode preferences
   - Trust the developer certificate on your device (Settings > General > VPN & Device Management)
4. Press ⌘+R to build and run

## For Plane/Offline Testing
The app is designed to work offline:
```bash
make plane-ready
```

This will:
- Clean previous builds
- Build for physical device
- Prepare the app for offline use

## Build Logs
Previous successful builds are documented in:
- `Build_iOS26_Success.log` - Successful iOS 26 build log
- `FINAL_BUILD_TEST_SUMMARY.md` - Detailed test results
- `build_test_output.log` - Latest build output

## Next Steps
1. Open the project in Xcode
2. Select your target device
3. Build and run the app
4. The app should launch showing the main tab interface with Home, Bible, Search, Library, and Settings tabs

## Support
If you encounter any issues not covered here, check the existing documentation files in the project root or refer to the build scripts for additional options.