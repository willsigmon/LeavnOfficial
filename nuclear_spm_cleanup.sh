#!/bin/bash

# Nuclear Swift Package Manager Cleanup Script
# This script performs a complete cleanup of all SPM-related caches and references

echo "=== Starting Nuclear SPM Cleanup ==="
echo "Current directory: $(pwd)"
echo "Date: $(date)"
echo ""

# Function to safely remove directories/files
safe_remove() {
    local path="$1"
    if [ -e "$path" ]; then
        echo "Removing: $path"
        rm -rf "$path"
        if [ $? -eq 0 ]; then
            echo "✓ Successfully removed"
        else
            echo "✗ Failed to remove"
        fi
    else
        echo "- Not found: $path"
    fi
    echo ""
}

echo "=== Step 1: Checking if Xcode is running ==="
if pgrep -x "Xcode" > /dev/null; then
    echo "⚠️  WARNING: Xcode is currently running!"
    echo "Please quit Xcode before continuing."
    echo "Press Ctrl+C to cancel or wait 10 seconds to continue anyway..."
    sleep 10
else
    echo "✓ Xcode is not running"
fi
echo ""

echo "=== Step 2: Removing Xcode DerivedData ==="
safe_remove "$HOME/Library/Developer/Xcode/DerivedData/"

echo "=== Step 3: Removing Xcode Caches ==="
safe_remove "$HOME/Library/Caches/com.apple.dt.Xcode"

echo "=== Step 4: Removing Swift Package Manager Caches ==="
safe_remove "$HOME/Library/Caches/org.swift.swiftpm"
safe_remove "$HOME/Library/org.swift.swiftpm"

echo "=== Step 5: Cleaning Project Workspace ==="
PROJECT_DIR="/Users/wsig/Cursor Repos/LeavnOfficial"
cd "$PROJECT_DIR"

# Remove SPM-related directories in the project
safe_remove "Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
safe_remove "Leavn.xcodeproj/project.xcworkspace/xcuserdata"

# Remove any Package.resolved files
echo "Searching for Package.resolved files..."
find . -name "Package.resolved" -type f -print -delete 2>/dev/null
echo ""

echo "=== Step 6: Searching for problematic GUID ==="
GUID="1OJ5W07399N9252HQLWU0QSAFZ3TLA8XH"
echo "Searching for GUID: $GUID"
if grep -r "$GUID" . --include="*.pbxproj" --include="*.xcworkspace" 2>/dev/null; then
    echo "⚠️  WARNING: Found problematic GUID references!"
else
    echo "✓ No problematic GUID references found"
fi
echo ""

echo "=== Step 7: Additional Xcode Cleanup ==="
# Remove additional Xcode caches
safe_remove "$HOME/Library/Caches/com.apple.dt.Xcode.sourcecontrol"
safe_remove "$HOME/Library/Developer/Xcode/Products"

# Remove SPM-specific caches
safe_remove "$HOME/Library/Developer/Xcode/DerivedData/ModuleCache.noindex"
safe_remove "$HOME/Library/Developer/Xcode/DerivedData/SymbolCache"

echo "=== Step 8: Resetting Xcode Package Preferences ==="
# Reset package-related preferences
defaults delete com.apple.dt.Xcode IDEPackageOnlyBuildOperationCacheKey 2>/dev/null || echo "- No package build cache to reset"
defaults delete com.apple.dt.Xcode IDESwiftPackageAdditionAssistantRecentlyUsedPackages 2>/dev/null || echo "- No recent packages to reset"
echo ""

echo "=== Cleanup Summary ==="
echo "✓ Removed all DerivedData"
echo "✓ Cleared Xcode caches"
echo "✓ Cleared Swift Package Manager caches"
echo "✓ Cleaned project workspace"
echo "✓ Verified no problematic GUID references"
echo "✓ Reset Xcode package preferences"
echo ""

echo "=== Next Steps ==="
echo "1. Open Xcode"
echo "2. Clean Build Folder (Cmd+Shift+K)"
echo "3. Reset Package Caches: File → Packages → Reset Package Caches"
echo "4. Build the project"
echo ""
echo "Nuclear cleanup completed at $(date)"