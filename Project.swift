import ProjectDescription

// MARK: - Project

let project = Project(
    name: "Leavn",
    organizationName: "LeavnOfficial",
    packages: [
        .local(path: "local/LeavnCore"),
        .local(path: "local/LeavnModules"),
        .local(path: "Features/LifeSituations")
    ],
    settings: .settings(
        base: ["DEVELOPMENT_TEAM": "YOUR_TEAM_ID"], // Replace with your actual team ID
        configurations: [
            .debug(name: "Debug", xcconfig: "Configurations/Debug.xcconfig"),
            .release(name: "Release", xcconfig: "Configurations/Release.xcconfig")
        ]
    ),
    targets: [
        .target(
            name: "Leavn",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.leavnofficial.Leavn",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .file(path: "Leavn/Info.plist"),
            sources: [
                "Leavn/App/**",
                "Leavn/Views/**",
                "Leavn/Platform/**",
                "Leavn/Configuration/**"
            ],
            resources: ["Leavn/Assets.xcassets/**", "Leavn/LaunchScreen.storyboard"],
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
        ),
        .target(
            name: "LeavnWidgets",
            destinations: [.iPhone, .iPad],
            product: .appExtension,
            bundleId: "com.leavnofficial.Leavn.Widgets",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Widgets/**"],
            dependencies: [
                .package(product: "LeavnCore"),
                .package(product: "DesignSystem")
            ]
        ),
        .target(
            name: "LeavnTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.leavnofficial.LeavnTests",
            infoPlist: .default,
            sources: ["Tests/UnitTests/**"],
            dependencies: [.target(name: "Leavn")]
        ),
        .target(
            name: "LeavnIntegrationTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.leavnofficial.LeavnIntegrationTests",
            infoPlist: .default,
            sources: ["Tests/IntegrationTests/**"],
            dependencies: [
                .target(name: "Leavn"),
                .package(product: "LeavnServices")
            ]
        ),
        .target(
            name: "LeavnUITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: "com.leavnofficial.LeavnUITests",
            infoPlist: .default,
            sources: ["Tests/UITests/**"],
            dependencies: [.target(name: "Leavn")]
        )
    ],
    schemes: [
        .scheme(
            name: "Leavn",
            buildAction: .buildAction(targets: ["Leavn"]),
            runAction: .runAction(executable: "Leavn"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(
            name: "Leavn-Widgets",
            buildAction: .buildAction(targets: ["LeavnWidgets"])
        ),
        .scheme(
            name: "Leavn-Tests",
            buildAction: .buildAction(targets: ["Leavn"]),
            testAction: .testAction(
                targets: [
                    .testableTarget(target: "LeavnTests"),
                    .testableTarget(target: "LeavnIntegrationTests"),
                    .testableTarget(target: "LeavnUITests")
                ],
                options: .options(coverage: true, codeCoverageTargets: ["Leavn"])
            )
        )
    ]
) 