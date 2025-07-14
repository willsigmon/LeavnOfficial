#!/bin/bash

echo "🧪 Testing LeavniOS Build (Community/Firebase Removed)"
echo "=================================================="

# Clean build artifacts
echo "→ Cleaning build artifacts..."
xcodebuild clean -project Leavn.xcodeproj -scheme Leavn -sdk iphonesimulator 2>/dev/null

# Remove DerivedData
echo "→ Removing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Build the project
echo "→ Building project..."
xcodebuild -project Leavn.xcodeproj \
    -scheme Leavn \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=iPhone 16 Pro Max,OS=latest" \
    build 2>&1 | tee build_result.log

# Check if build succeeded
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Build succeeded!"
    
    # Extract warnings count
    WARNINGS=$(grep -c "warning:" build_result.log || echo "0")
    echo "⚠️  Warnings: $WARNINGS"
    
    # Show any deprecation warnings
    if grep -q "deprecated" build_result.log; then
        echo ""
        echo "📋 Deprecation warnings found:"
        grep "deprecated" build_result.log | head -5
    fi
else
    echo "❌ Build failed!"
    
    # Show error summary
    echo ""
    echo "📋 Error summary:"
    grep "error:" build_result.log | head -10
fi

echo ""
echo "📄 Full build log saved to: build_result.log"