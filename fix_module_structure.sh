#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🎭 Examining module structure assumptions..."

# First, let's see if the Package.swift expects a specific directory structure
echo "📂 Expected vs Actual structure:"
echo "Expected by SPM: Modules/Library/Sources/LeavnLibrary/"
echo "Actual structure: Modules/Library/"

# Create the SPM-compliant structure
echo -e "\n🏗️ Creating SPM-compliant module structure..."
mkdir -p Modules/Library/Sources/LeavnLibrary

# Move existing files to proper location
echo "📦 Reorganizing files..."
if [ -f "Modules/Library/Views/LibraryView.swift" ]; then
    mv Modules/Library/Views/LibraryView.swift Modules/Library/Sources/LeavnLibrary/
fi

if [ -f "Modules/Library/ViewModels/LibraryViewModel.swift" ]; then
    mv Modules/Library/ViewModels/LibraryViewModel.swift Modules/Library/Sources/LeavnLibrary/
fi

if [ -f "Modules/Library/Models/LibraryModels.swift" ]; then
    # Models might need to stay in a separate target
    echo "Note: LibraryModels.swift might belong to LibraryModels target"
fi

# Create a module export file
cat > Modules/Library/Sources/LeavnLibrary/LeavnLibrary.swift << 'EOF'
// Module exports
@_exported import SwiftUI
@_exported import LeavnCore
@_exported import DesignSystem

// This file ensures the module has at least one source file
// and re-exports necessary dependencies
EOF

echo -e "\n📁 New structure:"
find Modules/Library -name "*.swift" -type f | sort

echo -e "\n🔨 Rebuilding with correct structure..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*/
xcodegen generate
xcodebuild -scheme LeavnLibrary -sdk iphonesimulator build
