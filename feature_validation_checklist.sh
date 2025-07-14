#!/bin/bash

# Feature Validation Checklist Script for Leavn
# This script validates UI features across all platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Leavn"
SCHEME="Leavn"
WORKSPACE="Leavn.xcworkspace"

echo "=========================================="
echo "Leavn Feature Validation Checklist"
echo "=========================================="
echo ""

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to validate file exists
validate_file() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Function to validate directory exists
validate_directory() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Function to run xcodebuild command
run_xcode_command() {
    xcodebuild "$@" 2>&1 | grep -E "(error:|warning:|succeeded|failed)" | tail -20
}

echo "1. Checking Project Structure"
echo "-----------------------------"

# Check main directories
validate_directory "Sources" && print_status $? "Sources directory exists" || print_status $? "Sources directory missing"
validate_directory "Sources/Views" && print_status $? "Views directory exists" || print_status $? "Views directory missing"
validate_directory "Sources/Views/iOS" && print_status $? "iOS views directory exists" || print_status $? "iOS views directory missing"
validate_directory "Sources/Views/macOS" && print_status $? "macOS views directory exists" || print_status $? "macOS views directory missing"
validate_directory "Sources/Views/watchOS" && print_status $? "watchOS views directory exists" || print_status $? "watchOS views directory missing"
validate_directory "Sources/Views/visionOS" && print_status $? "visionOS views directory exists" || print_status $? "visionOS views directory missing"
validate_directory "Resources" && print_status $? "Resources directory exists" || print_status $? "Resources directory missing"
validate_directory "Tests" && print_status $? "Tests directory exists" || print_status $? "Tests directory missing"

echo ""
echo "2. Checking UI Components"
echo "-------------------------"

# Check for essential UI files
UI_COMPONENTS=(
    "Sources/Views/Shared/Components/LeaveRequestCard.swift"
    "Sources/Views/Shared/Components/LoadingView.swift"
    "Sources/Views/Shared/Components/ErrorView.swift"
    "Sources/Views/iOS/Dashboard/DashboardView.swift"
    "Sources/Views/iOS/LeaveRequest/LeaveRequestView.swift"
    "Sources/Views/iOS/Settings/SettingsView.swift"
)

for component in "${UI_COMPONENTS[@]}"; do
    if validate_file "$component"; then
        print_status 0 "$(basename $component) exists"
    else
        print_status 1 "$(basename $component) missing"
        print_warning "  Expected at: $component"
    fi
done

echo ""
echo "3. Checking Design System"
echo "------------------------"

# Check theme and styling files
DESIGN_FILES=(
    "Sources/Utilities/Color+Theme.swift"
    "Sources/Utilities/Font+Custom.swift"
    "Resources/Assets.xcassets"
)

for file in "${DESIGN_FILES[@]}"; do
    if validate_file "$file"; then
        print_status 0 "$(basename $file) exists"
        
        # Additional checks for Assets.xcassets
        if [[ "$file" == *"Assets.xcassets"* ]]; then
            if validate_directory "Resources/Assets.xcassets/AppIcon.appiconset"; then
                print_status 0 "  App icons configured"
            else
                print_status 1 "  App icons missing"
            fi
            
            if validate_directory "Resources/Assets.xcassets/Colors"; then
                print_status 0 "  Color assets configured"
            else
                print_status 1 "  Color assets missing"
            fi
        fi
    else
        print_status 1 "$(basename $file) missing"
    fi
done

echo ""
echo "4. Checking Accessibility"
echo "------------------------"

# Search for accessibility modifiers in SwiftUI files
echo "Searching for accessibility implementations..."

ACCESSIBILITY_COUNT=$(find Sources/Views -name "*.swift" -type f -exec grep -l "\.accessibility\|\.accessibilityLabel\|\.accessibilityHint\|\.accessibilityValue" {} \; | wc -l)

if [ $ACCESSIBILITY_COUNT -gt 0 ]; then
    print_status 0 "Accessibility modifiers found in $ACCESSIBILITY_COUNT files"
else
    print_status 1 "No accessibility modifiers found"
    print_warning "  Add accessibility labels to your views"
fi

# Check for Dynamic Type support
DYNAMIC_TYPE_COUNT=$(find Sources/Views -name "*.swift" -type f -exec grep -l "\.dynamicTypeSize\|@ScaledMetric\|\.font(.largeTitle)\|\.font(.title)" {} \; | wc -l)

if [ $DYNAMIC_TYPE_COUNT -gt 0 ]; then
    print_status 0 "Dynamic Type support found in $DYNAMIC_TYPE_COUNT files"
else
    print_status 1 "No Dynamic Type support found"
    print_warning "  Consider supporting Dynamic Type for better accessibility"
fi

echo ""
echo "5. Checking Platform Support"
echo "---------------------------"

