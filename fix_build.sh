#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🔍 Checking for common issues..."

# Check for missing files referenced in project.yml
echo "📁 Checking required directories..."
[ ! -d "Leavn/Assets.xcassets" ] && echo "❌ Missing: Leavn/Assets.xcassets"
[ ! -d "Leavn/Preview Content" ] && echo "❌ Missing: Leavn/Preview Content"

# Check Swift Package resolution
echo "📦 Resolving packages..."
cd Packages/LeavnCore && swift package resolve && cd ../..
cd Modules && swift package resolve && cd ..

# Clean derived data
echo "🧹 Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Generate fresh project
echo "🔨 Generating Xcode project..."
xcodegen generate

echo "✅ Ready to build"
