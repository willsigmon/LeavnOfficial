#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🔍 Analyzing module dependency graph..."

# Check for circular imports in Library module
echo -e "\n📚 Library module imports:"
find Modules/Library -name "*.swift" -exec grep -H "^import" {} \; | sort | uniq

echo -e "\n🔗 Cross-module references:"
find Modules -name "*.swift" -exec grep -l "LeavnLibrary\|LibraryViewModel\|LibraryItem" {} \; | grep -v "Library/"

echo -e "\n🎯 Potential circular dependencies:"
# Check if other modules import Library while Library imports them
for module in Bible Search Settings Community Authentication; do
    if grep -r "import Leavn$module" Modules/Library/ 2>/dev/null; then
        echo "⚠️  Library imports $module"
        if grep -r "import LeavnLibrary" Modules/$module/ 2>/dev/null; then
            echo "   ❌ AND $module imports Library - CIRCULAR!"
        fi
    fi
done

echo -e "\n📦 Package.swift target analysis:"
grep -A 10 "name: \"LeavnLibrary\"" Modules/Package.swift
