// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let remoteDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/aaronsky/asc-swift.git", .upToNextMajor(from: "0.6.1")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeModels.git", .upToNextMajor(from: "0.1.0")),
]

let localDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/aaronsky/asc-swift.git", .upToNextMajor(from: "0.6.1")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeModels.git", .upToNextMajor(from: "0.1.0")),
]

var dependencies: [PackageDescription.Package.Dependency] = []

if let environmentValue = ProcessInfo.processInfo.environment["PRODUCTION"], environmentValue == "true" {
    dependencies = remoteDependencies
} else {
    dependencies = localDependencies
}

let package = Package(
    name: "OversizeAppStoreServices",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "OversizeAppStoreServices",
            targets: ["OversizeAppStoreServices"]
        ),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeAppStoreServices",
            dependencies: [
                .product(name: "AppStoreConnect", package: "asc-swift"),
                .product(name: "Factory", package: "Factory"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "OversizeServices", package: "OversizeServices"),
            ]
        ),
        .testTarget(
            name: "OversizeAppStoreServicesTests",
            dependencies: ["OversizeAppStoreServices"]
        ),
    ]
)
