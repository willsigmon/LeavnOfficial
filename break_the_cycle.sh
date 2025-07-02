#!/bin/bash
cd /Users/wsig/LeavnParent/Leavn

echo "🔥 Breaking the cycle - Switching to Swift 5 mode temporarily"

# Update Package manifests to Swift 5 mode
cat > Packages/LeavnCore/Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LeavnCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14), 
        .watchOS(.v10),
        .visionOS(.v1),
        .tvOS(.v17)
    ],
    products: [
        .library(name: "LeavnCore", targets: ["LeavnCore"]),
        .library(name: "LeavnServices", targets: ["LeavnServices"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LeavnCore",
            dependencies: []
        ),
        .target(
            name: "LeavnServices", 
            dependencies: ["LeavnCore"]
        ),
        .target(
            name: "DesignSystem",
            dependencies: ["LeavnCore"]
        )
    ]
)
EOF

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
        .library(name: "LeavnLibrary", targets: ["LeavnLibrary"]),
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
            ]
        ),
        .target(
            name: "LeavnSearch",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .target(name: "LeavnBible")
            ]
        ),
        .target(
            name: "LeavnLibrary",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ]
        ),
        .target(
            name: "LeavnSettings",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ]
        ),
        .target(
            name: "LeavnCommunity",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ]
        ),
        .target(
            name: "AuthenticationModule",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ]
        )
    ]
)
EOF

# Clean everything
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
rm -rf .build
rm -rf Packages/LeavnCore/.build
rm -rf Modules/.build

# Regenerate project
xcodegen generate

echo "✅ Reset to Swift 5.9 - Now you can BUILD and iterate"
