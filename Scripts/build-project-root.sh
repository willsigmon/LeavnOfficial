#!/bin/bash

# Leavn Build Script - Project Root Edition
# All build artifacts stay within the project root
set -e

echo "🚀 Leavn Build Script - Project Root Edition"
echo "==========================================="

PROJECT_ROOT="/Users/wsig/GitHub Builds/LeavnOfficial"
BUILD_PATH="$PROJECT_ROOT/build"
DERIVED_DATA_PATH="$PROJECT_ROOT/DerivedData"

cd "$PROJECT_ROOT"

if [[ "$1" == "clean" ]]; then
    echo "🧹 Cleaning build artifacts..."
    xcodebuild clean \
        -project Leavn.xcodeproj \
        -scheme Leavn \
        -quiet
    rm -rf "$BUILD_PATH"
    rm -rf "$DERIVED_DATA_PATH"
    echo "✨ Clean complete!"
fi

echo "🔨 Building in project root..."
xcodebuild build \
    -project Leavn.xcodeproj \
    -scheme Leavn \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
    SYMROOT="$BUILD_PATH" \
    OBJROOT="$BUILD_PATH" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -quiet

echo "✅ Build complete!"
echo "📱 App location: $BUILD_PATH/Debug-iphonesimulator/Leavn.app"
echo "📂 Derived Data: $DERIVED_DATA_PATH"