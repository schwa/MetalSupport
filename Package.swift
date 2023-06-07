// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MetalSupport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .macCatalyst(.v17),
    ],
    products: [
        .library(name: "MetalSupport", targets: ["MetalSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
    ],
    targets: [
        .target(
            name: "MetalSupport",
            dependencies: [
                "MetalSupportMacros"
            ]
        ),
        .testTarget(
            name: "MetalSupportTests",
            dependencies: [
                "MetalSupport",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-dump-macro-expansions"])
            ]
        ),
        .macro(
            name: "MetalSupportMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-dump-macro-expansions"])
            ]
        ),
        .executableTarget(
            name: "MetalSupportDemo",
            dependencies: [
                "MetalSupport"
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-dump-macro-expansions"])
            ]
        )
    ]
)
