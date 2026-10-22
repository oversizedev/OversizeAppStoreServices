//
// Copyright © 2025 Alexander Romanov
// SubscriptionGroup.swift, created on 12.01.2025
//

import AppStoreAPI
import Foundation

public struct SubscriptionGroup: Identifiable, Sendable {
    public let id: String
    public let referenceName: String

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.SubscriptionGroup, included: [AppStoreAPI.SubscriptionGroupsResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes
        else { return nil }
        id = schema.id
        referenceName = attributes.referenceName.valueOrEmpty

        relationships = .init(
            subscriptionsIds: schema.relationships?.subscriptions?.data?.compactMap { $0.id } ?? [],
            subscriptionGroupLocalizationsIds: schema.relationships?.subscriptionGroupLocalizations?.data?.compactMap { $0.id } ?? [],
            versionsIds: schema.relationships?.versions?.data?.compactMap { $0.id } ?? [],
        )

        var subscriptions: [AppStoreAPI.Subscription] = []
        var subscriptionGroupLocalizations: [AppStoreAPI.SubscriptionGroupLocalization] = []
        var versions: [AppStoreAPI.SubscriptionGroupVersion] = []

        if let includedItems = included {
            for includedItem in includedItems {
                switch includedItem {
                case let .subscription(subscription):
                    if schema.relationships?.subscriptions?.data?.first(where: { $0.id == subscription.id }) != nil {
                        subscriptions.append(subscription)
                    }
                case let .subscriptionGroupLocalization(subscriptionGroupLocalization):
                    if schema.relationships?.subscriptionGroupLocalizations?.data?.first(where: { $0.id == subscriptionGroupLocalization.id }) != nil {
                        subscriptionGroupLocalizations.append(subscriptionGroupLocalization)
                    }
                case let .subscriptionGroupVersion(version):
                    if schema.relationships?.versions?.data?.first(where: { $0.id == version.id }) != nil {
                        versions.append(version)
                    }
                @unknown default:
                    break
                }
            }

            self.included = .init(
                subscriptions: subscriptions.compactMap { .init(schema: $0) },
                subscriptionGroupLocalizations: subscriptionGroupLocalizations.compactMap { .init(schema: $0) },
                versions: versions.compactMap { .init(schema: $0) },
            )
        } else {
            self.included = nil
        }
    }

    public struct Relationships: Sendable {
        public let subscriptionsIds: [String]
        public let subscriptionGroupLocalizationsIds: [String]
        public let versionsIds: [String]
    }

    public struct Included: Sendable {
        public let subscriptions: [Subscription]?
        public let subscriptionGroupLocalizations: [SubscriptionGroupLocalization]?
        public let versions: [SubscriptionGroupVersion]?
    }
}
