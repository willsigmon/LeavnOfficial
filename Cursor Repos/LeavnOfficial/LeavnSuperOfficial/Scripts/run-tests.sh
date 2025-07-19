#!/bin/bash

# LeavnSuperOfficial Test Runner Script
# This script runs all test suites with proper configuration for CI/CD

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEME="LeavnSuperOfficial"
DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro,OS=latest"
COVERAGE_DIR="${PROJECT_DIR}/coverage"
TEST_RESULTS_DIR="${PROJECT_DIR}/test-results"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

cleanup() {
    log_info "Cleaning up..."
    rm -rf "${COVERAGE_DIR}"
    rm -rf "${TEST_RESULTS_DIR}"
}

prepare_directories() {
    log_info "Preparing directories..."
    mkdir -p "${COVERAGE_DIR}"
    mkdir -p "${TEST_RESULTS_DIR}"
}

run_unit_tests() {
    log_info "Running unit tests..."
    
    xcodebuild test \
        -scheme "${SCHEME}" \
        -destination "${DESTINATION}" \
        -testPlan "Unit Tests" \
        -resultBundlePath "${TEST_RESULTS_DIR}/unit-tests.xcresult" \
        -enableCodeCoverage YES \
        -quiet \
        | xcpretty --test
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_info "Unit tests passed!"
    else
        log_error "Unit tests failed!"
        return 1
    fi
}

run_integration_tests() {
    log_info "Running integration tests..."
    
    # Check if API key is set
    if [ -z "${ESV_API_KEY:-}" ]; then
        log_warning "ESV_API_KEY not set, skipping API integration tests"
    fi
    
    xcodebuild test \
        -scheme "${SCHEME}" \
        -destination "${DESTINATION}" \
        -testPlan "Integration Tests" \
        -resultBundlePath "${TEST_RESULTS_DIR}/integration-tests.xcresult" \
        -quiet \
        | xcpretty --test
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_info "Integration tests passed!"
    else
        log_error "Integration tests failed!"
        return 1
    fi
}

run_performance_tests() {
    log_info "Running performance tests..."
    
    xcodebuild test \
        -scheme "${SCHEME}" \
        -destination "${DESTINATION}" \
        -testPlan "Performance Tests" \
        -resultBundlePath "${TEST_RESULTS_DIR}/performance-tests.xcresult" \
        -quiet \
        | xcpretty --test
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_info "Performance tests passed!"
    else
        log_error "Performance tests failed!"
        return 1
    fi
}

run_ui_tests() {
    log_info "Running UI tests..."
    
    # Kill simulator to ensure clean state
    killall "Simulator" 2>/dev/null || true
    
    xcodebuild test \
        -scheme "${SCHEME}" \
        -destination "${DESTINATION}" \
        -testPlan "UI Tests" \
        -resultBundlePath "${TEST_RESULTS_DIR}/ui-tests.xcresult" \
        -quiet \
        | xcpretty --test
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_info "UI tests passed!"
    else
        log_error "UI tests failed!"
        return 1
    fi
}

run_snapshot_tests() {
    log_info "Running snapshot tests..."
    
    xcodebuild test \
        -scheme "${SCHEME}" \
        -destination "${DESTINATION}" \
        -only-testing:LeavnAppTests/SnapshotTests \
        -resultBundlePath "${TEST_RESULTS_DIR}/snapshot-tests.xcresult" \
        -quiet \
        | xcpretty --test
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_info "Snapshot tests passed!"
    else
        log_error "Snapshot tests failed!"
        return 1
    fi
}

generate_coverage_report() {
    log_info "Generating coverage report..."
    
    # Find the most recent .xcresult bundle
    RESULT_BUNDLE=$(find "${TEST_RESULTS_DIR}" -name "*.xcresult" -type d | head -n 1)
    
    if [ -z "$RESULT_BUNDLE" ]; then
        log_warning "No result bundle found, skipping coverage report"
        return 0
    fi
    
    # Generate coverage report
    xcrun xccov view --report --json "${RESULT_BUNDLE}" > "${COVERAGE_DIR}/coverage.json"
    
    # Extract coverage percentage
    COVERAGE=$(xcrun xccov view --report "${RESULT_BUNDLE}" | grep "LeavnApp" | head -n 1 | awk '{print $NF}')
    
    log_info "Code coverage: ${COVERAGE}"
    
    # Check minimum coverage threshold (80%)
    COVERAGE_NUM=$(echo "${COVERAGE}" | sed 's/%//')
    if (( $(echo "$COVERAGE_NUM < 80" | bc -l) )); then
        log_warning "Code coverage is below 80% threshold"
    fi
}

run_all_tests() {
    log_info "Running all test suites..."
    
    local failed=0
    
    run_unit_tests || failed=1
    run_integration_tests || failed=1
    run_performance_tests || failed=1
    run_ui_tests || failed=1
    run_snapshot_tests || failed=1
    
    if [ $failed -eq 0 ]; then
        log_info "All tests passed!"
    else
        log_error "Some tests failed!"
        return 1
    fi
}

# Main execution
main() {
    local test_suite="${1:-all}"
    
    log_info "Starting test runner for: ${test_suite}"
    
    # Check dependencies
    if ! command -v xcpretty &> /dev/null; then
        log_warning "xcpretty not found, installing..."
        gem install xcpretty
    fi
    
    # Clean and prepare
    cleanup
    prepare_directories
    
    # Run tests based on argument
    case "$test_suite" in
        unit)
            run_unit_tests
            ;;
        integration)
            run_integration_tests
            ;;
        performance)
            run_performance_tests
            ;;
        ui)
            run_ui_tests
            ;;
        snapshot)
            run_snapshot_tests
            ;;
        all)
            run_all_tests
            ;;
        *)
            log_error "Unknown test suite: $test_suite"
            echo "Usage: $0 [unit|integration|performance|ui|snapshot|all]"
            exit 1
            ;;
    esac
    
    # Generate coverage report
    generate_coverage_report
    
    log_info "Test run complete!"
}

# Run main function
main "$@"