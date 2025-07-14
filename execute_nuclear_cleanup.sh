#!/bin/bash

# Nuclear SPM Cleanup Execution Script
# Created: 2025-01-07

echo "Starting Nuclear SPM Cleanup..."
echo "================================"

# Check if Xcode is running
if pgrep -x "Xcode" > /dev/null; then
    echo "WARNING: Xcode is running!"
    echo "Please close Xcode before running this cleanup script."
    exit 1
fi

echo "✓ Xcode is not running. Proceeding with cleanup..."

# Function to remove directory with confirmation
remove_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo "Removing: $dir"
        rm -rf "$dir"
        echo "✓ Removed"
    else
        echo "⚠ Not found: $dir"
    fi
}

# 1. Remove DerivedData
echo ""
echo "1. Removing DerivedData..."
remove_dir ~/Library/Developer/Xcode/DerivedData/

# 2. Remove Xcode caches
echo ""
echo "2. Removing Xcode caches..."
remove_dir ~/Library/Caches/com.apple.dt.Xcode

# 3. Remove SPM caches
echo ""
echo "3. Removing SPM caches..."
remove_dir ~/Library/Caches/org.swift.swiftpm
remove_dir ~/Library/org.swift.swiftpm

# 4. Remove project-specific SPM data
echo ""
echo "4. Removing project-specific SPM data..."
remove_dir Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
remove_dir Leavn.xcodeproj/project.xcworkspace/xcuserdata

# 5. Find and remove Package.resolved
echo ""
echo "5. Searching for Package.resolved files..."
find . -name "Package.resolved" -type f -delete 2>/dev/null
echo "✓ Cleaned up Package.resolved files"

# 6. Search for problematic GUID
echo ""
echo "6. Searching for problematic GUID: 1OJ5W07399N9252HQLWU0QSAFZ3TLA8XH"
echo "In project directory:"
grep -r "1OJ5W07399N9252HQLWU0QSAFZ3TLA8XH" . 2>/dev/null | grep -v "\.sh:" | grep -v "\.md:" || echo "✓ Not found in project"

echo ""
echo "In Library directories:"
grep -r "1OJ5W07399N9252HQLWU0QSAFZ3TLA8XH" ~/Library/Developer/Xcode/ 2>/dev/null || echo "✓ Not found in Xcode directories"
grep -r "1OJ5W07399N9252HQLWU0QSAFZ3TLA8XH" ~/Library/Caches/ 2>/dev/null || echo "✓ Not found in Caches"

# 7. Remove additional caches
echo ""
echo "7. Removing additional caches..."
remove_dir ~/Library/Caches/com.apple.dt.Xcode.sourcecontrol
remove_dir ~/Library/Developer/Xcode/Products
remove_dir ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
remove_dir ~/Library/Developer/Xcode/DerivedData/SymbolCache

# 8. Reset Xcode preferences (optional - commented out for safety)
echo ""
echo "8. Xcode preferences reset..."
echo "⚠ Skipping preference reset for safety. Uncomment the next line if needed:"
echo "# defaults delete com.apple.dt.Xcode"

echo ""
echo "================================"
echo "Nuclear cleanup complete!"
echo ""
echo "Summary of what was cleaned:"
echo "✓ DerivedData directory"
echo "✓ Xcode caches"
echo "✓ Swift Package Manager caches"
echo "✓ Project-specific SPM data"
echo "✓ Package.resolved files"
echo "✓ Additional Xcode caches"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Clean build folder (Cmd+Shift+K)"
echo "3. Resolve packages (File > Packages > Resolve Package Versions)"
echo "4. Build the project"