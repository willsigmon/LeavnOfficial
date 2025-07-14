#!/bin/bash
# Fix Build Configuration Script for Leavn iOS App

echo "🔧 Fixing Leavn Build Configuration..."

# Clean build artifacts
echo "🧹 Cleaning build artifacts..."
rm -rf .build
rm -rf DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Regenerate project if xcodegen is available
if command -v xcodegen &> /dev/null; then
    echo "🏗️ Regenerating Xcode project..."
    xcodegen generate
else
    echo "⚠️  xcodegen not found. Please install with: brew install xcodegen"
fi

# Test iOS simulator build
echo "🔨 Testing iOS simulator build..."
xcodebuild build \
    -project Leavn.xcodeproj \
    -scheme "Leavn" \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    -sdk iphonesimulator \
    -configuration Debug \
    ONLY_ACTIVE_ARCH=YES \
    2>&1 | grep -E "(error:|warning:|SUCCEEDED|FAILED)"

# Verify platform settings
echo "🔍 Verifying platform settings..."
xcodebuild -showBuildSettings -project Leavn.xcodeproj -scheme "Leavn" | grep -E "(SUPPORTED_PLATFORMS|SDKROOT|IPHONEOS_DEPLOYMENT_TARGET|TARGETED_DEVICE_FAMILY)" | head -20

echo "✅ Build configuration check complete!"