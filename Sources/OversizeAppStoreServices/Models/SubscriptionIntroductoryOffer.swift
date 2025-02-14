//
// Copyright © 2025 Alexander Romanov
// SubscriptionIntroductoryOffer.swift, created on 05.02.2025
//

import AppStoreAPI
import Foundation
import OversizeCore

public struct SubscriptionIntroductoryOffer: Sendable, Identifiable {
    public let id: String
    public let startDate: Date?
    public let endDate: Date?
    public let duration: SubscriptionOfferDuration?
    public let offerMode: SubscriptionOfferMode?
    public let numberOfPeriods: Int?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.SubscriptionIntroductoryOffer, included: [SubscriptionIntroductoryOffersResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes else { return nil }

        id = schema.id

        startDate = attributes.startDate.valueOrEmpty.toDate()
        endDate = attributes.endDate.valueOrEmpty.toDate()
        duration = .init(rawValue: attributes.duration?.rawValue ?? "")
        offerMode = .init(rawValue: attributes.offerMode?.rawValue ?? "")
        numberOfPeriods = attributes.numberOfPeriods

        relationships = Relationships(
            subscriptionId: schema.relationships?.subscription?.data?.id,
            territoryId: schema.relationships?.territory?.data?.id,
            subscriptionPricePointId: schema.relationships?.subscriptionPricePoint?.data?.id
        )

        self.included = .init(
            subscription: included?.compactMap { item -> Subscription? in
                if case let .subscription(value) = item { return .init(schema: value) }
                return nil
            }.first,
            territory: included?.compactMap { item -> Territory? in
                if case let .territory(value) = item { return .init(schema: value) }
                return nil
            }.first,
            subscriptionPricePoint: included?.compactMap { item -> SubscriptionPricePoint? in
                if case let .subscriptionPricePoint(value) = item { return .init(schema: value) }
                return nil
            }.first
        )
    }

    public struct Relationships: Sendable {
        public let subscriptionId: String?
        public let territoryId: String?
        public let subscriptionPricePointId: String?

        public init(
            subscriptionId: String? = nil,
            territoryId: String? = nil,
            subscriptionPricePointId: String? = nil
        ) {
            self.subscriptionId = subscriptionId
            self.territoryId = territoryId
            self.subscriptionPricePointId = subscriptionPricePointId
        }
    }

    public struct Included: Sendable {
        public let subscription: Subscription?
        public let territory: Territory?
        public let subscriptionPricePoint: SubscriptionPricePoint?

        public init(
            subscription: Subscription? = nil,
            territory: Territory? = nil,
            subscriptionPricePoint: SubscriptionPricePoint? = nil
        ) {
            self.subscription = subscription
            self.territory = territory
            self.subscriptionPricePoint = subscriptionPricePoint
        }
    }
}

extension SubscriptionIntroductoryOffer {
    static func from(response: AppStoreAPI.SubscriptionIntroductoryOffersResponse) -> [SubscriptionIntroductoryOffer] {
        response.data.compactMap { SubscriptionIntroductoryOffer(schema: $0, included: response.included) }
    }
}
