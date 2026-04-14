// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MetalSupport",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "MetalSupport", targets: ["MetalSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.3.0"),
    ],
    targets: [
        .target(name: "MetalSupport", dependencies: [
            .product(name: "OrderedCollections", package: "swift-collections"),
        ]),
        .testTarget(name: "MetalSupportTests", dependencies: ["MetalSupport"]),
    ]
)