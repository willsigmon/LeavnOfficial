#!/bin/bash

# Fix Module Resolution Script
# This script fixes Swift module resolution issues

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[FIX]${NC} Fixing module resolution issues..."

# Clean module cache
echo "Cleaning Swift module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache
rm -rf ~/Library/Caches/org.swift.swiftpm

# Reset Package.resolved files
echo "Resetting Package.resolved files..."
find . -name "Package.resolved" -type f -delete

# Resolve packages
echo "Resolving Swift packages..."
cd Core/LeavnCore
swift package resolve
cd ../..

cd Core/LeavnModules
swift package resolve
cd ../..

# Clear build folder
echo "Clearing build artifacts..."
if [ -d "build" ]; then
    rm -rf build
fi

echo -e "${GREEN}✅ Module resolution fixes applied${NC}"