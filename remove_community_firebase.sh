#!/bin/bash

echo "🧹 Removing Community and Firebase references..."

# Remove Firebase configuration file
echo "→ Removing GoogleService-Info.plist..."
rm -f Leavn/GoogleService-Info.plist

# Remove Community module files
echo "→ Removing Community module..."
rm -rf Modules/Community/

# Remove Firebase and Mock Community services
echo "→ Removing Firebase and Mock Community services..."
rm -f Packages/LeavnCore/Sources/LeavnServices/FirebaseService.swift
rm -f Packages/LeavnCore/Sources/LeavnServices/MockCommunityService.swift

# Remove Firebase-related documentation
echo "→ Removing Firebase documentation..."
rm -f TESTFLIGHT_NO_FIREBASE.md

echo "✅ Community and Firebase references removed!"
echo ""
echo "Next steps:"
echo "1. Remove any remaining imports in other files"
echo "2. Update DIContainer if it references these services"
echo "3. Clean build folder and rebuild"