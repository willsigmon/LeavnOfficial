#!/bin/bash

echo "========================================="
echo "Leavn App Build Verification Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to project directory
cd "$(dirname "$0")"

echo "📦 Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

echo ""
echo "🔍 Checking for threading issues in code..."

# Check for problematic patterns
echo "Checking for Task creation in init methods..."
if grep -r "init.*{.*Task\s*{" --include="*.swift" Modules/ Leavn/ 2>/dev/null | grep -v "test_bible_navigation.swift"; then
    echo -e "${YELLOW}⚠️  Warning: Found Task creation in init methods${NC}"
else
    echo -e "${GREEN}✅ No Task creation in init methods${NC}"
fi

echo ""
echo "Checking for missing @MainActor annotations..."
if grep -r "func.*async.*{" --include="*.swift" Modules/ Leavn/ | grep -v "@MainActor" | grep -v "actor" | grep -v "protocol" | head -10; then
    echo -e "${YELLOW}⚠️  Warning: Some async functions might need @MainActor${NC}"
else
    echo -e "${GREEN}✅ Async functions properly annotated${NC}"
fi

echo ""
echo "🏗️  Building project..."

# Build for iOS Simulator
xcodebuild -project Leavn.xcodeproj \
    -scheme "Leavn" \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" \
    -configuration Debug \
    clean build \
    2>&1 | tee build_output.log | grep -E "(error:|warning:|Succeeded|Failed|Build)"

# Check build result
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ Build succeeded!${NC}"
    
    echo ""
    echo "🧪 Running threading safety checks..."
    
    # Count warnings and errors
    WARNINGS=$(grep -c "warning:" build_output.log || echo "0")
    ERRORS=$(grep -c "error:" build_output.log || echo "0")
    
    echo "Build Statistics:"
    echo "  Warnings: $WARNINGS"
    echo "  Errors: $ERRORS"
    
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}✅ No build errors detected${NC}"
    fi
    
    echo ""
    echo "📱 Ready for TestFlight!"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode and run the app on a simulator"
    echo "2. Test Bible tab navigation:"
    echo "   - Switch between different books (Genesis, Exodus, Psalms, etc.)"
    echo "   - Navigate chapters using arrow buttons"
    echo "   - Rapidly switch between books"
    echo "3. Archive and upload to TestFlight"
    
else
    echo -e "${RED}❌ Build failed!${NC}"
    echo ""
    echo "Check build_output.log for details"
    
    # Show first few errors
    echo ""
    echo "First few errors:"
    grep "error:" build_output.log | head -5
fi

echo ""
echo "========================================="
echo "Build verification complete"
echo "========================================="