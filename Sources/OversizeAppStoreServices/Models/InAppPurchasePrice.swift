//
// Copyright © 2025 Alexander Romanov
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
            territoryId: schema.relationships?.territory?.data?.id,
        )

        if let includedItems = included {
            var inAppPurchasePricePoint: InAppPurchasePricePoint?
            var territory: Territory?

            for includedItem in includedItems {
                switch includedItem {
                case let .inAppPurchasePricePoint(value):
                    if schema.relationships?.inAppPurchasePricePoint?.data?.id == value.id {
                        inAppPurchasePricePoint = .init(schema: value)
                    }
                case let .territory(value):
                    if schema.relationships?.territory?.data?.id == value.id {
                        territory = .init(schema: value)
                    }
                }
            }
            self.included = .init(
                inAppPurchasePricePoint: inAppPurchasePricePoint,
                territory: territory,
            )
        } else {
            self.included = nil
        }
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
