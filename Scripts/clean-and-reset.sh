#!/bin/bash

# Comprehensive Clean and Reset Script for Leavn
# This script performs all cleaning and fixing operations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[CLEAN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Main execution
main() {
    print_status "🧹 Starting comprehensive clean and reset..."
    
    # 1. Clean DerivedData
    print_status "Cleaning DerivedData..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
    rm -rf DerivedData
    
    # 2. Clean SPM caches
    print_status "Cleaning Swift Package Manager caches..."
    rm -rf ~/Library/Caches/org.swift.swiftpm
    rm -rf ~/.swiftpm/security
    rm -rf ~/.swiftpm/configuration
    rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache
    
    # 3. Reset Package.resolved files
    print_status "Resetting Package.resolved files..."
    find . -name "Package.resolved" -type f -delete
    
    # 4. Clean Xcode caches
    print_status "Cleaning Xcode caches..."
    rm -rf ~/Library/Caches/com.apple.dt.Xcode
    
    # 5. Remove user-specific Xcode files
    print_status "Removing user-specific Xcode files..."
    find . -name "*.xcodeproj" -type d | while read -r proj; do
        rm -rf "$proj/xcuserdata"
        rm -rf "$proj/project.xcworkspace/xcuserdata"
    done
    
    find . -name "*.xcworkspace" -type d | while read -r workspace; do
        rm -rf "$workspace/xcuserdata"
    done
    
    # 6. Remove NVME/external drive references
    print_status "Removing external drive references..."
    find . -type f \( -name "*.pbxproj" -o -name "*.xcscheme" -o -name "*.plist" \) | while read -r file; do
        if grep -q "/Volumes/" "$file" 2>/dev/null; then
            print_warning "Found external drive reference in: $file"
            sed -i.backup 's|/Volumes/[^/]*/||g' "$file"
        fi
    done
    
    # 7. Resolve Swift packages
    print_status "Resolving Swift packages..."
    
    cd Core/LeavnCore
    print_info "Resolving LeavnCore packages..."
    swift package resolve || print_error "Failed to resolve LeavnCore packages"
    cd ../..
    
    cd Core/LeavnModules
    print_info "Resolving LeavnModules packages..."
    swift package resolve || print_error "Failed to resolve LeavnModules packages"
    cd ../..
    
    # 8. Clean build folders
    print_status "Cleaning build folders..."
    rm -rf build
    rm -rf Build
    
    # 9. Reset simulators (optional - commented out by default)
    # print_status "Resetting simulators..."
    # xcrun simctl shutdown all
    # xcrun simctl erase all
    
    # 10. Make all scripts executable
    print_status "Making scripts executable..."
    find Scripts -name "*.sh" -type f -exec chmod +x {} \;
    
    print_status "✅ Clean and reset complete!"
    print_info "Next steps:"
    print_info "1. Open Xcode and let it index the project"
    print_info "2. Build each scheme individually to verify"
    print_info "3. Run './Scripts/run_tests.sh' to execute all tests"
}

# Check if running in correct directory
if [ ! -f "project.yml" ] && [ ! -d "Leavn.xcodeproj" ] && [ ! -d "Leavn.xcworkspace" ]; then
    print_error "This script must be run from the Leavn project root directory"
    exit 1
fi

# Confirm with user
echo -e "${YELLOW}⚠️  WARNING${NC}: This will clean all build caches and derived data."
echo -n "Continue? (y/N): "
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    main
else
    print_info "Cancelled by user"
    exit 0
fi