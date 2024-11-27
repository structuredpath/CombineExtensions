// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CombineExtensions",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "CombineExtensions",
            targets: ["CombineExtensions"]
        ),
    ],
    targets: [
        .target(
            name: "CombineExtensions"),
        .testTarget(
            name: "CombineExtensionsTests",
            dependencies: ["CombineExtensions"]
        ),
    ]
)
