#!/bin/bash

echo "🔧 Fixing Xcode Package Cache Issues..."
echo "=================================="

# Make sure we're in the right directory
cd "$(dirname "$0")"

echo "1. Closing Xcode..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true
sleep 2

echo "2. Removing Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "3. Removing Swift Package Manager Cache..."
rm -rf ~/Library/Caches/org.swift.swiftpm

echo "4. Removing local .swiftpm directories..."
find . -name ".swiftpm" -type d -exec rm -rf {} + 2>/dev/null || true

echo "5. Removing Package.resolved..."
find . -name "Package.resolved" -type f -delete 2>/dev/null || true

echo "6. Removing .build directory..."
rm -rf .build

echo "7. Cleaning Xcode workspace data..."
rm -rf Leavn.xcodeproj/project.xcworkspace/xcuserdata
rm -rf Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm

echo "✅ Cache cleared!"
echo ""
echo "Now please:"
echo "1. Open Xcode"
echo "2. Open your project"
echo "3. Wait for packages to resolve"
echo "4. File → Packages → Reset Package Caches"
echo "5. File → Packages → Resolve Package Versions"
echo "6. Product → Clean Build Folder (Shift+Cmd+K)"
echo "7. Try building again"
echo ""
echo "If the error persists:"
echo "- File → Packages → Update to Latest Package Versions"
echo "- Remove and re-add any problematic packages"

# Open Xcode with the project
echo ""
read -p "Press Enter to open Xcode with your project..."
open Leavn.xcodeproj