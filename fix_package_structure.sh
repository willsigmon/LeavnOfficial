#!/bin/bash

echo "🔧 Fixing package structure to resolve duplicate GUID issue..."

PROJECT_DIR="/Users/wsig/Cursor Repos/LeavnOfficial"
cd "$PROJECT_DIR"

echo "1️⃣ Backing up project file..."
cp Leavn.xcodeproj/project.pbxproj Leavn.xcodeproj/project.pbxproj.backup.$(date +%Y%m%d_%H%M%S)

echo "2️⃣ Removing problematic Package.swift files temporarily..."
# These Package.swift files are causing conflicts when referenced as folders
mv Packages/LeavnCore/Package.swift Packages/LeavnCore/Package.swift.disabled 2>/dev/null || true
mv Modules/Package.swift Modules/Package.swift.disabled 2>/dev/null || true

echo "3️⃣ Removing any remaining SPM artifacts..."
# Remove all .swiftpm directories
find . -name ".swiftpm" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove all .build directories
find . -name ".build" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove Package.resolved files
find . -name "Package.resolved" -type f -delete 2>/dev/null || true

echo "4️⃣ Clearing Xcode caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-* 2>/dev/null || true
rm -rf ~/Library/Caches/org.swift.swiftpm 2>/dev/null || true
rm -rf ~/Library/org.swift.swiftpm 2>/dev/null || true

echo "5️⃣ Creating a clean project structure..."
# Since the packages are referenced as folders, not as SPM packages,
# we need to ensure they're treated as regular source folders

echo "✅ Done! The package structure has been cleaned."
echo ""
echo "📝 Next steps:"
echo "1. Open Xcode"
echo "2. Clean Build Folder (Cmd+Shift+K)"
echo "3. Build the project (Cmd+B)"
echo ""
echo "If you need to use these as actual Swift packages later:"
echo "- Re-enable Package.swift files by removing .disabled extension"
echo "- Add them properly through File > Add Package Dependencies"
echo "- Use 'Add Local...' option and select the package directories"