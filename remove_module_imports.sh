#!/bin/bash

echo "🔧 Removing module import statements..."

# Function to remove import statements
remove_imports() {
    local file=$1
    echo "Processing: $file"
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Remove module imports (these are now part of the same target)
    sed -i '' '/^import LeavnCore$/d' "$file"
    sed -i '' '/^import LeavnServices$/d' "$file"
    sed -i '' '/^import DesignSystem$/d' "$file"
    sed -i '' '/^import LeavnBible$/d' "$file"
    sed -i '' '/^import LeavnSearch$/d' "$file"
    sed -i '' '/^import LeavnLibrary$/d' "$file"
    sed -i '' '/^import LeavnSettings$/d' "$file"
    sed -i '' '/^import AuthenticationModule$/d' "$file"
    sed -i '' '/^import LeavnMap$/d' "$file"
    sed -i '' '/^import LeavnOnboarding$/d' "$file"
    sed -i '' '/^import LeavnCommunity$/d' "$file"
    sed -i '' '/^import LibraryModels$/d' "$file"
    
    echo "✅ Processed $file"
}

# Remove imports from main app files
remove_imports "Leavn/App/LeavnApp.swift"
remove_imports "Leavn/Views/ContentView.swift"
remove_imports "Leavn/Views/MainTabView.swift"

# Find and process all Swift files that might have module imports
echo ""
echo "🔍 Searching for other files with module imports..."

# Search in all module directories
for module_dir in Modules/*/ Packages/LeavnCore/Sources/*/; do
    if [ -d "$module_dir" ]; then
        find "$module_dir" -name "*.swift" -type f | while read -r file; do
            if grep -q "^import Leavn" "$file"; then
                remove_imports "$file"
            fi
        done
    fi
done

echo ""
echo "✅ Completed removing module imports!"
echo ""
echo "📝 Next steps:"
echo "1. Add all source files to Xcode project (see integrate_sources.md)"
echo "2. Clean Build Folder (Cmd+Shift+K)"
echo "3. Build the project (Cmd+B)"