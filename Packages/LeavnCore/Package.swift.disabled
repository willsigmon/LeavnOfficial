// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LeavnCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14), 
        .watchOS(.v10),
        .visionOS(.v1),
        .tvOS(.v18)
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
            dependencies: ["DesignSystem"],
            path: "Sources/LeavnCore"
        ),
        .target(
            name: "LeavnServices",
            dependencies: ["LeavnCore"],
            path: "Sources/LeavnServices"
        ),
        .target(
            name: "DesignSystem",
            dependencies: [],
            path: "Sources/DesignSystem"
        )
    ]
)