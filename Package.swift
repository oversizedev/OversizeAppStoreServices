// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OversizeAppStoreConnectServices",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "OversizeAppStoreConnectServices",
            targets: ["OversizeAppStoreConnectServices"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/aaronsky/asc-swift.git", .upToNextMajor(from: "0.6.1")),
        .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
        .package(name: "OversizeModels", path: "../OversizeModels"),
        .package(name: "OversizeServices", path: "../OversizeLibrary/OversizeServices"),
    ],
    targets: [
        .target(
            name: "OversizeAppStoreConnectServices",
            dependencies: [
                .product(name: "AppStoreConnect", package: "asc-swift"),
                .product(name: "Factory", package: "Factory"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "OversizeServices", package: "OversizeServices"),
            ]
        ),
        .testTarget(
            name: "OversizeAppStoreConnectServicesTests",
            dependencies: ["OversizeAppStoreConnectServices"]
        ),
    ]
)
