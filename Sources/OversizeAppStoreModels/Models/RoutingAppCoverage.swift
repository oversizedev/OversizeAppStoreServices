//
// Copyright © 2024 Alexander Romanov
// RoutingAppCoverage.swift, created on 23.04.2026
//

import AppStoreAPI

public struct RoutingAppCoverage: Sendable, Identifiable {
    public let id: String
    public let fileSize: Int?
    public let fileName: String?
    public let sourceFileChecksum: String?
    public let assetDeliveryState: AppMediaAssetState?

    public init?(schema: AppStoreAPI.RoutingAppCoverage) {
        id = schema.id
        fileSize = schema.attributes?.fileSize
        fileName = schema.attributes?.fileName
        sourceFileChecksum = schema.attributes?.sourceFileChecksum
        assetDeliveryState = schema.attributes?.assetDeliveryState.flatMap { .init(schema: $0) }
    }
}
