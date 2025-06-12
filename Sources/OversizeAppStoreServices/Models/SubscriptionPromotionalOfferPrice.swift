//
// Copyright © 2025 Alexander Romanov
// SubscriptionPromotionalOfferPrice.swift, created on 05.02.2025
//

import AppStoreAPI
import Foundation
import OversizeCore

public struct SubscriptionPromotionalOfferPrice: Sendable, Identifiable {
    public let id: String
    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.SubscriptionPromotionalOfferPrice, included: [SubscriptionPromotionalOfferPricesResponse.IncludedItem]? = nil) {
        id = schema.id

        relationships = Relationships(
            territoryId: schema.relationships?.territory?.data?.id,
            subscriptionPricePointId: schema.relationships?.subscriptionPricePoint?.data?.id,
        )

        self.included = .init(
            territory: included?.compactMap { item -> Territory? in
                if case let .territory(value) = item { return .init(schema: value) }
                return nil
            }.first,
            subscriptionPricePoint: included?.compactMap { item -> SubscriptionPricePoint? in
                if case let .subscriptionPricePoint(value) = item { return .init(schema: value) }
                return nil
            }.first,
        )
    }

    public struct Relationships: Sendable {
        public let territoryId: String?
        public let subscriptionPricePointId: String?

        public init(
            territoryId: String? = nil,
            subscriptionPricePointId: String? = nil
        ) {
            self.territoryId = territoryId
            self.subscriptionPricePointId = subscriptionPricePointId
        }
    }

    public struct Included: Sendable {
        public let territory: Territory?
        public let subscriptionPricePoint: SubscriptionPricePoint?

        public init(
            territory: Territory? = nil,
            subscriptionPricePoint: SubscriptionPricePoint? = nil
        ) {
            self.territory = territory
            self.subscriptionPricePoint = subscriptionPricePoint
        }
    }
}
