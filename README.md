# HTTPPrism

A Swift port of [`tower`](https://docs.rs/tower): the `Service<Request>` trait
and the `Layer` middleware abstraction that axum/hyper/tower are built around.

Direct 1:1 port of the two central types:

- `Service` — an asynchronous `Request -> Response` transformer
- `Layer` — a factory that wraps one `Service` in another (middleware)

Every router, every handler, every middleware in the Starlight workspace is
fundamentally a `Service<Request>`. The same role the `tower` crate plays in the
Rust axum/hyper/tower ecosystem.

## Status

Early / experimental. Currently used by:

- [`starlight`](https://github.com/akvilary/starlight) — Swift port of axum (its `Router<S>`, `HandlerService`, `Route` are all `Service`).
- [`http-lens`](https://github.com/akvilary/http-lens) — Swift port of tower-http (its middleware `Layer`s are built on `HTTPPrism`).

## Installation

```swift
.package(url: "https://github.com/akvilary/http-prism.git", from: "0.1.0")
```

```swift
.target(name: "YourTarget", dependencies: [
    .product(name: "HTTPPrism", package: "http-prism"),
])
```

## Overview

### `Service` — the central abstraction

A minimal `async throws` protocol with associated `Request` / `Response` types.
Rust's `poll_ready + call` collapse into a single `async` method (backpressure is
modelled by awaiting the call itself):

```swift
import HTTPPrism
import HTTP

public protocol Service: Sendable {
    associatedtype Request: Sendable
    associatedtype Response: Sendable
    func call(_ request: consuming Request) async throws -> Response
}

/// Convenience constraint: `Service<HTTP.Request, HTTP.Response>`.
public protocol HTTPService: Service
    where Request == HTTP.Request, Response == HTTP.Response {}
```

### `BoxService` — type erasure

Swift has no trait objects; `BoxService<Request, Response>` provides the
equivalent via closure-based erasure (mirroring tower's `BoxCloneService`). This
is what lets a `Router` hold heterogeneous routes and layers behind one type.
`BoxService` itself conforms to `Service`, so a boxed service can be wrapped again.

```swift
let boxed = BoxService { (req: HTTP.Request) in try await myService.call(req) }
// or: erase(myService) — helper that infers Request/Response
```

### `Layer` — middleware as a factory

`Layer<Request, Response>` wraps an inner `Service` to add cross-cutting behaviour
(logging, auth, compression, …). It is a struct (closure-based), not a protocol,
so building one is one allocation and the closure is the layer. Layers compose via
`followedBy` or `ServiceBuilder`:

```swift
// Require an Authorization header before delegating to the inner service.
let authLayer = Layer<HTTP.Request, HTTP.Response> { inner in
    BoxService { req in
        guard req.headers.contains(.authorization) else {
            return HTTP.Response(status: .unauthorized)
        }
        return try await inner.call(req)
    }
}

// Wrap an existing BoxService<HTTP.Request, HTTP.Response>:
let protected = authLayer.layer(boxed)
```

### `ServiceBuilder`

Composes layers into a pipeline at build time (the analogue of
`tower::ServiceBuilder`). Each `.layer(...)` is captured; `.service(_:)` folds
them outermost-first over the inner service, returning a single `BoxService`:

```swift
let svc = ServiceBuilder()          // Request/Response inferred from the first layer
    .layer(authLayer)
    .layer(loggingLayer)            // any Layer<HTTP.Request, HTTP.Response>
    .service(boxed)                 // → BoxService<HTTP.Request, HTTP.Response>
```

## Why a separate package?

`Service` and `Layer` are the composition primitives the whole framework is built
on, and they carry no I/O, no async runtime, no HTTP codec — just the trait and
the wrapper. Keeping them in their own package (as `tower` is in Rust) lets
`http-lens` (middleware), `starlight` (router/handlers), and any future gRPC/tonic
port share one set of abstractions without pulling in a server.

## License

MIT — see [LICENSE](LICENSE).
