#!/bin/bash

echo "🧹 Cleaning Xcode and SwiftPM caches for Leavn project..."
echo ""

# Step 2: Delete DerivedData and SwiftPM caches
echo "📦 Step 2: Deleting DerivedData and SwiftPM caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData
echo "✅ Deleted DerivedData"

rm -rf ~/Library/Caches/org.swift.swiftpm
echo "✅ Deleted SwiftPM caches"

rm -rf ~/Library/org.swift.swiftpm
echo "✅ Deleted SwiftPM configuration"

# Step 3: Delete all .swiftpm/xcode folders in the repo
echo ""
echo "📁 Step 3: Deleting .swiftpm folders in the repository..."
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Find and delete all .swiftpm directories
find "$PROJECT_DIR" -type d -name ".swiftpm" -exec rm -rf {} + 2>/dev/null
echo "✅ Deleted all .swiftpm directories"

# Also clean any .build directories
find "$PROJECT_DIR" -type d -name ".build" -exec rm -rf {} + 2>/dev/null
echo "✅ Deleted all .build directories"

echo ""
echo "🎉 Cache cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Open the project: $PROJECT_DIR/Leavn.xcodeproj"
echo "3. Go to File → Packages → Reset Package Caches"
echo "4. Then File → Packages → Resolve Package Dependencies"
echo "5. If packages are still missing, go to project settings → Package Dependencies tab"
echo "6. Remove and re-add the following local packages:"
echo "   - $PROJECT_DIR/Packages/LeavnCore"
echo "   - $PROJECT_DIR/Modules"
echo "7. Clean build folder: Product → Clean Build Folder (⌘⇧K)"
echo "8. Build the project: Product → Build (⌘B)"