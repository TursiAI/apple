// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Tursi",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "TursiCore", targets: ["TursiCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "TursiCore",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Tursi/Core"
        ),
        .testTarget(
            name: "TursiCoreTests",
            dependencies: ["TursiCore"],
            path: "Tests"
        ),
    ]
)
