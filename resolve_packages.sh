#!/bin/bash

# Script to resolve Swift Package dependencies for Leavn project

echo "🔧 Resolving Swift Package Dependencies for Leavn..."

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
XCODEPROJ="$PROJECT_DIR/Leavn.xcodeproj"

# Check if project exists
if [ ! -d "$XCODEPROJ" ]; then
    echo "❌ Error: Leavn.xcodeproj not found at $XCODEPROJ"
    exit 1
fi

echo "📦 Project found at: $XCODEPROJ"

# Instructions for resolving packages in Xcode
echo ""
echo "=== INSTRUCTIONS TO RESOLVE PACKAGES ==="
echo ""
echo "Since xcodebuild is not available in this environment, please follow these steps in Xcode:"
echo ""
echo "1. Open Xcode"
echo "2. Open the project: $XCODEPROJ"
echo "3. In Xcode menu, go to: File → Packages → Reset Package Caches"
echo "4. Then go to: File → Packages → Resolve Package Dependencies"
echo "5. Wait for Xcode to download and resolve all packages"
echo ""
echo "Alternative method:"
echo "1. In Xcode, select the project in the navigator"
echo "2. Select the 'Leavn' target"
echo "3. Go to the 'Package Dependencies' tab"
echo "4. Click the '+' button to add packages if they're missing:"
echo "   - Add local package: $PROJECT_DIR/Packages/LeavnCore"
echo "   - Add local package: $PROJECT_DIR/Modules"
echo ""
echo "=== PACKAGE STRUCTURE ==="
echo ""
echo "The project expects these packages:"
echo "From LeavnCore package:"
echo "  ✓ LeavnCore"
echo "  ✓ DesignSystem"
echo "  ✓ LeavnServices"
echo ""
echo "From LeavnModules package:"
echo "  ✓ LeavnBible"
echo "  ✓ LeavnSearch"
echo "  ✓ LeavnLibrary"
echo "  ✓ LeavnSettings"
echo "  ✓ AuthenticationModule"
echo "  ✓ LeavnOnboarding"
echo ""

# Check if the package directories exist
echo "=== VERIFYING PACKAGE DIRECTORIES ==="
echo ""

if [ -d "$PROJECT_DIR/Packages/LeavnCore" ]; then
    echo "✅ LeavnCore package directory exists"
else
    echo "❌ LeavnCore package directory missing at: $PROJECT_DIR/Packages/LeavnCore"
fi

if [ -d "$PROJECT_DIR/Modules" ]; then
    echo "✅ LeavnModules package directory exists"
else
    echo "❌ LeavnModules package directory missing at: $PROJECT_DIR/Modules"
fi

echo ""
echo "After resolving packages in Xcode, the project should build successfully."