#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🔨 Performing targeted build with verbose output..."

# Build just LeavnLibrary with detailed diagnostics
xcodebuild -scheme Leavn \
    -sdk iphonesimulator \
    -target LeavnLibrary \
    -configuration Debug \
    build \
    OTHER_SWIFT_FLAGS="-driver-print-jobs -v" 2>&1 | tail -100

echo -e "\n📋 If that's too noisy, let's check for missing files:"
# Sometimes SwiftDriver fails when expected files don't exist
find Modules/Library -name "*.swift" | while read file; do
    if ! [ -s "$file" ]; then
        echo "❌ Empty file: $file"
    fi
done

echo -e "\n🎯 Checking module map generation:"
ls -la Modules/.build/*/LeavnLibrary.build/ 2>/dev/null || echo "No build artifacts found"
