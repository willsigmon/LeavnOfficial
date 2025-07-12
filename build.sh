#!/bin/bash
# Build script for Leavn project
# This ensures builds use project-local paths, not NVME

set -e

PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
DERIVED_DATA="$PROJECT_ROOT/DerivedData"

echo "🚀 Building Leavn..."
echo "Project: $PROJECT_ROOT"
echo "Build: $BUILD_DIR"
echo "DerivedData: $DERIVED_DATA"

# Clean if requested
if [[ "$1" == "clean" ]]; then
    echo "🧹 Cleaning..."
    xcodebuild clean -project Leavn.xcodeproj -scheme Leavn -quiet
    rm -rf "$BUILD_DIR" "$DERIVED_DATA"
fi

# Build
echo "🔨 Building..."
xcodebuild build \
    -project Leavn.xcodeproj \
    -scheme Leavn \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
    SYMROOT="$BUILD_DIR" \
    OBJROOT="$BUILD_DIR" \
    -derivedDataPath "$DERIVED_DATA"

echo "✅ Build complete!"
echo "📱 App: $BUILD_DIR/Debug-iphonesimulator/Leavn.app"