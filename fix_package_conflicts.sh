#!/bin/bash

echo "Fixing package dependency conflicts..."

# Navigate to project directory
cd "/Users/wsig/Cursor Repos/LeavnOfficial"

# Remove conflicting empty Package.swift files
echo "Removing conflicting Package.swift files..."
rm -f Modules/Map/Package.swift
rm -f Modules/Onboarding/Package.swift
rm -f Modules/Discover/Package.swift

# Clean DerivedData
echo "Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Remove Package.resolved to force fresh resolution
echo "Removing Package.resolved..."
rm -f Package.resolved

# Remove .build directory
echo "Removing .build directory..."
rm -rf .build

# Clean Xcode caches
echo "Cleaning Xcode package caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm

echo "Done! Now try building again in Xcode."
echo ""
echo "If issues persist, try:"
echo "1. Close Xcode"
echo "2. Run this script again"
echo "3. Open Xcode and select File > Packages > Reset Package Caches"
echo "4. Build again"