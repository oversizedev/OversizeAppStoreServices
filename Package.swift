// swift-tools-version: 6.1

import Foundation
import PackageDescription

let commonDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/aaronsky/asc-swift.git", .upToNextMajor(from: "1.5.0")),
    .package(url: "https://github.com/1024jp/GzipSwift", .upToNextMajor(from: "6.1.0")),
    .package(url: "https://github.com/dehesa/CodableCSV.git", .upToNextMajor(from: "0.6.7")),
]

let remoteKitDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
]

let localKitDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "3.0.2")),
    .package(name: "OversizeCore", path: "../OversizeCore"),
    .package(name: "OversizeServices", path: "../OversizeServices"),
]

let isLocalDev = FileManager.default.fileExists(atPath: "\(NSHomeDirectory())/Developer/Packages/OversizeCore")
let kitDependencies: [PackageDescription.Package.Dependency] = isLocalDev ? localKitDependencies : remoteKitDependencies
let dependencies: [PackageDescription.Package.Dependency] = commonDependencies + kitDependencies

let applePlatforms: [PackageDescription.Platform] = [.iOS, .macOS, .tvOS, .watchOS, .visionOS, .macCatalyst]

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
                .product(name: "FactoryKit", package: "Factory", condition: .when(platforms: applePlatforms)),
                .product(name: "OversizeCore", package: "OversizeCore", condition: .when(platforms: applePlatforms)),
                .product(name: "OversizeServices", package: "OversizeServices", condition: .when(platforms: applePlatforms)),
            ],
        ),
        .target(
            name: "OversizeMetricServices",
            dependencies: [
                .product(name: "AppStoreConnect", package: "asc-swift"),
                .product(name: "Gzip", package: "GzipSwift"),
                .product(name: "CodableCSV", package: "CodableCSV"),
                .product(name: "FactoryKit", package: "Factory", condition: .when(platforms: applePlatforms)),
                "OversizeAppStoreServices",
            ],
        ),
        .testTarget(
            name: "OversizeAppStoreServicesTests",
            dependencies: ["OversizeAppStoreServices", "OversizeMetricServices"],
        ),
    ],
)
