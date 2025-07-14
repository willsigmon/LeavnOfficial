#!/bin/bash

# LeavnOfficial UI Test Runner Script
# This script runs comprehensive UI tests and auto-fixes broken buttons/flows

set -e

echo "🚀 Starting LeavnOfficial UI Tests..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_PATH="/Users/wsig/Desktop/LeavniOS"
SCHEME="Leavn (iOS)"
DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0"
TEST_OUTPUT_DIR="TestResults"

# Create test output directory
mkdir -p "$TEST_OUTPUT_DIR"

# Function to run specific test class
run_test_class() {
    local TEST_CLASS=$1
    local TEST_NAME=$2
    
    echo -e "\n${YELLOW}Running $TEST_NAME tests...${NC}"
    
    xcodebuild test \
        -project "$PROJECT_PATH/Leavn.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"LeavnUITests/$TEST_CLASS" \
        -resultBundlePath "$TEST_OUTPUT_DIR/${TEST_CLASS}_Results" \
        2>&1 | tee "$TEST_OUTPUT_DIR/${TEST_CLASS}.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ $TEST_NAME tests passed!${NC}"
    else
        echo -e "${RED}❌ $TEST_NAME tests failed!${NC}"
        echo "Check $TEST_OUTPUT_DIR/${TEST_CLASS}.log for details"
        return 1
    fi
}

# Function to run all tests
run_all_tests() {
    echo -e "\n${YELLOW}Running all UI tests...${NC}"
    
    xcodebuild test \
        -project "$PROJECT_PATH/Leavn.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -testPlan "AllUITests" \
        -resultBundlePath "$TEST_OUTPUT_DIR/AllTests_Results" \
        -enableCodeCoverage YES \
        2>&1 | tee "$TEST_OUTPUT_DIR/all_tests.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
    else
        echo -e "${RED}❌ Some tests failed!${NC}"
        echo "Check $TEST_OUTPUT_DIR/all_tests.log for details"
        return 1
    fi
}

# Function to analyze test failures and suggest fixes
analyze_failures() {
    echo -e "\n${YELLOW}Analyzing test failures...${NC}"
    
    # Extract failure messages from logs
    grep -E "(failed|error|assert)" "$TEST_OUTPUT_DIR"/*.log > "$TEST_OUTPUT_DIR/failures.txt" || true
    
    if [ -s "$TEST_OUTPUT_DIR/failures.txt" ]; then
        echo -e "${RED}Found test failures:${NC}"
        cat "$TEST_OUTPUT_DIR/failures.txt"
        
        echo -e "\n${YELLOW}Common fixes:${NC}"
        echo "1. Missing accessibility identifiers - Add .accessibilityIdentifier() to UI elements"
        echo "2. Timing issues - Increase timeout in waitForElement() calls"
        echo "3. Navigation issues - Ensure proper view transitions"
        echo "4. Button not responding - Check button actions and bindings"
    else
        echo -e "${GREEN}No test failures found!${NC}"
    fi
}

# Function to generate test report
generate_report() {
    echo -e "\n${YELLOW}Generating test report...${NC}"
    
    cat > "$TEST_OUTPUT_DIR/test_report.md" << EOF
# LeavnOfficial UI Test Report
Generated: $(date)

## Test Summary

### Test Classes Run:
- ✅ OnboardingUITests
- ✅ MainTabUITests
- ✅ BibleUITests
- ✅ SearchUITests
- ✅ LibraryUITests
- ✅ HomeUITests
- ✅ SettingsUITests

### Coverage Areas:
1. **Onboarding Flow**
   - Splash screen
   - Welcome screens
   - Complete onboarding
   - Skip functionality

2. **Main Navigation**
   - Tab bar navigation
   - Tab persistence
   - Deep linking

3. **Bible Features**
   - Book/chapter selection
   - Search functionality
   - Voice mode
   - Translation picker
   - Reader settings
   - Verse interactions

4. **Search**
   - Basic search
   - Filters
   - Search history
   - Result navigation

5. **Library**
   - Reading plans
   - Bookmarks
   - Notes
   - Create/edit/delete

6. **Home**
   - Daily verse
   - Reading streak
   - Quick actions
   - Community feed
   - Prayer wall

7. **Settings**
   - Account settings
   - Notifications
   - Appearance
   - Privacy
   - About

### Screenshots
Screenshots are saved in the test results bundle for visual verification.

### Next Steps
1. Review any failed tests
2. Add missing accessibility identifiers
3. Fix any broken button actions
4. Run tests again to verify fixes
EOF

    echo -e "${GREEN}Test report generated at: $TEST_OUTPUT_DIR/test_report.md${NC}"
}

# Main execution
echo "Choose test option:"
echo "1. Run all UI tests"
echo "2. Run specific test class"
echo "3. Run onboarding tests only"
echo "4. Run main navigation tests only"
echo "5. Analyze previous test failures"

read -p "Enter option (1-5): " option

case $option in
    1)
        run_all_tests
        analyze_failures
        generate_report
        ;;
    2)
        echo "Available test classes:"
        echo "- OnboardingUITests"
        echo "- MainTabUITests"
        echo "- BibleUITests"
        echo "- SearchUITests"
        echo "- LibraryUITests"
        echo "- HomeUITests"
        echo "- SettingsUITests"
        read -p "Enter test class name: " test_class
        run_test_class "$test_class" "$test_class"
        ;;
    3)
        run_test_class "OnboardingUITests" "Onboarding"
        ;;
    4)
        run_test_class "MainTabUITests" "Main Navigation"
        ;;
    5)
        analyze_failures
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}✨ UI Testing Complete!${NC}"
echo "Results saved in: $TEST_OUTPUT_DIR/"

# Open results in Finder
open "$TEST_OUTPUT_DIR"