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
    name: "http-prism",
    products: [
        .library(name: "HTTPPrism", targets: ["HTTPPrism"]),
    ],
    targets: [
        .target(
            name: "HTTPPrism",
            path: "Sources/HTTPPrism",
            swiftSettings: baseSwiftSettings
        ),
        .testTarget(
            name: "HTTPPrismTests",
            dependencies: ["HTTPPrism"],
            path: "Tests/HTTPPrismTests",
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
