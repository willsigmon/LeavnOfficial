#!/bin/bash

echo "🔧 Fixing Module Dependencies Issue..."
echo "This script will help resolve the NetworkingKit, PersistenceKit, and DesignSystem import issues."
echo ""

# Navigate to project root
PROJECT_ROOT="$(dirname "$0")/.."
cd "$PROJECT_ROOT" || exit 1

# Step 1: Clean all caches
echo "Step 1: Cleaning all caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .build
rm -rf Core/LeavnCore/.build
rm -rf Core/LeavnModules/.build

# Step 2: Remove Package.resolved files
echo "Step 2: Removing Package.resolved files..."
rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
rm -f Core/LeavnCore/Package.resolved
rm -f Core/LeavnModules/Package.resolved

# Step 3: Create a temporary test file to verify imports
echo "Step 3: Creating module import verification file..."
cat > Core/LeavnModules/Sources/LeavnLibrary/VerifyImports.swift << 'EOF'
// Temporary file to verify module imports
import Foundation
import LeavnCore
import NetworkingKit
import PersistenceKit
import DesignSystem
import LeavnServices

// This file verifies that all required modules can be imported
// It can be deleted after verification
struct ImportVerification {
    func verify() {
        print("✅ All imports resolved successfully")
    }
}
EOF

# Step 4: Try to build just the packages
echo "Step 4: Building packages..."
echo ""
echo "Building LeavnCore..."
cd Core/LeavnCore
if command -v swift &> /dev/null; then
    swift build || echo "⚠️  Swift build failed, will retry with Xcode"
else
    echo "⚠️  Swift CLI not available"
fi
cd ../..

echo ""
echo "Building LeavnModules..."
cd Core/LeavnModules
if command -v swift &> /dev/null; then
    swift build || echo "⚠️  Swift build failed, will retry with Xcode"
else
    echo "⚠️  Swift CLI not available"
fi
cd ../..

# Step 5: Instructions for Xcode
echo ""
echo "✅ Preparation complete!"
echo ""
echo "📱 Now open Xcode and follow these steps:"
echo ""
echo "1. Open Leavn.xcodeproj"
echo "2. In Xcode menu: File → Packages → Reset Package Caches"
echo "3. In Xcode menu: File → Packages → Resolve Package Versions"
echo "4. Wait for package resolution to complete (check the activity viewer)"
echo "5. Try building the project (Cmd+B)"
echo ""
echo "If the build still fails:"
echo "- Check the Report Navigator (Cmd+9) for detailed error messages"
echo "- Ensure all packages show up in the Project Navigator under 'Package Dependencies'"
echo "- Try Product → Clean Build Folder (Cmd+Shift+K) and rebuild"
echo ""
echo "The temporary file 'VerifyImports.swift' can be deleted once imports are working."