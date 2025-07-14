#!/bin/bash

echo "Swift Package Manager Cleanup Script for Leavn Project"
echo "======================================================"

PROJECT_DIR="/Users/wsig/Cursor Repos/LeavnOfficial"

# 1. Backup already created
echo "✓ Project file backup created at: $PROJECT_DIR/Leavn.xcodeproj/project.pbxproj.backup"

# 2. Remove .swiftpm directory if it exists
if [ -d "$PROJECT_DIR/.swiftpm" ]; then
    echo "Removing .swiftpm directory..."
    rm -rf "$PROJECT_DIR/.swiftpm"
    echo "✓ .swiftpm directory removed"
else
    echo "✓ .swiftpm directory does not exist"
fi

# 3. Remove .build directory if it exists
if [ -d "$PROJECT_DIR/.build" ]; then
    echo "Removing .build directory..."
    rm -rf "$PROJECT_DIR/.build"
    echo "✓ .build directory removed"
else
    echo "✓ .build directory does not exist"
fi

# 4. Remove Package.resolved if it exists
if [ -f "$PROJECT_DIR/Package.resolved" ]; then
    echo "Removing Package.resolved..."
    rm -f "$PROJECT_DIR/Package.resolved"
    echo "✓ Package.resolved removed"
else
    echo "✓ Package.resolved does not exist"
fi

# Also check in xcodeproj
if [ -f "$PROJECT_DIR/Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Removing Package.resolved from xcodeproj..."
    rm -f "$PROJECT_DIR/Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    echo "✓ Package.resolved removed from xcodeproj"
fi

# 5. Remove swiftpm directory from xcworkspace
SWIFTPM_DIR="$PROJECT_DIR/Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
if [ -d "$SWIFTPM_DIR" ]; then
    echo "Removing swiftpm directory from xcworkspace..."
    rm -rf "$SWIFTPM_DIR"
    echo "✓ swiftpm directory removed"
else
    echo "✓ swiftpm directory does not exist in xcworkspace"
fi

# 6. Delete DerivedData
echo ""
echo "Clearing DerivedData..."

# Check user's DerivedData
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA_PATH" ]; then
    # Find and remove Leavn-related DerivedData
    echo "Looking for Leavn-related DerivedData..."
    find "$DERIVED_DATA_PATH" -name "Leavn-*" -type d -exec rm -rf {} + 2>/dev/null
    echo "✓ Leavn DerivedData cleared"
else
    echo "DerivedData directory not found at default location"
fi

# Also check project-relative DerivedData
if [ -d "$PROJECT_DIR/DerivedData" ]; then
    echo "Removing project-relative DerivedData..."
    rm -rf "$PROJECT_DIR/DerivedData"
    echo "✓ Project DerivedData removed"
fi

echo ""
echo "======================================================"
echo "Swift Package Manager cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Clean Build Folder (Shift+Cmd+K)"
echo "3. Close and reopen the project"
echo ""
echo "The project file backup is saved at:"
echo "$PROJECT_DIR/Leavn.xcodeproj/project.pbxproj.backup"