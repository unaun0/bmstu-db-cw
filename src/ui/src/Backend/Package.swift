// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            from: "2.8.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🔐 JWT for autentification
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        // 👩🏻‍💻 VaporOpenAPI for TechUI
        .package(
            url: "https://github.com/dankinsoid/VaporToOpenAPI.git",
            from: "4.8.1"
        ),
        // 🥭 MongoDB
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),


    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .target(name: "Domain"),
                .target(name: "DataAccess"),
                .target(name: "API"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "VaporToOpenAPI", package: "VaporToOpenAPI"),
                .product(name: "Fluent", package: "fluent"),
                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                ),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "API",
            dependencies: [
                .target(name: "Domain"),
                .product(name: "VaporToOpenAPI", package: "VaporToOpenAPI"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
            ]
        ),
        .target(
            name: "DataAccess",
            dependencies: [
                .target(name: "Domain"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                ),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .target(name: "DataAccess"),
                .target(name: "Domain"),
                .target(name: "API"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("DisableOutwardActorInference"),
        .enableExperimentalFeature("StrictConcurrency"),
    ]
}
