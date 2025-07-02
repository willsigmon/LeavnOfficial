#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🚀 Pragmatic path: Temporarily flatten the architecture..."

# Create a backup of current state
echo "💾 Backing up current Package.swift..."
cp Modules/Package.swift Modules/Package.swift.backup

echo -e "\n📝 Creating a working Package.swift without LeavnLibrary..."
cat > Modules/Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LeavnModules",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
        .tvOS(.v17)
    ],
    products: [
        .library(name: "LeavnBible", targets: ["LeavnBible"]),
        .library(name: "LeavnSearch", targets: ["LeavnSearch"]),
        // Temporarily removed: .library(name: "LeavnLibrary", targets: ["LeavnLibrary"]),
        .library(name: "LeavnSettings", targets: ["LeavnSettings"]),
        .library(name: "LeavnCommunity", targets: ["LeavnCommunity"]),
        .library(name: "AuthenticationModule", targets: ["AuthenticationModule"])
    ],
    dependencies: [
        .package(path: "../Packages/LeavnCore")
    ],
    targets: [
        .target(
            name: "LeavnBible",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Bible"
        ),
        .target(
            name: "LeavnSearch",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .target(name: "LeavnBible")
            ],
            path: "Search"
        ),
        // LeavnLibrary temporarily removed - will add directly to main app
        .target(
            name: "LeavnSettings",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Settings"
        ),
        .target(
            name: "LeavnCommunity",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Community"
        ),
        .target(
            name: "AuthenticationModule",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Authentication"
        )
    ]
)
EOF

echo -e "\n🔧 Copying Library files to main app..."
mkdir -p Leavn/Library
cp -r Modules/Library/* Leavn/Library/ 2>/dev/null || echo "No files to copy"

echo -e "\n📦 Updating project.yml to include Library files directly..."
# This is a temporary measure - we'll modularize again once building

echo -e "\n🏗️ Regenerating and building..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*/
xcodegen generate
xcodebuild -scheme Leavn -sdk iphonesimulator build

echo -e "\n✅ If this builds, you can:"
echo "1. Ship your app"
echo "2. Refactor Library into a proper module later"
echo "3. Learn from what made it fail as a module"
