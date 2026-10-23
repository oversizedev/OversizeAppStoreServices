// swift-tools-version: 6.1

import PackageDescription

let commonDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/aaronsky/asc-swift.git", .upToNextMajor(from: "1.8.0")),
    .package(url: "https://github.com/1024jp/GzipSwift", .upToNextMajor(from: "7.0.0")),
    .package(url: "https://github.com/dehesa/CodableCSV.git", .upToNextMajor(from: "0.6.7")),
    .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "4.0.0")),
]

let kitDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeCore.git", .upToNextMajor(from: "1.3.0")),
]

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
                .product(name: "OversizeCore", package: "OversizeCore"),
                .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux])),
            ],
        ),
        .target(
            name: "OversizeMetricServices",
            dependencies: [
                .product(name: "AppStoreConnect", package: "asc-swift"),
                .product(name: "Gzip", package: "GzipSwift"),
                .product(name: "CodableCSV", package: "CodableCSV"),
                .product(name: "FactoryKit", package: "Factory", condition: .when(platforms: applePlatforms)),
                .product(name: "OversizeCore", package: "OversizeCore"),
                "OversizeAppStoreServices",
            ],
        ),
        .testTarget(
            name: "OversizeAppStoreServicesTests",
            dependencies: ["OversizeAppStoreServices", "OversizeMetricServices"],
        ),
    ],
)
