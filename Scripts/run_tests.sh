#!/bin/bash

# Leavn Test Runner Script
# This script runs all tests for the Leavn project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to run tests for a specific platform
run_platform_tests() {
    local platform=$1
    local destination=$2
    
    print_status "Running tests for $platform..."
    
    if xcodebuild test \
        -scheme "Leavn-$platform" \
        -destination "$destination" \
        -resultBundlePath "TestResults/$platform.xcresult" \
        2>&1 | xcpretty; then
        print_status "✅ $platform tests passed"
        return 0
    else
        print_error "❌ $platform tests failed"
        return 1
    fi
}

# Main execution
main() {
    print_status "Starting Leavn test suite..."
    
    # Create test results directory
    mkdir -p TestResults
    
    # Track overall test status
    overall_status=0
    
    # Run iOS tests
    if ! run_platform_tests "iOS" "platform=iOS Simulator,name=iPhone 15 Pro,OS=18.0"; then
        overall_status=1
    fi
    
    # Run macOS tests
    if ! run_platform_tests "macOS" "platform=macOS"; then
        overall_status=1
    fi
    
    # Run watchOS tests (if available)
    # Uncomment when watchOS tests are ready
    # if ! run_platform_tests "watchOS" "platform=watchOS Simulator,name=Apple Watch Series 9 (45mm),OS=10.0"; then
    #     overall_status=1
    # fi
    
    # Run visionOS tests (if available)
    # Uncomment when visionOS tests are ready
    # if ! run_platform_tests "visionOS" "platform=visionOS Simulator,name=Apple Vision Pro,OS=1.0"; then
    #     overall_status=1
    # fi
    
    # Run SPM package tests
    print_status "Running Swift Package tests..."
    
    # Test LeavnCore
    cd Core/LeavnCore
    if swift test 2>&1 | xcpretty; then
        print_status "✅ LeavnCore tests passed"
    else
        print_error "❌ LeavnCore tests failed"
        overall_status=1
    fi
    cd ../..
    
    # Test LeavnModules
    cd Core/LeavnModules
    if swift test 2>&1 | xcpretty; then
        print_status "✅ LeavnModules tests passed"
    else
        print_error "❌ LeavnModules tests failed"
        overall_status=1
    fi
    cd ../..
    
    # Generate coverage report if all tests passed
    if [ $overall_status -eq 0 ]; then
        print_status "Generating coverage report..."
        xcrun xcresultparser codecov TestResults/*.xcresult > coverage.json
        print_status "Coverage report saved to coverage.json"
    fi
    
    # Final status
    if [ $overall_status -eq 0 ]; then
        print_status "🎉 All tests passed!"
    else
        print_error "💥 Some tests failed. Please check the logs above."
    fi
    
    exit $overall_status
}

# Check dependencies
check_dependencies() {
    if ! command -v xcpretty &> /dev/null; then
        print_warning "xcpretty not found. Installing..."
        gem install xcpretty
    fi
    
    if ! command -v xcresultparser &> /dev/null; then
        print_warning "xcresultparser not found. Test coverage reporting will be skipped."
    fi
}

# Run the script
check_dependencies
main "$@"