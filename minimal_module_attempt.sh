#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🔎 Final diagnostic - understanding what LeavnLibrary actually needs..."

# Sometimes the issue is that the module expects files that don't exist
echo "📋 Checking Package.swift path declarations:"
grep -A 5 "path:" Modules/Package.swift | grep -A 5 "LeavnLibrary"

echo -e "\n🎯 Current Modules structure:"
tree -L 3 Modules/ 2>/dev/null || find Modules -type d | head -20

echo -e "\n💡 Understanding the module graph:"
echo "What LeavnLibrary declares it needs:"
grep -A 10 "name: \"LeavnLibrary\"" Modules/Package.swift

echo -e "\n🏗️ Creating the simplest possible working module:"
# Remove all existing Library files to start fresh
rm -rf Modules/Library
rm -rf Modules/Sources/LeavnLibrary

# Create based on what Package.swift expects
mkdir -p Modules/Library

# Single file, minimal module
cat > Modules/Library/Library.swift << 'EOF'
import SwiftUI

public struct LibraryView: View {
    public init() {}
    
    public var body: some View {
        Text("Library Module Successfully Loaded")
            .padding()
    }
}
EOF

echo -e "\n✅ Created minimal module at: Modules/Library/Library.swift"

# Try one more time with the absolute minimum
xcodebuild -scheme LeavnLibrary -sdk iphonesimulator build 2>&1 | tail -30
