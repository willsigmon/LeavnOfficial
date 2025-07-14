#!/bin/bash

# CI Build Script for Leavn
# This script is used by CI/CD systems to build the project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CONFIGURATION=${1:-"Debug"}
PLATFORM=${2:-"iOS"}

# Print colored output
print_status() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local destination=$2
    local scheme="Leavn-$platform"
    
    print_status "Building for $platform ($CONFIGURATION)..."
    
    if xcodebuild build \
        -scheme "$scheme" \
        -destination "$destination" \
        -configuration "$CONFIGURATION" \
        -derivedDataPath "DerivedData" \
        CODE_SIGNING_ALLOWED=NO \
        COMPILER_INDEX_STORE_ENABLE=NO \
        | xcbeautify; then
        print_status "✅ $platform build succeeded"
        return 0
    else
        print_error "❌ $platform build failed"
        return 1
    fi
}

# Main execution
main() {
    print_status "Starting Leavn CI build..."
    print_status "Configuration: $CONFIGURATION"
    print_status "Platform: $PLATFORM"
    
    # Clean previous builds
    print_status "Cleaning previous builds..."
    rm -rf DerivedData
    
    # Build based on platform
    case $PLATFORM in
        "iOS")
            build_platform "iOS" "generic/platform=iOS"
            ;;
        "macOS")
            build_platform "macOS" "platform=macOS"
            ;;
        "watchOS")
            build_platform "watchOS" "generic/platform=watchOS"
            ;;
        "visionOS")
            build_platform "visionOS" "generic/platform=visionOS"
            ;;
        "all")
            # Build all platforms
            overall_status=0
            
            if ! build_platform "iOS" "generic/platform=iOS"; then
                overall_status=1
            fi
            
            if ! build_platform "macOS" "platform=macOS"; then
                overall_status=1
            fi
            
            # Optional platforms
            build_platform "watchOS" "generic/platform=watchOS" || print_warning "watchOS build skipped"
            build_platform "visionOS" "generic/platform=visionOS" || print_warning "visionOS build skipped"
            
            exit $overall_status
            ;;
        *)
            print_error "Unknown platform: $PLATFORM"
            echo "Available platforms: iOS, macOS, watchOS, visionOS, all"
            exit 1
            ;;
    esac
}

# Check dependencies
if ! command -v xcbeautify &> /dev/null; then
    print_warning "xcbeautify not found. Output will be verbose."
fi

# Run the script
main