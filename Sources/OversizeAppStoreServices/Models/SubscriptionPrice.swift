//
// Copyright © 2025 Alexander Romanov
// SubscriptionPrice.swift, created on 05.02.2025
//

import AppStoreAPI
import OversizeCore

public struct SubscriptionPrice: Sendable, Identifiable {
    public let id: String
    public var startDate: String?
    public var isPreserved: Bool?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.SubscriptionPrice, included: [AppStoreAPI.SubscriptionPricesResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        startDate = attributes.startDate
        isPreserved = attributes.isPreserved

        relationships = .init(
            subscriptionPricePointId: schema.relationships?.subscriptionPricePoint?.data?.id,
            territoryId: schema.relationships?.territory?.data?.id
        )

        if let includedItems = included {
            var subscriptionPricePoint: SubscriptionPricePoint?
            var territory: Territory?

            for includedItem in includedItems {
                switch includedItem {
                case let .subscriptionPricePoint(value):
                    if schema.relationships?.subscriptionPricePoint?.data?.id == value.id {
                        subscriptionPricePoint = .init(schema: value)
                    }
                case let .territory(value):
                    if schema.relationships?.territory?.data?.id == value.id {
                        territory = .init(schema: value)
                    }
                }
            }

            self.included = .init(
                subscriptionPricePoint: subscriptionPricePoint,
                territory: territory
            )
        } else {
            self.included
                = nil
        }
    }

    public struct Relationships: Sendable {
        public let subscriptionPricePointId: String?
        public let territoryId: String?
    }

    public struct Included: Sendable {
        public let subscriptionPricePoint: SubscriptionPricePoint?
        public let territory: Territory?
    }
}

extension SubscriptionPrice {
    static func from(response: AppStoreAPI.SubscriptionPricesResponse) -> [SubscriptionPrice] {
        response.data.compactMap { SubscriptionPrice(schema: $0, included: response.included) }
    }
}