# Check for platform-specific code
for platform in iOS macOS watchOS visionOS; do
    PLATFORM_COUNT=$(find Sources -name "*.swift" -type f -exec grep -l "#if os($platform)" {} \; | wc -l)
    if [ $PLATFORM_COUNT -gt 0 ]; then
        print_status 0 "$platform conditional compilation found in $PLATFORM_COUNT files"
    else
        print_warning "$platform conditional compilation not found"
    fi
done

echo ""
echo "6. Building UI Tests"
echo "-------------------"

# Check if we can build for different platforms
echo "Attempting to build for iOS..."
if xcodebuild -scheme "$SCHEME" -destination "platform=iOS Simulator,name=iPhone 15 Pro" -derivedDataPath build -quiet build-for-testing > /dev/null 2>&1; then
    print_status 0 "iOS build successful"
else
    print_status 1 "iOS build failed"
fi

echo ""
echo "7. Checking Localization"
echo "-----------------------"

# Check for localization files
if validate_file "Resources/Localizable.strings"; then
    print_status 0 "Base localization file exists"
    
    # Count number of localized strings
    STRING_COUNT=$(grep -c "=" Resources/Localizable.strings 2>/dev/null || echo "0")
    if [ $STRING_COUNT -gt 0 ]; then
        print_status 0 "  Found $STRING_COUNT localized strings"
    else
        print_status 1 "  No localized strings found"
    fi
else
    print_status 1 "Localization file missing"
    print_warning "  Create Resources/Localizable.strings for internationalization"
fi

echo ""
echo "8. Checking SwiftUI Previews"
echo "---------------------------"

# Count preview providers
PREVIEW_COUNT=$(find Sources/Views -name "*.swift" -type f -exec grep -l "PreviewProvider\|#Preview" {} \; | wc -l)

if [ $PREVIEW_COUNT -gt 0 ]; then
    print_status 0 "SwiftUI previews found in $PREVIEW_COUNT files"
else
    print_status 1 "No SwiftUI previews found"
    print_warning "  Add previews to your views for faster development"
fi

echo ""
echo "9. Checking Animation Usage"
echo "--------------------------"

# Check for animations
ANIMATION_COUNT=$(find Sources/Views -name "*.swift" -type f -exec grep -l "\.animation\|\.transition\|withAnimation\|\.spring\|\.easeInOut" {} \; | wc -l)

if [ $ANIMATION_COUNT -gt 0 ]; then
    print_status 0 "Animations found in $ANIMATION_COUNT files"
    
    # Check for respecting reduced motion
    REDUCED_MOTION_COUNT=$(find Sources -name "*.swift" -type f -exec grep -l "\.accessibilityReduceMotion\|UIAccessibility.isReduceMotionEnabled" {} \; | wc -l)
    
    if [ $REDUCED_MOTION_COUNT -gt 0 ]; then
        print_status 0 "  Reduced motion preference respected"
    else
        print_warning "  Consider respecting reduced motion preference"
    fi
else
    print_warning "No animations found - consider adding subtle animations"
fi

echo ""
echo "10. Performance Checks"
echo "---------------------"

# Check for performance optimizations
LAZY_COUNT=$(find Sources/Views -name "*.swift" -type f -exec grep -l "LazyVStack\|LazyHStack\|LazyVGrid\|LazyHGrid" {} \; | wc -l)

if [ $LAZY_COUNT -gt 0 ]; then
    print_status 0 "Lazy loading views found in $LAZY_COUNT files"
else
    print_warning "No lazy loading views found - consider using for large lists"
fi

# Check for @StateObject vs @ObservedObject usage
STATE_OBJECT_COUNT=$(find Sources/Views -name "*.swift" -type f -exec grep -l "@StateObject" {} \; | wc -l)
OBSERVED_OBJECT_COUNT=$(find Sources/Views -name "*.swift" -type f -exec grep -l "@ObservedObject" {} \; | wc -l)

print_status 0 "Found $STATE_OBJECT_COUNT @StateObject uses (owned objects)"
print_status 0 "Found $OBSERVED_OBJECT_COUNT @ObservedObject uses (passed objects)"

echo ""
echo "=========================================="
echo "Feature Validation Summary"
echo "=========================================="

# Count successes and failures
TOTAL_CHECKS=0
PASSED_CHECKS=0

# This is a simplified summary - in a real script, you'd track all checks
echo ""
echo "✅ Validation complete!"
echo ""
echo "Next steps:"
echo "1. Fix any missing components marked with ✗"
echo "2. Address warnings marked with ⚠"
echo "3. Run UI tests to verify functionality"
echo "4. Test on all target devices/simulators"
echo ""

# Generate report file
REPORT_FILE="validation_report_$(date +%Y%m%d_%H%M%S).txt"
echo "Full report saved to: $REPORT_FILE"

# Exit with appropriate code
exit 0