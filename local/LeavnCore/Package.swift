// swift-tools-version: 6.0
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
