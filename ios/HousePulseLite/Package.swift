// swift-tools-version: 5.7
// This file documents Swift Package dependencies for HousePulse Lite iOS app

import PackageDescription

let package = Package(
    name: "HousePulseLite",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "HousePulseLite",
            targets: ["HousePulseLite"]
        )
    ],
    dependencies: [
        // Note: For a production app, you would typically use:
        // .package(url: "https://github.com/supabase/supabase-swift", from: "1.0.0")
        //
        // For this MVP, we're using URLSession directly for API calls
        // to minimize dependencies and demonstrate the core flow.
    ],
    targets: [
        .target(
            name: "HousePulseLite",
            dependencies: []
        )
    ]
)
