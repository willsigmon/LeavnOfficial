#!/bin/bash

# Clean Build Script for LeavniOS
# This script cleans all build artifacts and caches

echo "🧹 Cleaning LeavniOS build artifacts..."

# Clean Xcode build folder
echo "→ Cleaning Xcode build folder..."
xcodebuild clean -project Leavn.xcodeproj -scheme Leavn -sdk iphonesimulator

# Remove DerivedData
echo "→ Removing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Clean Swift Package Manager cache
echo "→ Cleaning SPM cache..."
rm -rf .build
rm -rf .swiftpm

# Reset package resolved file
echo "→ Resetting Package.resolved..."
rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# Clean module cache
echo "→ Cleaning module cache..."
rm -rf ~/Library/Caches/org.swift.swiftpm

echo "✅ Clean complete!"
echo ""
echo "Now you can run a fresh build with:"
echo "xcodebuild -scheme 'Leavn' -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=latest' build"