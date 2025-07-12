#!/bin/bash

# Feature Validation Checklist Script
# Interactive script to guide through manual testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results file
RESULTS_FILE="./TestReports/manual_test_results.md"

# Function to test a feature
test_feature() {
    local feature_name="$1"
    local test_steps="$2"
    
    echo -e "\n${BLUE}Testing: ${feature_name}${NC}"
    echo -e "${YELLOW}${test_steps}${NC}"
    echo -n "Result (p)ass/(f)ail/(s)kip: "
    read -n 1 result
    echo
    
    case $result in
        p|P)
            echo -e "${GREEN}✓ PASSED${NC}"
            echo "- [x] ${feature_name}: PASSED" >> "$RESULTS_FILE"
            return 0
            ;;
        f|F)
            echo -e "${RED}✗ FAILED${NC}"
            echo -n "Enter issue description: "
            read issue_desc
            echo "- [ ] ${feature_name}: FAILED - ${issue_desc}" >> "$RESULTS_FILE"
            return 1
            ;;
        s|S)
            echo -e "${YELLOW}⊘ SKIPPED${NC}"
            echo "- [ ] ${feature_name}: SKIPPED" >> "$RESULTS_FILE"
            return 2
            ;;
    esac
}

# Function to capture screenshot
capture_screenshot() {
    local feature_name="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local filename="screenshot_${feature_name// /_}_${timestamp}.png"
    
    echo -n "Capture screenshot? (y/n): "
    read -n 1 capture
    echo
    
    if [[ $capture == "y" || $capture == "Y" ]]; then
        xcrun simctl io booted screenshot "./TestReports/Screenshots/${filename}"
        echo "Screenshot saved: ${filename}"
        echo "![${feature_name}](Screenshots/${filename})" >> "$RESULTS_FILE"
    fi
}

# Initialize report
initialize_report() {
    mkdir -p TestReports/Screenshots
    
    cat > "$RESULTS_FILE" << EOF
# QA Test Report

**Date**: $(date)
**Tester**: $(whoami)
**Device**: iPhone 16 Pro Max Simulator
**iOS Version**: 18.0
**Build**: $(date +%Y%m%d_%H%M%S)

## Test Results

### Navigation & UI

EOF
}

# Main testing sequence
run_tests() {
    local failed_count=0
    local passed_count=0
    local skipped_count=0
    
    echo -e "${BLUE}=== Leavn App Manual Testing ===${NC}"
    echo "Please ensure the app is running on the simulator before proceeding."
    echo "Press any key to start testing..."
    read -n 1
    
    initialize_report
    
    # Tab Navigation Tests
    echo -e "\n${YELLOW}### Tab Navigation${NC}" >> "$RESULTS_FILE"
    
    test_feature "Home Tab Navigation" \
        "1. Tap Home tab
2. Verify content loads
3. Check for LifeSituations section"
    capture_screenshot "home_tab"
    
    test_feature "Bible Tab Navigation" \
        "1. Tap Bible tab
2. Verify book list appears
3. Check if books are scrollable"
    capture_screenshot "bible_tab"
    
    test_feature "Library Tab Navigation" \
        "1. Tap Library tab
2. Verify saved items appear
3. Check organization/categories"
    capture_screenshot "library_tab"
    
    test_feature "Search Tab Navigation" \
        "1. Tap Search tab
2. Verify search field appears
3. Try typing in search field"
    capture_screenshot "search_tab"
    
    test_feature "Community Tab Navigation" \
        "1. Tap Community tab
2. Verify community content loads
3. Check for user interactions"
    capture_screenshot "community_tab"
    
    # Bible Functionality Tests
    echo -e "\n${YELLOW}### Bible Functionality${NC}" >> "$RESULTS_FILE"
    
    test_feature "Bible Book Selection" \
        "1. Go to Bible tab
2. Select any book (e.g., Genesis)
3. Verify chapters list appears"
    
    test_feature "Chapter Reading" \
        "1. Select a chapter
2. Verify text loads properly
3. Check text formatting and readability"
    capture_screenshot "bible_reading"
    
    test_feature "Apocrypha Access" \
        "1. Go to Bible tab
2. Look for Apocrypha section
3. Try to open an Apocryphal book"
    capture_screenshot "apocrypha"
    
    # Audio Tests
    echo -e "\n${YELLOW}### Audio Functionality${NC}" >> "$RESULTS_FILE"
    
    test_feature "Audio Playback Controls" \
        "1. Find audio play button
2. Tap to start playback
3. Verify audio controls appear"
    capture_screenshot "audio_controls"
    
    test_feature "Audio Play/Pause" \
        "1. Play audio
2. Tap pause
3. Tap play again
4. Verify smooth transitions"
    
    # Share & Modal Tests
    echo -e "\n${YELLOW}### Share & Modal Functionality${NC}" >> "$RESULTS_FILE"
    
    test_feature "Share Sheet" \
        "1. Find any shareable content
2. Tap share button
3. Verify share sheet appears with options"
    capture_screenshot "share_sheet"
    
    test_feature "Modal Presentations" \
        "1. Look for any settings/info buttons
2. Tap to open modals
3. Verify modals open and close properly"
    
    # LifeSituations Tests
    echo -e "\n${YELLOW}### LifeSituations Feature${NC}" >> "$RESULTS_FILE"
    
    test_feature "LifeSituations Display" \
        "1. Go to Home tab
2. Find LifeSituations section
3. Verify categories/topics display"
    capture_screenshot "life_situations"
    
    test_feature "LifeSituations Interaction" \
        "1. Tap on a LifeSituation topic
2. Verify content loads
3. Check navigation back to list"
    
    # Performance Tests
    echo -e "\n${YELLOW}### Performance & Stability${NC}" >> "$RESULTS_FILE"
    
    test_feature "App Launch Time" \
        "1. Force quit the app
2. Launch again
3. Time how long until fully loaded
4. Should be under 3 seconds"
    
    test_feature "Memory Usage" \
        "1. Navigate through all tabs rapidly
2. Open multiple Bible books
3. Check for any lag or crashes"
    
    test_feature "Orientation Support" \
        "1. Rotate simulator (Cmd + Left/Right Arrow)
2. Check all screens in landscape
3. Verify UI adapts properly"
    capture_screenshot "landscape"
    
    # Generate summary
    echo -e "\n## Summary\n" >> "$RESULTS_FILE"
    echo "- Total Tests: $((passed_count + failed_count + skipped_count))" >> "$RESULTS_FILE"
    echo "- Passed: ${passed_count}" >> "$RESULTS_FILE"
    echo "- Failed: ${failed_count}" >> "$RESULTS_FILE"
    echo "- Skipped: ${skipped_count}" >> "$RESULTS_FILE"
    
    echo -e "\n## Recommendations\n" >> "$RESULTS_FILE"
    
    if [[ $failed_count -gt 0 ]]; then
        echo "⚠️ **Critical Issues Found** - Review failed tests above" >> "$RESULTS_FILE"
    else
        echo "✅ **All tested features working as expected**" >> "$RESULTS_FILE"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}=== Leavn App Feature Validation ===${NC}"
    echo "This script will guide you through manual testing of app features."
    echo ""
    
    # Check if simulator is running
    if ! pgrep -x "Simulator" > /dev/null; then
        echo -e "${YELLOW}Warning: Simulator app doesn't appear to be running.${NC}"
        echo "Please launch Xcode and run the app on iPhone 16 Pro Max simulator."
        echo "Press any key when ready..."
        read -n 1
    fi
    
    run_tests
    
    echo -e "\n${GREEN}Testing complete!${NC}"
    echo "Test report saved to: ${RESULTS_FILE}"
    
    # Open report
    echo -n "Open test report? (y/n): "
    read -n 1 open_report
    echo
    
    if [[ $open_report == "y" || $open_report == "Y" ]]; then
        open "$RESULTS_FILE"
    fi
}

main "$@"