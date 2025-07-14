#!/bin/bash
# Remove Swift Package Manager directories

echo "Removing swiftpm directory..."
rm -rf "/Users/wsig/Cursor Repos/LeavnOfficial/Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"

echo "Checking if directory was removed..."
if [ ! -d "/Users/wsig/Cursor Repos/LeavnOfficial/Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" ]; then
    echo "✓ swiftpm directory successfully removed"
else
    echo "✗ Failed to remove swiftpm directory"
fi