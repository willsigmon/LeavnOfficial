#!/bin/bash

# Fix for duplicate GUID error in Xcode project
# Error: The workspace contains multiple references with the same GUID 'PACKAGE:1OJ5W07399N9252HQLWU0QSAFZ3TLA8XH::MAINGROUP'

echo "🔧 Fixing duplicate GUID issue in Xcode project..."

PROJECT_DIR="/Users/wsig/Cursor Repos/LeavnOfficial"
cd "$PROJECT_DIR"

echo "1️⃣ Closing Xcode (if running)..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true

echo "2️⃣ Removing Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

echo "3️⃣ Removing Swift Package Manager caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm

echo "4️⃣ Removing workspace data..."
rm -rf Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
rm -rf Leavn.xcodeproj/project.xcworkspace/xcuserdata/*/UserInterfaceState.xcuserstate

echo "5️⃣ Removing Package.resolved..."
rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

echo "6️⃣ Cleaning module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex

echo "7️⃣ Resetting package caches..."
defaults delete com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile 2>/dev/null || true
defaults delete com.apple.dt.Xcode IDEDisableAutomaticPackageResolution 2>/dev/null || true

echo "✅ Cleanup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Open Xcode"
echo "2. Open the Leavn.xcodeproj file"
echo "3. Go to File > Packages > Reset Package Caches"
echo "4. Go to File > Packages > Resolve Package Versions"
echo "5. Clean build folder: Cmd+Shift+K"
echo "6. Build the project: Cmd+B"
echo ""
echo "If the issue persists, you may need to:"
echo "- Remove all package dependencies in Xcode"
echo "- Re-add them manually"
echo "- Clean and rebuild"