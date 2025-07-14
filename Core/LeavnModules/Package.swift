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
        .library(name: "AuthenticationModule", targets: ["AuthenticationModule"])
    ],
    dependencies: [
        .package(path: "../LeavnCore"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.47.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.0")
    ],
    targets: [
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