#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Timestamp for backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/Users/wsig/Desktop/Leavn_backup_${TIMESTAMP}"
TEMP_DIR="/Users/wsig/Desktop/Leavn_temp_${TIMESTAMP}"
NEW_PROJ_DIR="/Users/wsig/Desktop/Leavn_new"

# Function to print section headers
section() {
    echo -e "\n${YELLOW}==> $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
for cmd in xcodebuild xcode-select ruby; do
    if ! command_exists "$cmd"; then
        echo -e "${RED}Error: $cmd is required but not installed.${NC}"
        exit 1
    fi
done

# Create backup
section "Creating backup of current project"
mkdir -p "$BACKUP_DIR"
rsync -a --exclude='.git' --exclude='build' --exclude='DerivedData' \
    "/Users/wsig/Desktop/Leavn/" "$BACKUP_DIR/"
echo -e "${GREEN}✓ Backup created at: $BACKUP_DIR${NC}"

# Create temporary directory for new project
section "Setting up new project structure"
mkdir -p "$TEMP_DIR"

# Create directories
mkdir -p "$TEMP_DIR/Leavn/App"
mkdir -p "$TEMP_DIR/Leavn/Configuration"
mkdir -p "$TEMP_DIR/Leavn/Platform/macOS"
mkdir -p "$TEMP_DIR/Leavn/Platform/visionOS"
mkdir -p "$TEMP_DIR/Leavn/Platform/watchOS"
mkdir -p "$TEMP_DIR/Leavn/Views"
mkdir -p "$TEMP_DIR/Modules"
mkdir -p "$TEMP_DIR/Configurations"

# Copy source files
echo "Copying source files..."
rsync -a --exclude='.git' --exclude='build' --exclude='DerivedData' \
    "/Users/wsig/Desktop/Leavn/Leavn/" "$TEMP_DIR/Leavn/"

# Copy modules
echo "Copying modules..."
rsync -a --exclude='.git' --exclude='build' --exclude='DerivedData' \
    "/Users/wsig/Desktop/Leavn/Modules/" "$TEMP_DIR/Modules/"

# Copy configurations
echo "Copying configurations..."
rsync -a --exclude='.git' \
    "/Users/wsig/Desktop/Leavn/Configurations/" "$TEMP_DIR/Configurations/"

# Create new Xcode project
section "Creating new Xcode project"
cd "$TEMP_DIR"

# Create Package.swift for the project
cat > Package.swift << 'EOL'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Leavn",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Leavn",
            targets: ["Leavn"]
        ),
    ],
    dependencies: [
        // Add your dependencies here
    ],
    targets: [
        .target(
            name: "Leavn",
            dependencies: [],
            path: "Leavn",
            resources: [
                .process("Resources"),
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "LeavnTests",
            dependencies: ["Leavn"]
        ),
    ]
)
EOL

# Create README.md
cat > README.md << 'EOL'
# Leavn

## Project Structure

- `Leavn/` - Main app target
- `Modules/` - Feature modules
- `Configurations/` - Build configurations

## Setup

1. Open `Package.swift` in Xcode
2. Build the project

## Requirements

- Xcode 15.0+
- iOS 16.0+ / macOS 13.0+ / watchOS 9.0+ / visionOS 1.0+
EOL

# Create .gitignore
cat > .gitignore << 'EOL'
# Xcode
.DS_Store
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
build/
DerivedData/
*.hmap
*.ipa
*.xcuserstate
*.xcscm*

# Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved
*.xcodeproj

# CocoaPods
Pods/

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output

# Code Injection
*.xcodeproj/xcuserdata/*.xcuserdatad/xcdebugger/*

# AppCode
.idea/

# Local Configuration
*.xcconfig

# SwiftUI Previews
*.swiftpm/
EOL

# Create Xcode project
section "Generating Xcode project"
swift package generate-xcodeproj --output "$TEMP_DIR"

# Move to final location
section "Finalizing migration"
if [ -d "$NEW_PROJ_DIR" ]; then
    rm -rf "$NEW_PROJ_DIR"
fi
mv "$TEMP_DIR" "$NEW_PROJ_DIR"

# Clean up
rm -rf "$TEMP_DIR"

# Final instructions
echo -e "${GREEN}✓ Migration complete!${NC}"
echo -e "\nNext steps:"
echo "1. Open $NEW_PROJ_DIR/Package.swift in Xcode"
echo "2. Build the project"
echo "3. Verify all features are working"
echo -e "\nYour original project is backed up at: $BACKUP_DIR"
echo -e "${YELLOW}Please verify the new project works before deleting the backup.${NC}"

exit 0
