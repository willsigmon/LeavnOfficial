#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🌐 Mapping the actual dependency graph..."

# Sometimes the issue is circular dependencies that SPM can't resolve
echo "📊 Module dependency analysis:"

echo -e "\n1️⃣ What LeavnLibrary imports:"
grep -h "^import" Modules/Library/**/*.swift 2>/dev/null | sort | uniq

echo -e "\n2️⃣ What imports LeavnLibrary:"
grep -r "import LeavnLibrary" Modules/ --include="*.swift" 2>/dev/null

echo -e "\n3️⃣ Checking for circular dependencies:"
# If Search imports Library and Library imports Bible, and Bible imports Search...
if grep -r "import LeavnBible" Modules/Library/ 2>/dev/null; then
    echo "⚠️  Library imports Bible"
    if grep -r "import LeavnLibrary" Modules/Bible/ 2>/dev/null; then
        echo "   ❌ Bible imports Library - CIRCULAR!"
    fi
fi

echo -e "\n4️⃣ Package.swift dependency declaration for LeavnLibrary:"
awk '/name: "LeavnLibrary"/,/\]/' Modules/Package.swift | grep -E "dependencies:|\.product|\.target" 

echo -e "\n🔧 Alternative: Bypass the module system temporarily:"
echo "Instead of fighting the module system, we could:"
echo "1. Comment out LeavnLibrary from Package.swift targets"
echo "2. Add Library files directly to the main app target"
echo "3. Refactor into modules after we have a working build"

echo -e "\n💭 Or embrace the error and read what it's really saying:"
# Sometimes the most valuable information is in the intermediate build products
find ~/Library/Developer/Xcode/DerivedData/Leavn-*/Build/Intermediates.noindex -name "*.dia" -o -name "*.swiftdeps" | grep -i library | head -5
