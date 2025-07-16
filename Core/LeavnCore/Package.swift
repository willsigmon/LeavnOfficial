// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "LeavnCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "LeavnCore", targets: ["LeavnCore"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "LeavnServices", targets: ["LeavnServices"]),
        .library(name: "NetworkingKit", targets: ["NetworkingKit"]),
        .library(name: "PersistenceKit", targets: ["PersistenceKit"]),
        .library(name: "AnalyticsKit", targets: ["AnalyticsKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "LeavnCore",
            dependencies: []
        ),
        .target(
            name: "DesignSystem",
            dependencies: ["LeavnCore"]
        ),
        .target(
            name: "LeavnServices",
            dependencies: [
                "LeavnCore",
                "NetworkingKit",
                "PersistenceKit",
                "AnalyticsKit",
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .target(
            name: "NetworkingKit",
            dependencies: [
                "LeavnCore",
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
        .target(
            name: "PersistenceKit",
            dependencies: [
                "LeavnCore",
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ]
        ),
        .target(
            name: "AnalyticsKit",
            dependencies: ["LeavnCore"]
        ),
        .testTarget(
            name: "LeavnCoreTests",
            dependencies: ["LeavnCore", "LeavnServices", "NetworkingKit", "PersistenceKit", "AnalyticsKit"]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem", "LeavnCore"]
        )
    ]
)