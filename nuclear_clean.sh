#!/bin/bash

echo "🔥 NUCLEAR CLEAN - Removing ALL Xcode caches and state"
echo "=================================================="

PROJECT_DIR="/Users/wsig/Cursor Repos/LeavnOfficial"
cd "$PROJECT_DIR"

echo "1. Removing user-specific Xcode data..."
rm -rf Leavn.xcodeproj/xcuserdata/
rm -rf Leavn.xcodeproj/project.xcworkspace/xcuserdata/

echo "2. Removing Package.resolved..."
rm -f Package.resolved
rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

echo "3. Removing all DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "4. Removing Swift Package Manager caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm
rm -rf .build
rm -rf .swiftpm

echo "5. Removing module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex

echo "6. Fixing conflicting Package.swift files..."
# These were already disabled but making sure
rm -f Modules/Map/Package.swift
rm -f Modules/Onboarding/Package.swift
# Keep Discover disabled
echo "// Disabled - managed by parent Modules/Package.swift" > Modules/Discover/Package.swift

echo ""
echo "✅ DONE! Now:"
echo "1. Open Xcode"
echo "2. File → Packages → Reset Package Caches"
echo "3. File → Packages → Resolve Package Versions"
echo "4. Product → Clean Build Folder (Shift+Cmd+K)"
echo "5. Build"
echo ""
echo "The duplicate GUID error should be gone!"