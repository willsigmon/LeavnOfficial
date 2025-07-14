#!/bin/bash

echo "🔨 Rebuilding Leavn as iOS-only project..."

# Navigate to project directory
cd "$(dirname "$0")/.."

# Step 1: Remove old project files
echo "🗑️  Removing corrupted project files..."
rm -rf Leavn.xcodeproj
rm -rf Leavn.xcworkspace
rm -rf *.xcodeproj
rm -rf *.xcworkspace

# Step 2: Clean caches
echo "🧹 Cleaning caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .swiftpm
rm -rf .build

# Step 3: Remove old configurations
echo "📄 Backing up old configurations..."
mkdir -p .backup
mv project.yml .backup/project.yml.bak 2>/dev/null || true
mv Project.swift .backup/Project.swift.bak 2>/dev/null || true

# Step 4: Use iOS-only configuration
echo "📱 Setting up iOS-only configuration..."
mv project-ios.yml project.yml

# Step 5: Generate new project
echo "🚀 Generating fresh iOS project..."
if command -v xcodegen &> /dev/null; then
    xcodegen generate
    echo "✅ iOS project generated successfully!"
else
    echo "❌ XcodeGen not found. Install it with: brew install xcodegen"
    exit 1
fi

# Step 6: Resolve packages
echo "📦 Resolving Swift packages..."
cd Core/LeavnCore && swift package resolve && cd ../..
cd Core/LeavnModules && swift package resolve && cd ../..

# Step 7: Open project
echo "🎉 Opening fresh iOS project..."
open Leavn.xcodeproj

echo "✅ iOS-only rebuild complete!"
echo ""
echo "Next steps:"
echo "1. Wait for Xcode to finish indexing"
echo "2. Select 'Leavn' scheme"
echo "3. Select an iOS simulator"
echo "4. Press Cmd+B to build"