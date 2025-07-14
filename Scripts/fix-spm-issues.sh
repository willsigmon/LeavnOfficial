#!/bin/bash

# Fix SPM Issues Script
# This script fixes Swift Package Manager issues

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[FIX]${NC} Fixing Swift Package Manager issues..."

# Function to fix package
fix_package() {
    local package_dir=$1
    echo -e "${YELLOW}[SPM]${NC} Fixing $package_dir..."
    
    cd "$package_dir"
    
    # Clean SPM cache
    swift package clean
    
    # Reset resolved file
    rm -f Package.resolved
    
    # Update dependencies
    swift package update
    
    # Resolve dependencies
    swift package resolve
    
    # Generate Xcode project to verify
    swift package generate-xcodeproj 2>/dev/null || true
    rm -rf *.xcodeproj
    
    cd - > /dev/null
}

# Fix all packages
fix_package "Core/LeavnCore"
fix_package "Core/LeavnModules"

# Clean global SPM cache
echo "Cleaning global SPM cache..."
rm -rf ~/.swiftpm/security
rm -rf ~/.swiftpm/configuration

# Reset Xcode package cache
echo "Resetting Xcode package cache..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*/SourcePackages

echo -e "${GREEN}✅ SPM issues fixed${NC}"