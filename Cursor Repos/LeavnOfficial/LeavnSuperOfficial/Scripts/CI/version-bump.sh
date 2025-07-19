#!/bin/bash
# Version Bump Script for LeavnSuperOfficial

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLIST_PATH="$PROJECT_DIR/Info.plist"
PROJECT_FILE="$PROJECT_DIR/LeavnSuperOfficial.xcodeproj/project.pbxproj"

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to get current version
get_current_version() {
    /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$PLIST_PATH"
}

# Function to get current build
get_current_build() {
    /usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$PLIST_PATH"
}

# Function to set version
set_version() {
    local new_version=$1
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $new_version" "$PLIST_PATH"
    
    # Update in project file as well
    sed -i '' "s/MARKETING_VERSION = .*;/MARKETING_VERSION = $new_version;/g" "$PROJECT_FILE"
}

# Function to set build number
set_build() {
    local new_build=$1
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_build" "$PLIST_PATH"
    
    # Update in project file as well
    sed -i '' "s/CURRENT_PROJECT_VERSION = .*;/CURRENT_PROJECT_VERSION = $new_build;/g" "$PROJECT_FILE"
}

# Function to bump version
bump_version() {
    local version_type=$1
    local current_version=$(get_current_version)
    
    # Parse version components
    IFS='.' read -r -a version_parts <<< "$current_version"
    major="${version_parts[0]}"
    minor="${version_parts[1]:-0}"
    patch="${version_parts[2]:-0}"
    
    case $version_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            print_message $RED "Invalid version type: $version_type"
            exit 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Main script
main() {
    local bump_type="${1:-build}"
    local custom_version="$2"
    
    print_message $YELLOW "Current version: $(get_current_version) ($(get_current_build))"
    
    case $bump_type in
        build)
            # Increment build number only
            local current_build=$(get_current_build)
            local new_build=$((current_build + 1))
            set_build $new_build
            print_message $GREEN "Build number bumped to: $new_build"
            ;;
        major|minor|patch)
            # Bump version and reset build to 1
            local new_version=$(bump_version $bump_type)
            set_version $new_version
            set_build 1
            print_message $GREEN "Version bumped to: $new_version (1)"
            ;;
        custom)
            # Set custom version
            if [ -z "$custom_version" ]; then
                print_message $RED "Custom version not provided"
                exit 1
            fi
            set_version $custom_version
            set_build 1
            print_message $GREEN "Version set to: $custom_version (1)"
            ;;
        *)
            print_message $RED "Usage: $0 [build|major|minor|patch|custom] [version]"
            exit 1
            ;;
    esac
    
    # Verify changes
    print_message $YELLOW "New version: $(get_current_version) ($(get_current_build))"
}

# Run main function
main "$@"