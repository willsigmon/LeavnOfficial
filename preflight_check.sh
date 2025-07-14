#!/bin/bash

# Pre-flight check script for TestFlight submission
# This script verifies that everything is ready for TestFlight

echo "🔍 Running TestFlight Pre-flight Checks..."
echo "========================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

# Check for required files
echo -e "\n📁 Checking Required Files..."

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
    else
        echo -e "${RED}✗${NC} $1 is missing!"
        ERRORS=$((ERRORS + 1))
    fi
}

check_file "Leavn/Info.plist"
check_file "Leavn/Leavn.entitlements"
check_file "Leavn/LaunchScreen.storyboard"
check_file "Leavn/GoogleService-Info.plist"

# Check Info.plist values
echo -e "\n📋 Checking Info.plist Configuration..."

check_plist_key() {
    if grep -q "<key>$1</key>" Leavn/Info.plist; then
        echo -e "${GREEN}✓${NC} $1 is set"
    else
        echo -e "${RED}✗${NC} $1 is missing!"
        ERRORS=$((ERRORS + 1))
    fi
}

check_plist_key "CFBundleIdentifier"
check_plist_key "CFBundleVersion"
check_plist_key "CFBundleShortVersionString"
check_plist_key "NSCameraUsageDescription"
check_plist_key "NSLocationWhenInUseUsageDescription"
check_plist_key "NSMicrophoneUsageDescription"
check_plist_key "NSPhotoLibraryUsageDescription"
check_plist_key "NSUserTrackingUsageDescription"

# Check for placeholder values
echo -e "\n⚠️  Checking for Placeholder Values..."

if grep -q "YOUR_" Leavn/GoogleService-Info.plist; then
    echo -e "${YELLOW}⚠${NC} GoogleService-Info.plist contains placeholder values"
    echo "   Please update with real Firebase configuration"
    WARNINGS=$((WARNINGS + 1))
fi

if grep -q "YOUR_TEAM_ID" build_testflight.sh; then
    echo -e "${YELLOW}⚠${NC} build_testflight.sh contains placeholder Team ID"
    echo "   Please update with your Apple Developer Team ID"
    WARNINGS=$((WARNINGS + 1))
fi

# Check Swift Package Dependencies
echo -e "\n📦 Checking Package Dependencies..."

if [ -f "Package.resolved" ] || [ -d "Packages" ]; then
    echo -e "${GREEN}✓${NC} Swift packages found"
else
    echo -e "${YELLOW}⚠${NC} No Package.resolved file found"
    WARNINGS=$((WARNINGS + 1))
fi

# Check Xcode project
echo -e "\n🛠 Checking Xcode Project..."

if [ -f "Leavn.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✓${NC} Xcode project exists"
    
    # Check for bundle identifier
    if grep -q "PRODUCT_BUNDLE_IDENTIFIER = com.leavn.app" Leavn.xcodeproj/project.pbxproj; then
        echo -e "${GREEN}✓${NC} Bundle identifier is set correctly"
    else
        echo -e "${RED}✗${NC} Bundle identifier not found or incorrect"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}✗${NC} Xcode project not found!"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo -e "\n========================================"
echo "📊 Pre-flight Check Summary:"
echo "========================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Ready for TestFlight.${NC}"
    echo -e "\nNext steps:"
    echo "1. Update placeholder values if needed"
    echo "2. Open Xcode and sign in with your Apple ID"
    echo "3. Run: ./build_testflight.sh"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Ready with $WARNINGS warnings${NC}"
    echo -e "\nPlease address the warnings above before submission."
else
    echo -e "${RED}❌ Found $ERRORS errors and $WARNINGS warnings${NC}"
    echo -e "\nPlease fix the errors above before attempting TestFlight submission."
    exit 1
fi

echo -e "\n💡 Tip: Run 'open TESTFLIGHT_GUIDE.md' for detailed instructions"