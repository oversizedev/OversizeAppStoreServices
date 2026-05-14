// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let commonDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/aaronsky/asc-swift.git", .upToNextMajor(from: "1.5.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/1024jp/GzipSwift", .upToNextMajor(from: "6.1.0")),
    .package(url: "https://github.com/dehesa/CodableCSV.git", .upToNextMajor(from: "0.6.7")),
]

let remoteDependencies: [PackageDescription.Package.Dependency] = commonDependencies + [
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
]

let localDependencies: [PackageDescription.Package.Dependency] = commonDependencies + [
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeServices", path: "../OversizeServices"),
]

let isLocalDev = FileManager.default.fileExists(atPath: "\(NSHomeDirectory())/Developer/Packages/OversizeCore")
let dependencies: [PackageDescription.Package.Dependency] = isLocalDev ? localDependencies : remoteDependencies

let package = Package(
    name: "OversizeAppStoreServices",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "OversizeAppStoreModels",
            targets: ["OversizeAppStoreModels"],
        ),
        .library(
            name: "OversizeAppStoreServices",
            targets: ["OversizeAppStoreServices"],
        ),
        .library(
            name: "OversizeMetricServices",
            targets: ["OversizeMetricServices"],
        ),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeAppStoreServices",
            dependencies: [
                .product(name: "AppStoreConnect", package: "asc-swift"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "OversizeServices", package: "OversizeServices"),
                "OversizeAppStoreModels",
            ],
        ),
        .target(
            name: "OversizeMetricServices",
            dependencies: [
                .product(name: "AppStoreConnect", package: "asc-swift"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Gzip", package: "GzipSwift"),
                .product(name: "CodableCSV", package: "CodableCSV"),
                "OversizeAppStoreServices",
            ],
        ),
        .target(
            name: "OversizeAppStoreModels",
            dependencies: [
                .product(name: "AppStoreConnect", package: "asc-swift"),
                .product(name: "OversizeCore", package: "OversizeCore"),
            ],
        ),
        .testTarget(
            name: "OversizeAppStoreServicesTests",
            dependencies: ["OversizeAppStoreServices", "OversizeMetricServices"],
        ),
    ],
)
