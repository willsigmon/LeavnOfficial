#!/bin/bash

echo "🧹 Cleaning build folders and caches..."

# Clean build folder
xcodebuild clean -scheme "Leavn" -sdk iphonesimulator

# Remove DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Remove Package.resolved to force re-resolution
rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

echo "📦 Resolving packages..."
xcodebuild -resolvePackageDependencies -scheme "Leavn" -sdk iphonesimulator

echo "🔨 Building project..."
xcodebuild -scheme "Leavn" -sdk iphonesimulator -configuration Debug build

echo "✅ Build complete. The Core Data model should now be properly included."