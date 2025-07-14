#!/bin/bash

echo "🔍 Diagnosing Module Dependency Issues..."
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to project root
PROJECT_ROOT="$(dirname "$0")/.."
cd "$PROJECT_ROOT" || exit 1

# Check 1: Verify Package.swift files exist
echo "1️⃣ Checking Package.swift files..."
if [ -f "Core/LeavnCore/Package.swift" ]; then
    echo -e "${GREEN}✓${NC} LeavnCore/Package.swift exists"
else
    echo -e "${RED}✗${NC} LeavnCore/Package.swift missing!"
fi

if [ -f "Core/LeavnModules/Package.swift" ]; then
    echo -e "${GREEN}✓${NC} LeavnModules/Package.swift exists"
else
    echo -e "${RED}✗${NC} LeavnModules/Package.swift missing!"
fi

# Check 2: Verify source directories
echo ""
echo "2️⃣ Checking source directories..."
MODULES=("NetworkingKit" "PersistenceKit" "DesignSystem" "AnalyticsKit" "LeavnServices")
for module in "${MODULES[@]}"; do
    if [ -d "Core/LeavnCore/Sources/$module" ]; then
        echo -e "${GREEN}✓${NC} $module source directory exists"
    else
        echo -e "${RED}✗${NC} $module source directory missing!"
    fi
done

# Check 3: Look for import errors
echo ""
echo "3️⃣ Checking for problematic imports..."
echo "Files importing NetworkingKit:"
grep -r "import NetworkingKit" Core/LeavnModules/Sources --include="*.swift" | wc -l | xargs echo "  Found in" | xargs -I {} echo "{} files"

echo "Files importing PersistenceKit:"
grep -r "import PersistenceKit" Core/LeavnModules/Sources --include="*.swift" | wc -l | xargs echo "  Found in" | xargs -I {} echo "{} files"

echo "Files importing DesignSystem:"
grep -r "import DesignSystem" Core/LeavnModules/Sources --include="*.swift" | wc -l | xargs echo "  Found in" | xargs -I {} echo "{} files"

# Check 4: Package dependencies
echo ""
echo "4️⃣ Checking package dependencies in LeavnModules..."
grep -A 10 "dependencies:" Core/LeavnModules/Package.swift | grep -E "NetworkingKit|PersistenceKit|DesignSystem" > /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Dependencies are declared in Package.swift"
else
    echo -e "${RED}✗${NC} Dependencies might be missing in Package.swift"
fi

# Fix attempt
echo ""
echo "🔧 Attempting fixes..."
echo "===================="

# Fix 1: Clean everything
echo ""
echo "Fix 1: Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
rm -rf .build
rm -rf Core/LeavnCore/.build
rm -rf Core/LeavnModules/.build
echo -e "${GREEN}✓${NC} Cleaned build artifacts"

# Fix 2: Remove resolved files
echo ""
echo "Fix 2: Removing Package.resolved files..."
rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
rm -f Core/LeavnCore/Package.resolved
rm -f Core/LeavnModules/Package.resolved
echo -e "${GREEN}✓${NC} Removed Package.resolved files"

# Fix 3: Create a diagnostic Swift file
echo ""
echo "Fix 3: Creating diagnostic file..."
mkdir -p Core/LeavnModules/Sources/DiagnosticTest
cat > Core/LeavnModules/Sources/DiagnosticTest/DiagnosticTest.swift << 'EOF'
// Diagnostic file to test module imports
// This file can be deleted after verification

import Foundation

// Test LeavnCore imports
import LeavnCore
import NetworkingKit
import PersistenceKit
import DesignSystem
import AnalyticsKit
import LeavnServices

public struct DiagnosticTest {
    public init() {
        print("✅ All module imports successful!")
    }
    
    public func testNetworkingKit() {
        // Test NetworkingKit types
        let _: NetworkService? = nil
        print("✅ NetworkingKit types accessible")
    }
    
