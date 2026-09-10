// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "CommandWidget",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CommandWidget", targets: ["CommandWidget"]),
        .library(name: "CommandWidgetCore", targets: ["CommandWidgetCore"])
    ],
    targets: [
        .target(name: "CommandWidgetCore"),
        .executableTarget(
            name: "CommandWidget",
            dependencies: ["CommandWidgetCore"]
        ),
        .testTarget(
            name: "CommandWidgetCoreTests",
            dependencies: ["CommandWidgetCore"]
        )
    ]
)
