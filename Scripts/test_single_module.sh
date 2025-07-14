#!/bin/bash

# Test single module script
# Usage: ./test_single_module.sh <module_name>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No module name provided${NC}"
    echo "Usage: $0 <module_name>"
    echo "Available modules: LeavnCore, LeavnModules, LeavnBible, LeavnSearch, LeavnLibrary, LeavnSettings, LeavnCommunity, AuthenticationModule"
    exit 1
fi

MODULE_NAME=$1

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Main execution
main() {
    print_status "Testing module: $MODULE_NAME"
    
    # Determine the package directory
    case $MODULE_NAME in
        "LeavnCore")
            cd Core/LeavnCore
            ;;
        "LeavnModules"|"LeavnBible"|"LeavnSearch"|"LeavnLibrary"|"LeavnSettings"|"LeavnCommunity"|"AuthenticationModule")
            cd Core/LeavnModules
            ;;
        *)
            print_error "Unknown module: $MODULE_NAME"
            exit 1
            ;;
    esac
    
    # Run tests
    if [ "$MODULE_NAME" == "LeavnCore" ] || [ "$MODULE_NAME" == "LeavnModules" ]; then
        # Test entire package
        print_status "Running all tests in package..."
        swift test --parallel
    else
        # Test specific module
        print_status "Running tests for $MODULE_NAME..."
        swift test --filter "${MODULE_NAME}Tests"
    fi
    
    if [ $? -eq 0 ]; then
        print_status "✅ Tests passed for $MODULE_NAME"
    else
        print_error "❌ Tests failed for $MODULE_NAME"
        exit 1
    fi
}

# Run the script
main