// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ThreadsFeature",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ThreadsFeature",
            targets: ["ThreadsFeature"]
        )
    ],
    dependencies: [
        .package(
            url: "git@github.com:ivalx1s/SUINavigationFusion.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "ThreadsFeature",
            dependencies: [
                "SUINavigationFusion"
            ]
        )
    ]
)

