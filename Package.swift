// swift-tools-version: 6.2
//
//  pylon — Service and Layer abstractions for Swift.
//
//  Direct port of Rust's `tower` crate. The `Service<Request> -> Response`
//  trait and `Layer` (middleware wrapper) are the foundation abstractions
//  that Starlight (axum port) is built on.
//
//  Zero external dependencies — only Foundation.
//
import PackageDescription

let package = Package(
    name: "pylon",
    products: [
        .library(name: "Pylon", targets: ["Pylon"]),
    ],
    targets: [
        .target(
            name: "Pylon",
            path: "Sources/Pylon",
            swiftSettings: baseSwiftSettings
        ),
        .testTarget(
            name: "PylonTests",
            dependencies: ["Pylon"],
            path: "Tests/PylonTests",
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
