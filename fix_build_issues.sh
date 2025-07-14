#!/bin/bash

echo "🔧 Fixing Xcode build issues..."

# Fix 1: Clean derived data and package cache
echo "1. Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/org.swift.swiftpm

# Fix 2: Remove empty map image sets
echo "2. Removing empty map image sets..."
cd "$(dirname "$0")/Leavn/Assets.xcassets"
rm -rf Map_Exodus_Ancient.imageset
rm -rf Map_Exodus_Modern.imageset
rm -rf Map_Genesis.imageset
rm -rf Map_Genesis_Ancient.imageset
rm -rf Map_Genesis_Modern.imageset
rm -rf Map_Psalms_Ancient.imageset
rm -rf Map_Psalms_Modern.imageset

# Fix 3: Reset package cache
echo "3. Resetting Swift packages..."
cd "$(dirname "$0")"
rm -rf .build
rm -rf .swiftpm
rm Package.resolved 2>/dev/null || true

echo "✅ Fixes applied!"
echo ""
echo "Now in Xcode:"
echo "1. Click 'Update to recommended settings' if prompted"
echo "2. File → Packages → Reset Package Caches"
echo "3. File → Packages → Resolve Package Versions"
echo "4. Clean Build Folder (Shift+Cmd+K)"
echo "5. Try building again"