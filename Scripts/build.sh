#!/bin/bash

# Build script for Leavn project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Default values
PLATFORM="iOS"
CONFIGURATION="Debug"
CLEAN=false
TEST=false
ARCHIVE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --configuration)
            CONFIGURATION="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --test)
            TEST=true
            shift
            ;;
        --archive)
            ARCHIVE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --platform       Platform to build (iOS, macOS, watchOS, tvOS, visionOS)"
            echo "  --configuration  Build configuration (Debug, Release)"
            echo "  --clean          Clean build folder before building"
            echo "  --test           Run tests after building"
            echo "  --archive        Create archive after building"
            echo "  --help           Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set scheme based on platform
case $PLATFORM in
    iOS)
        SCHEME="Leavn"
        DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro Max"
        ;;
    macOS)
        SCHEME="Leavn-macOS"
        DESTINATION="platform=macOS"
        ;;
    watchOS)
        SCHEME="Leavn-watchOS"
        DESTINATION="platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)"
        ;;
    tvOS)
        SCHEME="Leavn-tvOS"
        DESTINATION="platform=tvOS Simulator,name=Apple TV 4K (3rd generation)"
        ;;
    visionOS)
        SCHEME="Leavn-visionOS"
        DESTINATION="platform=visionOS Simulator,name=Apple Vision Pro"
        ;;
    *)
        log_error "Unknown platform: $PLATFORM"
        exit 1
        ;;
esac

log_info "Building Leavn for $PLATFORM ($CONFIGURATION)"

# Clean if requested
if [ "$CLEAN" = true ]; then
    log_info "Cleaning build folder..."
    xcodebuild clean \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -derivedDataPath .build
fi

# Build
log_info "Building..."
xcodebuild build \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    -derivedDataPath .build \
    -allowProvisioningUpdates \
    | xcbeautify

if [ $? -eq 0 ]; then
    log_info "Build succeeded!"
else
    log_error "Build failed!"
    exit 1
fi

# Test if requested
if [ "$TEST" = true ]; then
    log_info "Running tests..."
    xcodebuild test \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath .build \
        -enableCodeCoverage YES \
        | xcbeautify
    
    if [ $? -eq 0 ]; then
        log_info "Tests passed!"
    else
        log_error "Tests failed!"
        exit 1
    fi
fi

# Archive if requested
if [ "$ARCHIVE" = true ]; then
    log_info "Creating archive..."
    xcodebuild archive \
        -scheme "$SCHEME" \
        -configuration "Release" \
        -archivePath ".build/Leavn-$PLATFORM.xcarchive" \
        -derivedDataPath .build \
        -allowProvisioningUpdates \
        | xcbeautify
    
    if [ $? -eq 0 ]; then
        log_info "Archive created at .build/Leavn-$PLATFORM.xcarchive"
    else
        log_error "Archive failed!"
        exit 1
    fi
fi

log_info "Done!"