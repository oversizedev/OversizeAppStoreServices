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

        self.included = .init(
            subscriptionPricePoint: included?.compactMap { (item: SubscriptionPricesResponse.IncludedItem) -> SubscriptionPricePoint? in
                if case let .subscriptionPricePoint(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first,
            territory: included?.compactMap { (item: SubscriptionPricesResponse.IncludedItem) -> Territory? in
                if case let .territory(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first
        )
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
