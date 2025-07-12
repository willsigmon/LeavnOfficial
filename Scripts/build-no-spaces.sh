#!/bin/bash

# Leavn Build Script - No Spaces Edition
# This script ensures builds always use the correct path without spaces

set -e

echo "🚀 Leavn Build Script - No Spaces Edition"
echo "========================================"

PROJECT_ROOT="/Users/wsig/GitHub Builds/LeavnOfficial"
BUILD_PATH="$PROJECT_ROOT/build"
DERIVED_DATA_PATH="$PROJECT_ROOT/DerivedData"

# Navigate to project root
cd "$PROJECT_ROOT"

# Clean if requested
if [[ "$1" == "clean" ]]; then
    echo "🧹 Cleaning build..."
    /usr/bin/xcodebuild clean \
        -project Leavn.xcodeproj \
        -scheme Leavn \
        -quiet
fi

# Build with explicit paths
echo "📦 Resolving packages..."
/usr/bin/xcodebuild -resolvePackageDependencies \
    -project Leavn.xcodeproj \
    -scheme Leavn \
    -derivedDataPath "$DERIVED_DATA_PATH"

echo "🔨 Building with correct paths..."
/usr/bin/xcodebuild build \
    -project Leavn.xcodeproj \
    -scheme Leavn \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0' \
    SYMROOT="$BUILD_PATH" \
    OBJROOT="$BUILD_PATH" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -quiet

echo "✅ Build complete!"
echo "📱 App location: $BUILD_PATH/Debug-iphonesimulator/Leavn.app"