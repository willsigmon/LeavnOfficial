#!/bin/bash

echo "🔥 NUCLEAR XCODE RESET - This will completely reset Xcode's state"
echo "================================================="
echo ""

# Get project directory
PROJECT_DIR="/Users/wsig/Cursor Repos/LeavnOfficial"

echo "⚠️  WARNING: This will:"
echo "- Close Xcode"
echo "- Delete ALL Xcode caches and derived data"
echo "- Remove all user-specific Xcode settings for this project"
echo "- Reset all package caches"
echo ""
echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
sleep 5

echo ""
echo "1️⃣ Force closing Xcode..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true
sleep 2

echo "2️⃣ Removing ALL Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true

echo "3️⃣ Removing Xcode caches..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode* 2>/dev/null || true

echo "4️⃣ Removing Swift Package Manager state..."
rm -rf ~/Library/Caches/org.swift.swiftpm 2>/dev/null || true
rm -rf ~/Library/org.swift.swiftpm 2>/dev/null || true

echo "5️⃣ Removing project-specific Xcode data..."
cd "$PROJECT_DIR"
rm -rf Leavn.xcodeproj/project.xcworkspace/xcuserdata 2>/dev/null || true
rm -rf Leavn.xcodeproj/xcuserdata 2>/dev/null || true

echo "6️⃣ Removing any xcshareddata package data..."
rm -rf Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm 2>/dev/null || true
rm -rf Leavn.xcodeproj/xcshareddata/xcschemes/Package* 2>/dev/null || true

echo "7️⃣ Cleaning module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex 2>/dev/null || true

echo "8️⃣ Resetting Xcode preferences..."
defaults delete com.apple.dt.Xcode 2>/dev/null || true

echo "9️⃣ Final cleanup..."
# Remove any remaining SPM artifacts in the project
find "$PROJECT_DIR" -name ".swiftpm" -type d -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_DIR" -name ".build" -type d -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_DIR" -name "Package.resolved" -type f -delete 2>/dev/null || true

echo ""
echo "✅ Nuclear reset complete!"
echo ""
echo "📝 Next steps:"
echo "1. Open Xcode fresh"
echo "2. Open your project: Leavn.xcodeproj"
echo "3. Wait for indexing to complete"
echo "4. Try to build (Cmd+B)"
echo ""
echo "If it still fails:"
echo "- File > Packages > Reset Package Caches"
echo "- Product > Clean Build Folder"
echo "- Restart Xcode and try again"