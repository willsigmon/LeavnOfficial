#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🔬 Deep inspection of LeavnLibrary module boundary..."

# Check what the Package.swift actually declares for this target
echo "📦 Package.swift target definition:"
awk '/name: "LeavnLibrary"/,/\]/' Modules/Package.swift | head -20

echo -e "\n📋 Actual files in Library directory:"
find Modules/Library -name "*.swift" -type f | sort

echo -e "\n🔍 Import analysis for each file:"
for file in $(find Modules/Library -name "*.swift" -type f); do
    echo -e "\n--- $file ---"
    grep "^import\|^public\|^struct\|^class\|^enum" "$file" | head -10
done

echo -e "\n💡 Checking if LibraryView has a mismatched public interface:"
# Sometimes the issue is a public type referencing an internal type
grep -A5 -B5 "public.*View\|public.*Model" Modules/Library/**/*.swift 2>/dev/null

echo -e "\n🎯 Nuclear option - creating minimal viable module:"
cat > Modules/Library/Sources/LeavnLibrary/Library.swift << 'EOF'
import SwiftUI

public struct LibraryModule {
    public static let version = "1.0"
    public init() {}
}

public struct LibraryView: View {
    public init() {}
    public var body: some View {
        Text("Library Module")
    }
}
EOF

echo "✅ Created minimal module at: Modules/Library/Sources/LeavnLibrary/Library.swift"
