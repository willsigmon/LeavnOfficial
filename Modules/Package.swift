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
            name: "LibraryModels",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore")
            ],
            path: "Library/Models"
        ),
        .target(
            name: "LeavnLibrary",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .target(name: "LibraryModels")
            ],
            path: "Library",
            exclude: ["Models"]
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
