//
// Copyright © 2025 Alexander Romanov
// SubscriptionPromotionalOffer.swift, created on 05.02.2025
//

import AppStoreAPI
import Foundation
import OversizeCore

public struct SubscriptionPromotionalOffer: Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let offerCode: String?
    public let duration: SubscriptionOfferDuration?
    public let offerMode: SubscriptionOfferMode?
    public let numberOfPeriods: Int?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.SubscriptionPromotionalOffer, included: [SubscriptionPromotionalOfferResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes else { return nil }

        id = schema.id
        name = attributes.name
        offerCode = attributes.offerCode

        duration = .init(rawValue: attributes.duration?.rawValue ?? "")
        offerMode = .init(rawValue: attributes.offerMode?.rawValue ?? "")

        numberOfPeriods = attributes.numberOfPeriods

        relationships = Relationships(
            subscriptionId: schema.relationships?.subscription?.data?.id,
            pricesIds: schema.relationships?.prices?.data?.map { $0.id }
        )

        self.included = .init(
            subscription: included?.compactMap { (item: SubscriptionPromotionalOfferResponse.IncludedItem) -> Subscription? in
                if case let .subscription(value) = item { return .init(schema: value) }
                return nil
            }.first,
            subscriptionPromotionalOfferPrices: included?.compactMap { (item: SubscriptionPromotionalOfferResponse.IncludedItem) -> SubscriptionPromotionalOfferPrice? in
                if case let .subscriptionPromotionalOfferPrice(value) = item { return .init(schema: value) }
                return nil
            }
        )
    }

    public struct Relationships: Sendable {
        public var subscriptionId: String?
        public var pricesIds: [String]?

        public init(
            subscriptionId: String? = nil,
            pricesIds: [String]? = nil
        ) {
            self.subscriptionId = subscriptionId
            self.pricesIds = pricesIds
        }
    }

    public struct Included: Sendable {
        public let subscription: Subscription?
        public let subscriptionPromotionalOfferPrices: [SubscriptionPromotionalOfferPrice]?

        public init(
            subscription: Subscription? = nil,
            subscriptionPromotionalOfferPrices: [SubscriptionPromotionalOfferPrice]? = nil
        ) {
            self.subscription = subscription
            self.subscriptionPromotionalOfferPrices = subscriptionPromotionalOfferPrices
        }
    }
}
