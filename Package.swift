// swift-tools-version: 6.2
//
//  prism — Service and Layer abstractions for Swift.
//
//  Direct port of Rust's `tower` crate. The `Service<Request> -> Response`
//  trait and `Layer` (middleware wrapper) are the foundation abstractions
//  that Starlight (axum port) is built on.
//
//  Zero external dependencies — only Foundation.
//
import PackageDescription

let package = Package(
    name: "prism",
    products: [
        .library(name: "Prism", targets: ["Prism"]),
    ],
    targets: [
        .target(
            name: "Prism",
            path: "Sources/Prism",
            swiftSettings: baseSwiftSettings
        ),
        .testTarget(
            name: "PrismTests",
            dependencies: ["Prism"],
            path: "Tests/PrismTests",
            swiftSettings: baseSwiftSettings
        ),
    ]
)

var baseSwiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("StrictMemorySafety"),
    ]
}
