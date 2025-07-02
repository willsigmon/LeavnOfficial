#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🧹 Cleaning up conflicting implementations..."

# Remove all but the essential files
rm -f Modules/Library/LibraryBootstrap.swift
rm -f Modules/Library/Views/MinimalLibraryView.swift

echo "📁 Current Library module structure:"
find Modules/Library -name "*.swift" -type f

echo -e "\n🔍 Checking for duplicate type definitions:"
# Look for duplicate struct/class declarations
for type in LibraryView LibraryViewModel; do
    echo -e "\nSearching for $type definitions:"
    grep -n "struct $type\|class $type" Modules/Library/**/*.swift 2>/dev/null || echo "Not found"
done

echo -e "\n🏗️ Rebuilding with clean module..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*/Build/Products/Debug-iphonesimulator/LeavnLibrary*
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*/Build/Intermediates.noindex/LeavnModules.build/Debug-iphonesimulator/LeavnLibrary.build/

xcodebuild -scheme LeavnLibrary -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -E "(error:|warning:|BUILD)"
