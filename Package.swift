// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Leavn",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
        .tvOS(.v18)
    ],
    products: [
        .app(
            name: "Leavn",
            targets: ["Leavn"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.16.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.5.2"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "Leavn",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "NukeUI", package: "Nuke"),
            ],
            path: "Leavn",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "LeavnTests",
            dependencies: ["Leavn"],
            path: "LeavnTests"
        )
    ]
)