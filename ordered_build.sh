#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🎯 Strategic rebuild with explicit module ordering..."

# Clean only the problematic module
rm -rf Modules/.build/*/LeavnLibrary*
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*/Build/Products/*/LeavnLibrary*

# Build dependencies first, explicitly
echo "1️⃣ Building DesignSystem..."
xcodebuild -scheme Leavn -target DesignSystem -sdk iphonesimulator build

echo "2️⃣ Building LeavnCore..."
xcodebuild -scheme Leavn -target LeavnCore -sdk iphonesimulator build

echo "3️⃣ Building LeavnServices..."
xcodebuild -scheme Leavn -target LeavnServices -sdk iphonesimulator build

echo "4️⃣ Now attempting LeavnLibrary with its foundation in place..."
xcodebuild -scheme Leavn -target LeavnLibrary -sdk iphonesimulator build -verbose 2>&1 | grep -E "(error:|warning:|note:|FAILED|Building)" | tail -50

echo -e "\n🔍 Module interface inspection:"
find ~/Library/Developer/Xcode/DerivedData/Leavn-*/Build -name "*.swiftinterface" | grep -i library | head -5
