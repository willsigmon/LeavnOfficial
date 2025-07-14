#!/bin/bash

# Full Build and Test Cycle Script
# This script performs a complete clean, build, and test cycle for all platforms

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Results tracking
BUILD_ERRORS=0
TEST_ERRORS=0
WARNINGS=0

# Print functions
print_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_status() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((BUILD_ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    ((WARNINGS++))
}

# Step 1: Clean environment
clean_environment() {
    print_section "1. Cleaning Build Environment"
    
    print_status "Running clean script..."
    if [ -f "Scripts/clean-and-reset.sh" ]; then
        chmod +x Scripts/clean-and-reset.sh
        ./Scripts/clean-and-reset.sh || print_error "Clean script failed"
    else
        print_error "Clean script not found"
    fi
}

# Step 2: Generate Xcode project
generate_project() {
    print_section "2. Generating Xcode Project"
    
    if command -v xcodegen >/dev/null 2>&1; then
        print_status "Running xcodegen..."
        if xcodegen generate; then
            print_status "✓ Xcode project generated successfully"
        else
            print_error "Failed to generate Xcode project"
        fi
    else
        print_error "xcodegen not found. Install with: brew install xcodegen"
    fi
}

# Step 3: Build platforms
build_platform() {
    local platform=$1
    local scheme=$2
    local destination=$3
    
    print_status "Building $platform..."
    
    if xcodebuild build \
        -scheme "$scheme" \
        -destination "$destination" \
        -configuration Debug \
        CODE_SIGNING_ALLOWED=NO \
        COMPILER_INDEX_STORE_ENABLE=NO \
        -quiet; then
        print_status "✓ $platform build succeeded"
        return 0
    else
        print_error "✗ $platform build failed"
        return 1
    fi
}

build_all_platforms() {
    print_section "3. Building All Platforms"
    
    # Check if Xcode project exists
    if [ ! -d "Leavn.xcodeproj" ]; then
        print_error "Leavn.xcodeproj not found. Generate project first."
        return
    fi
    
    # Build iOS
    build_platform "iOS" "Leavn-iOS" "generic/platform=iOS"
    
    # Build macOS
    build_platform "macOS" "Leavn-macOS" "platform=macOS"
    
    # Build watchOS (optional)
    if xcodebuild -list | grep -q "Leavn-watchOS"; then
        build_platform "watchOS" "Leavn-watchOS" "generic/platform=watchOS"
    else
        print_warning "watchOS scheme not found, skipping"
    fi
    
    # Build visionOS (optional)
    if xcodebuild -list | grep -q "Leavn-visionOS"; then
        build_platform "visionOS" "Leavn-visionOS" "generic/platform=visionOS"
    else
        print_warning "visionOS scheme not found, skipping"
    fi
}

# Step 4: Run tests
run_tests() {
    print_section "4. Running Tests"
    
    # Test Swift packages first
    print_status "Testing Swift packages..."
    
    cd Core/LeavnCore
    if swift test; then
        print_status "✓ LeavnCore tests passed"
    else
        print_error "✗ LeavnCore tests failed"
        ((TEST_ERRORS++))
    fi
    cd ../..
    
    cd Core/LeavnModules
    if swift test; then
        print_status "✓ LeavnModules tests passed"
    else
        print_error "✗ LeavnModules tests failed"
        ((TEST_ERRORS++))
    fi
    cd ../..
    
    # Test iOS app
    print_status "Testing iOS app..."
    if xcodebuild test \
        -scheme "Leavn-iOS" \
        -destination "platform=iOS Simulator,name=iPhone 15 Pro,OS=latest" \
        -quiet; then
        print_status "✓ iOS tests passed"
    else
        print_error "✗ iOS tests failed"
        ((TEST_ERRORS++))
    fi
}

# Step 5: Check App Store readiness
check_app_store_readiness() {
    print_section "5. App Store Readiness Check"
    
    if [ -f "Scripts/check-app-store-readiness.sh" ]; then
        chmod +x Scripts/check-app-store-readiness.sh
        ./Scripts/check-app-store-readiness.sh
    else
        print_error "App Store readiness script not found"
    fi
}

# Generate build report
generate_build_report() {
    local report_file="build-test-report.txt"
    
    {
        echo "BUILD AND TEST REPORT"
        echo "===================="
        echo "Generated on: $(date)"
        echo ""
        echo "Summary:"
        echo "  Build Errors: $BUILD_ERRORS"
        echo "  Test Errors: $TEST_ERRORS"
        echo "  Warnings: $WARNINGS"
        echo ""
        
        if [ "$BUILD_ERRORS" -eq 0 ] && [ "$TEST_ERRORS" -eq 0 ]; then
            echo "Status: ✅ ALL BUILDS AND TESTS PASSED"
        else
            echo "Status: ❌ FAILURES DETECTED"
            echo "  - Build failures: $BUILD_ERRORS"
            echo "  - Test failures: $TEST_ERRORS"
        fi
        
        echo ""
        echo "Next Steps:"
        echo "1. Review any build errors and fix source code issues"
        echo "2. Investigate test failures and update test cases"
        echo "3. Address warnings to improve code quality"
        echo "4. Run App Store readiness check"
        echo "5. Create archives for distribution"
        
    } > "$report_file"
    
    print_status "Build report saved to: $report_file"
}

# Main execution
main() {
    echo -e "${BLUE}🚀 Full Build and Test Cycle${NC}"
    echo -e "${BLUE}============================${NC}"
    echo "Starting comprehensive build and test cycle for Leavn project"
    
    # Record start time
    START_TIME=$(date +%s)
    
    # Execute all steps
    clean_environment
    generate_project
    build_all_platforms
    run_tests
    check_app_store_readiness
    
    # Calculate duration
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    # Final summary
    print_section "FINAL SUMMARY"
    echo -e "  Build Errors: ${RED}$BUILD_ERRORS${NC}"
    echo -e "  Test Errors: ${RED}$TEST_ERRORS${NC}"
    echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "  Duration: ${BLUE}${DURATION}s${NC}"
    
    if [ "$BUILD_ERRORS" -eq 0 ] && [ "$TEST_ERRORS" -eq 0 ]; then
        echo -e "\n${GREEN}🎉 SUCCESS: All builds and tests completed successfully!${NC}"
        exit_code=0
    else
        echo -e "\n${RED}💥 FAILURE: Found $((BUILD_ERRORS + TEST_ERRORS)) errors${NC}"
        exit_code=1
    fi
    
    generate_build_report
    exit $exit_code
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v xcodebuild >/dev/null 2>&1; then
        missing_deps+=("Xcode command line tools")
    fi
    
    if ! command -v swift >/dev/null 2>&1; then
        missing_deps+=("Swift compiler")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        exit 1
    fi
}

# Run dependency check and main function
check_dependencies
main "$@"