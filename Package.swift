// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Candle",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // An xtool project should contain exactly one library product,
        // representing the main app.
        .library(
            name: "Candle",
            targets: ["Candle"]
        ),
    ],
    targets: [
        .target(
            name: "Candle"
        ),
    ]
)
