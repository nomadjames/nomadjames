// swift-tools-version: 5.9
// This file tells Xcode and Swift Package Manager what this project needs.
// When you open this file in Xcode, it will automatically download AudioKit.

import PackageDescription

let package = Package(
    name: "NomadjamesSynth",
    // Minimum iOS version the app will support
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NomadjamesSynth",
            targets: ["NomadjamesSynth"]
        )
    ],
    // External libraries this project depends on
    dependencies: [
        // AudioKit: open-source audio synthesis framework for iOS/macOS
        // Provides oscillators, filters, effects, and MIDI tools
        .package(
            url: "https://github.com/AudioKit/AudioKit",
            from: "5.6.0"
        ),
        // AudioKitUI: SwiftUI components for AudioKit (visualizers, knobs, etc.)
        .package(
            url: "https://github.com/AudioKit/AudioKitUI",
            from: "0.4.0"
        )
    ],
    targets: [
        .target(
            name: "NomadjamesSynth",
            dependencies: [
                "AudioKit",
                "AudioKitUI"
            ],
            path: "Sources/NomadjamesSynth"
        )
    ]
)
