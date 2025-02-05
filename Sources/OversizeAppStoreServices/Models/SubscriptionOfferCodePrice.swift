//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferCodePrice.swift, created on 05.02.2025
//

import AppStoreAPI
import Foundation

public struct SubscriptionOfferCodePrice: Identifiable, Sendable {
    public let id: String
    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.SubscriptionOfferCodePrice, included: [AppStoreAPI.SubscriptionOfferCodePricesResponse.IncludedItem]? = nil) {
        id = schema.id
        relationships = .init(
            territoryId: schema.relationships?.territory?.data?.id,
            subscriptionPricePointId: schema.relationships?.subscriptionPricePoint?.data?.id
        )

        var territories: [AppStoreAPI.Territory] = []
        var subscriptionPricePoints: [AppStoreAPI.SubscriptionPricePoint] = []

        if let includedItems = included {
            for includedItem in includedItems {
                switch includedItem {
                case let .territory(territory):
                    if schema.relationships?.territory?.data?.id == territory.id {
                        territories.append(territory)
                    }
                case let .subscriptionPricePoint(subscriptionPricePoint):
                    if schema.relationships?.subscriptionPricePoint?.data?.id == subscriptionPricePoint.id {
                        subscriptionPricePoints.append(subscriptionPricePoint)
                    }
                }
            }

            self.included = .init(
                territory: territories.first.flatMap { .init(schema: $0) },
                subscriptionPricePoint: subscriptionPricePoints.first.flatMap { .init(schema: $0) }
            )
        } else {
            self.included = nil
        }
    }

    public struct Relationships: Sendable {
        public let territoryId: String?
        public let subscriptionPricePointId: String?
    }

    public struct Included: Sendable {
        public let territory: Territory?
        public let subscriptionPricePoint: SubscriptionPricePoint?
    }
}
