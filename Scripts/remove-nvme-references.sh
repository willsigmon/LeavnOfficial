#!/bin/bash

# Remove NVME References Script
# This script removes any hardcoded NVME or external drive references

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[FIX]${NC} Removing NVME and external drive references..."

# Patterns to search for and remove
PATTERNS=(
    "/Volumes/nvme"
    "/Volumes/NVME"
    "/Volumes/[^/]*/GitHub"
    "file:///Volumes/"
)

# File types to check
FILE_TYPES=(
    "*.pbxproj"
    "*.xcscheme"
    "*.plist"
    "*.xcworkspacedata"
    "*.swift"
    "Package.swift"
    "Package.resolved"
)

# Function to clean file
clean_file() {
    local file=$1
    local modified=false
    
    for pattern in "${PATTERNS[@]}"; do
        if grep -q "$pattern" "$file" 2>/dev/null; then
            echo -e "${YELLOW}[CLEAN]${NC} Removing references in: $file"
            
            # Backup file
            cp "$file" "$file.backup"
            
            # Replace absolute paths with relative ones
            sed -i '' "s|$pattern[^\"']*|.|g" "$file" 2>/dev/null || true
            modified=true
        fi
    done
    
    if [ "$modified" = true ]; then
        echo "  ✓ Cleaned $file"
    fi
}

# Search and clean files
for file_type in "${FILE_TYPES[@]}"; do
    echo "Checking $file_type files..."
    find . -name "$file_type" -type f | while read -r file; do
        # Skip backup files and derived data
        if [[ ! "$file" =~ \.backup$ ]] && [[ ! "$file" =~ DerivedData ]]; then
            clean_file "$file"
        fi
    done
done

# Special handling for Xcode project files
if [ -d "Leavn.xcodeproj" ]; then
    echo "Cleaning Xcode project settings..."
    
    # Remove workspace settings that might contain paths
    rm -rf Leavn.xcodeproj/project.xcworkspace/xcuserdata
    rm -rf Leavn.xcodeproj/xcuserdata
fi

# Clean any xcworkspace files
find . -name "*.xcworkspace" -type d | while read -r workspace; do
    echo "Cleaning workspace: $workspace"
    rm -rf "$workspace/xcuserdata"
done

echo -e "${GREEN}✅ NVME references removed${NC}"