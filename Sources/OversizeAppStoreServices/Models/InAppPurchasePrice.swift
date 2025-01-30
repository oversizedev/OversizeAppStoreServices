//
// Copyright © 2025 Aleksandr Romanov
// InAppPurchasePrice.swift, created on 29.01.2025
//

import AppStoreAPI
import OversizeCore

public struct InAppPurchasePrice: Sendable, Identifiable {
    public let id: String
    public var startDate: String?
    public var endDate: String?
    public var isManual: Bool?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.InAppPurchasePrice, included: [AppStoreAPI.InAppPurchasePricesResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        startDate = attributes.startDate
        endDate = attributes.endDate
        isManual = attributes.isManual

        relationships = .init(
            inAppPurchasePricePointId: schema.relationships?.inAppPurchasePricePoint?.data?.id,
            territoryId: schema.relationships?.territory?.data?.id
        )

        self.included = .init(
            inAppPurchasePricePoint: included?.compactMap { (item: InAppPurchasePricesResponse.IncludedItem) -> InAppPurchasePricePoint? in
                if case let .inAppPurchasePricePoint(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first,
            territory: included?.compactMap { (item: InAppPurchasePricesResponse.IncludedItem) -> Territory? in
                if case let .territory(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first
        )
    }

    public struct Relationships: Sendable {
        public let inAppPurchasePricePointId: String?
        public let territoryId: String?
    }

    public struct Included: Sendable {
        public let inAppPurchasePricePoint: InAppPurchasePricePoint?
        public let territory: Territory?
    }
}