    public func testPersistenceKit() {
        // Test PersistenceKit types
        let _: Storage? = nil
        print("✅ PersistenceKit types accessible")
    }
    
    public func testDesignSystem() {
        // Test DesignSystem availability
        print("✅ DesignSystem accessible")
    }
}
EOF

# Add diagnostic target to Package.swift
echo ""
echo "Fix 4: Adding diagnostic target to Package.swift..."
cat > Core/LeavnModules/Package_temp.swift << 'EOF'
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "LeavnModules",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "LeavnBible", targets: ["LeavnBible"]),
        .library(name: "LeavnSearch", targets: ["LeavnSearch"]),
        .library(name: "LeavnLibrary", targets: ["LeavnLibrary"]),
        .library(name: "LeavnSettings", targets: ["LeavnSettings"]),
        .library(name: "LeavnCommunity", targets: ["LeavnCommunity"]),
        .library(name: "AuthenticationModule", targets: ["AuthenticationModule"]),
        .library(name: "DiagnosticTest", targets: ["DiagnosticTest"])
    ],
    dependencies: [
        .package(path: "../LeavnCore"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.47.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "DiagnosticTest",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "NetworkingKit", package: "LeavnCore"),
                .product(name: "PersistenceKit", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "AnalyticsKit", package: "LeavnCore")
            ]
        ),
        .target(
            name: "LeavnBible",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "NetworkingKit", package: "LeavnCore"),
                .product(name: "PersistenceKit", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .target(
            name: "LeavnSearch",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "NetworkingKit", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .target(
            name: "LeavnLibrary",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "NetworkingKit", package: "LeavnCore"),
                .product(name: "PersistenceKit", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .target(
            name: "LeavnSettings",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "PersistenceKit", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "AnalyticsKit", package: "LeavnCore"),
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .target(
            name: "LeavnCommunity",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "NetworkingKit", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .target(
            name: "AuthenticationModule",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "NetworkingKit", package: "LeavnCore"),
                .product(name: "PersistenceKit", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .testTarget(
            name: "LeavnBibleTests",
            dependencies: ["LeavnBible"]
        ),
        .testTarget(
            name: "LeavnSearchTests",
            dependencies: ["LeavnSearch"]
        ),
        .testTarget(
            name: "LeavnLibraryTests",
            dependencies: ["LeavnLibrary"]
        ),
        .testTarget(
            name: "LeavnSettingsTests",
            dependencies: ["LeavnSettings"]
        ),
        .testTarget(
            name: "AuthenticationModuleTests",
            dependencies: ["AuthenticationModule"]
        )
    ]
)
EOF

# Backup original and replace
cp Core/LeavnModules/Package.swift Core/LeavnModules/Package.swift.backup
mv Core/LeavnModules/Package_temp.swift Core/LeavnModules/Package.swift

echo -e "${GREEN}✓${NC} Added diagnostic target"

# Final instructions
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo -e "${YELLOW}1.${NC} Open Leavn.xcodeproj in Xcode"
echo -e "${YELLOW}2.${NC} Wait for automatic package resolution"
echo -e "${YELLOW}3.${NC} If needed: File → Packages → Reset Package Caches"
echo -e "${YELLOW}4.${NC} Try building the DiagnosticTest target first"
echo -e "${YELLOW}5.${NC} Then build the main Leavn target"
echo ""
echo "If successful:"
echo "- Remove Core/LeavnModules/Sources/DiagnosticTest directory"
echo "- Restore original Package.swift: mv Core/LeavnModules/Package.swift.backup Core/LeavnModules/Package.swift"
echo "- Remove diagnostic target from Package.swift"
echo ""
echo "If still failing, check:"
echo "- Xcode → Report Navigator (Cmd+9) for detailed errors"
echo "- Ensure 'Package Dependencies' shows LeavnCore and LeavnModules"
echo "- Try closing and reopening Xcode"