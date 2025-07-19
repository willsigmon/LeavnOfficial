// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LeavnSuperOfficial",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "LeavnApp",
            targets: ["LeavnApp"]
        ),
        .executable(
            name: "LeavnSuperOfficial",
            targets: ["LeavnSuperOfficial"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.16.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.5.2"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.5.7"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.8.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.6"),
        .package(url: "https://github.com/Quick/Quick", from: "7.6.2"),
        .package(url: "https://github.com/Quick/Nimble", from: "13.6.0")
    ],
    targets: [
        .executableTarget(
            name: "LeavnSuperOfficial",
            dependencies: [
                "LeavnApp"
            ],
            path: "Sources/App"
        ),
        .target(
            name: "LeavnApp",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            path: "Sources/LeavnApp",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "LeavnAppTests",
            dependencies: [
                "LeavnApp",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Tests/LeavnAppTests"
        )
    ]
)