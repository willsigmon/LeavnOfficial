#!/bin/bash
# Module Resolution Fix Script
# Resolves "Unable to find module dependency: 'LeavnServices'" errors

echo "🔧 Module Resolution Fix Protocol Starting..."

# Step 1: Clean all build artifacts
echo "1️⃣ Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
rm -rf build/
rm -rf DerivedData/
rm -rf .build/

# Step 2: Remove any NVME references
echo "2️⃣ Removing NVME path references..."
if [ -d "/Volumes/NVME/Xcode Files" ]; then
    rm -rf "/Volumes/NVME/Xcode Files"
fi
if [ -d "/Volumes/NVME/XcodeFiles" ]; then
    rm -rf "/Volumes/NVME/XcodeFiles"
fi

# Step 3: Reset Swift Package Manager
echo "3️⃣ Resetting Swift Package Manager..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .swiftpm

# Step 4: Clean workspace
echo "4️⃣ Cleaning Xcode workspace..."
if command -v xcodebuild >/dev/null 2>&1; then
    xcodebuild clean -project Leavn.xcodeproj -scheme Leavn -quiet || true
else
    echo "   ⚠️  xcodebuild not found - clean manually in Xcode"
fi

# Step 5: Resolve packages
echo "5️⃣ Resolving Swift packages..."
if command -v swift >/dev/null 2>&1; then
    cd local/LeavnCore && swift package resolve && cd ../..
    cd local/LeavnModules && swift package resolve && cd ../..
else
    echo "   ⚠️  Swift CLI not found - resolve packages manually in Xcode"
fi

echo "✅ Module Resolution Fix Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Open Xcode"
echo "2. File → Packages → Reset Package Caches"
echo "3. File → Packages → Resolve Package Versions"
echo "4. Product → Clean Build Folder (Shift+Cmd+K)"
echo "5. Product → Build (Cmd+B)"
echo ""
echo "If errors persist:"
echo "- Check that all import statements match module names exactly"
echo "- Verify package dependencies in Package.swift files"
echo "- Ensure no typos in module names"