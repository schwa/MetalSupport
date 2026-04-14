// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MetalSupport",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "MetalSupport", targets: ["MetalSupport"]),
    ],
    targets: [
        .target(name: "MetalSupport"),
        .testTarget(name: "MetalSupportTests", dependencies: ["MetalSupport"]),
    ]
)