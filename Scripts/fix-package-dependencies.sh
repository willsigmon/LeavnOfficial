#!/bin/bash

echo "🔧 Fixing LeavnModules Package Dependencies..."

# Navigate to project root
cd "$(dirname "$0")/.." || exit 1

# Clean Xcode derived data
echo "📦 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Clean SPM cache for local packages
echo "🧹 Cleaning SPM cache..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .build
rm -rf Core/LeavnCore/.build
rm -rf Core/LeavnModules/.build

# Reset package resolved files
echo "🔄 Resetting package resolved files..."
rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
rm -f Core/LeavnCore/Package.resolved
rm -f Core/LeavnModules/Package.resolved

# Clean Xcode project
echo "🧽 Cleaning Xcode project..."
if command -v xcodebuild &> /dev/null; then
    xcodebuild -project Leavn.xcodeproj -scheme Leavn-iOS clean 2>/dev/null || true
fi

# Force package resolution for LeavnCore first
echo "📥 Resolving LeavnCore packages..."
cd Core/LeavnCore
if command -v swift &> /dev/null; then
    swift package resolve || echo "Swift CLI not available, will use Xcode"
fi
cd ../..

# Force package resolution for LeavnModules
echo "📥 Resolving LeavnModules packages..."
cd Core/LeavnModules
if command -v swift &> /dev/null; then
    swift package resolve || echo "Swift CLI not available, will use Xcode"
fi
cd ../..

# Resolve packages in Xcode project
echo "🔄 Resolving packages in Xcode..."
if command -v xcodebuild &> /dev/null; then
    xcodebuild -resolvePackageDependencies -project Leavn.xcodeproj -scheme Leavn-iOS || true
fi

echo "✅ Package dependency fix complete!"
echo ""
echo "Next steps:"
echo "1. Open Leavn.xcodeproj in Xcode"
echo "2. Wait for package resolution to complete"
echo "3. Try building the project again"
echo ""
echo "If issues persist:"
echo "- File > Packages > Reset Package Caches"
echo "- File > Packages > Resolve Package Versions"