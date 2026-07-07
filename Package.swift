// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ZKFoundation",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "ZKFoundation",
            targets: ["ZKFoundation"]
        ),
    ],
    dependencies: [
        // ZKCategories SPM support is on master; tagged releases do not yet include Package.swift.
        .package(url: "https://github.com/kaiser143/ZKCategories.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "ZKFoundation",
            dependencies: ["ZKCategories"],
            path: "ZKFoundation",
            sources: ["Classes/Source"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Classes/Source"),
                .headerSearchPath("Classes/Source/Adapter"),
                .headerSearchPath("Classes/Source/AuthContext"),
                .headerSearchPath("Classes/Source/Categories"),
                .headerSearchPath("Classes/Source/LocationManager"),
                .headerSearchPath("Classes/Source/Permission"),
                .headerSearchPath("Classes/Source/URLProtocol"),
                .headerSearchPath("Classes/Source/UIKit"),
                .headerSearchPath("Classes/Source/UIKit/ZKAlert"),
                .headerSearchPath("Classes/Source/UIKit/ZKNavigationBarTransition"),
                .headerSearchPath("Classes/Source/UIKit/ZKNavigationBarTransition/internal"),
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("CoreLocation"),
                .linkedFramework("LocalAuthentication"),
            ]
        ),
    ]
)
