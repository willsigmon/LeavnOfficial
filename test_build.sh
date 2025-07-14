#!/bin/bash

echo "🧪 Testing Leavn build..."

# Navigate to project directory
cd "$(dirname "$0")"

# Clean
echo "🧹 Cleaning build artifacts..."
xcodebuild clean -project Leavn.xcodeproj -scheme Leavn -quiet

# Build for simulator
echo "🔨 Building for iPhone 16 Pro Max simulator..."
xcodebuild build \
    -project Leavn.xcodeproj \
    -scheme "Leavn" \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee build_test_output.log

# Check if build succeeded
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Build succeeded!"
    echo "Check build_test_output.log for details"
else
    echo "❌ Build failed!"
    echo "Checking for errors..."
    grep -E "(error:|failed:|Fatal)" build_test_output.log | head -20
fi