#!/bin/bash

# Leavn App Testing Script
# This script handles simulator setup, building, and testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Leavn Testing Script ===${NC}"

# Configuration
PROJECT_NAME="Leavn"
SCHEME="Leavn"
SIMULATOR_NAME="iPhone 16 Pro Max"
IOS_VERSION="18.0"
DERIVED_DATA_PATH="./DerivedData"

# Function to clean derived data
clean_derived_data() {
    echo -e "${BLUE}Cleaning derived data...${NC}"
    rm -rf "$DERIVED_DATA_PATH"
    xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME" -quiet
}

# Function to find or create simulator
setup_simulator() {
    echo -e "${BLUE}Setting up simulator...${NC}"
    
    # Check if simulator exists
    SIMULATOR_ID=$(xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep -v "unavailable" | head -1 | awk -F'[()]' '{print $2}')
    
    if [ -z "$SIMULATOR_ID" ]; then
        echo -e "${RED}Simulator '$SIMULATOR_NAME' not found. Creating...${NC}"
        # Get the runtime identifier
        RUNTIME_ID=$(xcrun simctl list runtimes | grep "iOS $IOS_VERSION" | awk '{print $NF}')
        if [ -z "$RUNTIME_ID" ]; then
            echo -e "${RED}iOS $IOS_VERSION runtime not found. Please install it via Xcode.${NC}"
            exit 1
        fi
        # Create the simulator
        SIMULATOR_ID=$(xcrun simctl create "$SIMULATOR_NAME" "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max" "$RUNTIME_ID")
    fi
    
    echo "Using simulator: $SIMULATOR_NAME ($SIMULATOR_ID)"
    
    # Boot simulator if not already booted
    SIMULATOR_STATE=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | awk '{print $NF}')
    if [ "$SIMULATOR_STATE" != "(Booted)" ]; then
        echo "Booting simulator..."
        xcrun simctl boot "$SIMULATOR_ID"
        sleep 5
    fi
    
    export SIMULATOR_ID
}

# Function to build the app
build_app() {
    echo -e "${BLUE}Building app for testing...${NC}"
    
    xcodebuild build-for-testing \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -quiet | xcpretty
}

# Function to run unit tests
run_unit_tests() {
    echo -e "${BLUE}Running unit tests...${NC}"
    
    xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -only-testing:LeavnTests \
        -enableCodeCoverage YES \
        -resultBundlePath "./TestResults/unit_tests.xcresult" | xcpretty --test
}

# Function to run UI tests
run_ui_tests() {
    echo -e "${BLUE}Running UI tests...${NC}"
    
    xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -only-testing:LeavnUITests \
        -resultBundlePath "./TestResults/ui_tests.xcresult" | xcpretty --test
}

# Function to generate test report
generate_report() {
    echo -e "${BLUE}Generating test report...${NC}"
    
    # Create reports directory
    mkdir -p TestReports
    
    # Generate coverage report
    if command -v xcov &> /dev/null; then
        xcov --project "${PROJECT_NAME}.xcodeproj" \
             --scheme "$SCHEME" \
             --output_directory "./TestReports" \
             --derived_data_path "$DERIVED_DATA_PATH"
    fi
    
    # Extract test results
    if [ -d "./TestResults" ]; then
        xcrun xcresulttool get --path "./TestResults/unit_tests.xcresult" --format json > "./TestReports/unit_test_results.json"
        xcrun xcresulttool get --path "./TestResults/ui_tests.xcresult" --format json > "./TestReports/ui_test_results.json"
    fi
}

# Function to run manual feature validation
run_feature_validation() {
    echo -e "${BLUE}Launching app for manual feature validation...${NC}"
    
    # Install the app on simulator
    APP_PATH=$(find "$DERIVED_DATA_PATH" -name "${PROJECT_NAME}.app" -type d | grep "iphonesimulator" | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo -e "${RED}App not found in derived data${NC}"
        exit 1
    fi
    
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
    
    # Launch the app
    xcrun simctl launch "$SIMULATOR_ID" "com.leavn.app"
    
    echo -e "${GREEN}App launched on simulator. Please perform manual testing.${NC}"
    echo "Test the following features:"
    echo "1. All tabs (Home, Bible, Library, Search, Community)"
    echo "2. Apocrypha books navigation"
    echo "3. Audio playback functionality"
    echo "4. LifeSituations on Home tab"
    echo "5. Share sheets and modals"
    echo ""
    echo "Press any key when manual testing is complete..."
    read -n 1
}

# Main execution
main() {
    # Create necessary directories
    mkdir -p Scripts TestResults TestReports
    
    # Parse command line arguments
    case "${1:-all}" in
        clean)
            clean_derived_data
            ;;
        build)
            clean_derived_data
            setup_simulator
            build_app
            ;;
        unit)
            setup_simulator
            run_unit_tests
            ;;
        ui)
            setup_simulator
            run_ui_tests
            ;;
        manual)
            setup_simulator
            run_feature_validation
            ;;
        report)
            generate_report
            ;;
        all)
            clean_derived_data
            setup_simulator
            build_app
            run_unit_tests
            run_ui_tests
            run_feature_validation
            generate_report
            ;;
        *)
            echo "Usage: $0 {clean|build|unit|ui|manual|report|all}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Testing complete!${NC}"
}

# Run main function with all arguments
main "$@"