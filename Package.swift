// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LiquidGlass",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "LiquidGlass", targets: ["LiquidGlass"]),
    ],
    targets: [
        .target(name: "LiquidGlass", path: "Sources/LiquidGlass"),
    ]
)
