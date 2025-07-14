#!/bin/bash

# Fix Build Paths Script
# This script fixes build path issues in the Xcode project

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[FIX]${NC} Fixing build paths..."

# Clean DerivedData
echo "Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Remove local DerivedData if exists
if [ -d "DerivedData" ]; then
    echo "Removing local DerivedData..."
    rm -rf DerivedData
fi

# Fix relative paths in pbxproj if it exists
if [ -f "Leavn.xcodeproj/project.pbxproj" ]; then
    echo "Checking project file for absolute paths..."
    
    # Backup project file
    cp Leavn.xcodeproj/project.pbxproj Leavn.xcodeproj/project.pbxproj.backup
    
    # Remove absolute paths that might cause issues
    sed -i '' 's|/Users/[^/]*/|~/|g' Leavn.xcodeproj/project.pbxproj 2>/dev/null || true
    
    # Remove any hardcoded derived data paths
    sed -i '' 's|/Library/Developer/Xcode/DerivedData/[^/]*||g' Leavn.xcodeproj/project.pbxproj 2>/dev/null || true
fi

# Create standard directory structure
echo "Ensuring standard directory structure..."
mkdir -p Core/LeavnCore/Sources
mkdir -p Core/LeavnCore/Tests
mkdir -p Core/LeavnModules/Sources
mkdir -p Core/LeavnModules/Tests
mkdir -p Scripts
mkdir -p Resources

# Fix xcscheme files
echo "Checking scheme files..."
find . -name "*.xcscheme" -type f | while read -r scheme; do
    # Remove absolute paths from schemes
    sed -i '' 's|/Users/[^/]*/|~/|g' "$scheme" 2>/dev/null || true
done

echo -e "${GREEN}✅ Build paths fixed${NC}"