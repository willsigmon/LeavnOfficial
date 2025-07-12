// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LeavnLifeSituations",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
        .tvOS(.v17)
    ],
    products: [
        .library(name: "LeavnLifeSituations", targets: ["LeavnLifeSituations"]),
    ],
    dependencies: [
        .package(path: "../../local/LeavnCore"),
        .package(path: "../../local/LeavnModules")
    ],
    targets: [
        .target(
            name: "LeavnLifeSituations",
            dependencies: [
                .product(name: "LeavnCore", package: "LeavnCore"),
                .product(name: "LeavnServices", package: "LeavnCore"),
                .product(name: "DesignSystem", package: "LeavnCore"),
                .product(name: "LeavnBible", package: "LeavnModules")
            ],
            path: "Presentation"
        )
    ]
) 