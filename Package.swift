// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MetalSupport",
    platforms: [
        .iOS("17.0"),
        .macOS("14.0"),
        .macCatalyst("17.0"),
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
