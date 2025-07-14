// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LeavnModules",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v10),
        .visionOS(.v1),
        .tvOS(.v18)
    ],
    products: [
        .library(name: "LeavnBible", targets: ["LeavnBible"]),
        .library(name: "LeavnSearch", targets: ["LeavnSearch"]),
        .library(name: "LeavnLibrary", targets: ["LeavnLibrary"]),
        .library(name: "LeavnSettings", targets: ["LeavnSettings"]),
        .library(name: "AuthenticationModule", targets: ["AuthenticationModule"]),
        .library(name: "LeavnMap", targets: ["LeavnMap"]),
        .library(name: "LeavnOnboarding", targets: ["LeavnOnboarding"])
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
                .product(name: "DesignSystem", package: "LeavnCore"),
                .target(name: "LeavnMap")
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
        .target(
            name: "LeavnLibrary",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Library"
        ),
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
            name: "AuthenticationModule",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Authentication"
        ),
        .target(
            name: "LeavnMap",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Map"
        ),
        .target(
            name: "LeavnOnboarding",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore")
            ],
            path: "Onboarding"
        )
    ]
)