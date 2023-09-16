// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MetalSupport",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0"),
        .macCatalyst("15.0"),
    ],
    products: [
        .library(
            name: "MetalSupport",
            targets: ["MetalSupport"]
        ),
        .library(
            name: "MetalSupportUnsafeConformances",
            targets: ["MetalSupportUnsafeConformances"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MetalSupport",
            dependencies: [],
            swiftSettings: [
               .define("LEGACY")
            ]
        ),
        .target(
            name: "MetalSupportUnsafeConformances",
            dependencies: []
        ),
        .testTarget(
            name: "MetalSupportTests",
            dependencies: ["MetalSupport"]
        ),
    ]
)
