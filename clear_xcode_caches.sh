#!/bin/bash

# Clear Xcode caches to resolve GUID conflicts
echo "Clearing Xcode caches..."

# Remove DerivedData for Leavn project
echo "Removing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Remove Swift Package Manager cache
echo "Removing SPM cache..."
rm -rf ~/Library/Caches/org.swift.swiftpm

# Remove SPM state
echo "Removing SPM state..."
rm -rf ~/Library/org.swift.swiftpm

# Remove any .swiftpm directories in the project
echo "Removing .swiftpm directories..."
find "/Users/wsig/Cursor Repos/LeavnOfficial" -name ".swiftpm" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove any .build directories in the project
echo "Removing .build directories..."
find "/Users/wsig/Cursor Repos/LeavnOfficial" -name ".build" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove any Package.resolved files
echo "Removing Package.resolved files..."
find "/Users/wsig/Cursor Repos/LeavnOfficial" -name "Package.resolved" -type f -delete 2>/dev/null || true

echo "Cache cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Clean build folder (Cmd+Shift+K)"
echo "3. Close and reopen the project"
echo "4. Build the project"