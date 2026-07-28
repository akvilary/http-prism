// swift-tools-version: 6.2
//
//  prism — Service and Layer abstractions for Swift.
//
//  Direct port of Rust's `tower` crate. The `Service<Request> -> Response`
//  trait and `Layer` (middleware wrapper) are the foundation abstractions
//  that Starlight (axum port) is built on.
//
import PackageDescription

let package = Package(
    name: "http-prism",
    products: [
        .library(name: "HTTPPrism", targets: ["HTTPPrism"]),
    ],
    dependencies: [
        .package(url: "https://github.com/akvilary/http.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "HTTPPrism",
            dependencies: [
                .product(name: "HTTP", package: "http"),
            ],
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
