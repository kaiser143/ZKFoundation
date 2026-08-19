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
        .package(url: "https://github.com/kaiser143/ZKCategories.git", from: "0.4.26"),
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
                .headerSearchPath("Classes/Source/UIKit/ZKUIImagePreview"),
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
