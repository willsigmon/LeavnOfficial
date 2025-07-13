import ProjectDescription

let project = Project(
    name: "Leavn",
    organizationName: "LeavnOfficial",
    packages: [
        .local(path: "local/LeavnCore"),
        .local(path: "local/LeavnModules"),
        .local(path: "Features/LifeSituations")
    ],
    targets: [
        .target(
            name: "Leavn",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.leavn.app",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UIRequiredDeviceCapabilities": [
                    "arm64",
                ],
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                ],
            ]),
            sources: [
                "Leavn/App/**",
                "Leavn/Views/**",
                "Leavn/Configuration/**"
            ],
            resources: ["Leavn/Assets.xcassets/**"],
            entitlements: .file(path: "Leavn/Leavn.entitlements"),
            dependencies: [
                .package(product: "LeavnCore"),
                .package(product: "LeavnServices"),
                .package(product: "DesignSystem"),
                .package(product: "LeavnBible"),
                .package(product: "LeavnSearch"),
                .package(product: "LeavnLibrary"),
                .package(product: "LeavnSettings"),
                .package(product: "LeavnCommunity"),
                .package(product: "AuthenticationModule"),
                .package(product: "LeavnLifeSituations")
            ]
        )
    ]
) 