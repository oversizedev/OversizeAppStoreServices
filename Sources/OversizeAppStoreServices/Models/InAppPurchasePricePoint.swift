//
// Copyright © 2025 Aleksandr Romanov
// InAppPurchasePricePoint.swift, created on 17.01.2025
//

import AppStoreAPI
import OversizeCore

public struct InAppPurchasePricePoint: Identifiable, Sendable {
    public let id: String
    public let customerPrice: String
    public let proceeds: String
    public let relationships: Relationships
    public let included: Included?

    public init?(schema: AppStoreAPI.InAppPurchasePricePoint, included: [AppStoreAPI.Territory]? = nil) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        customerPrice = attributes.customerPrice.valueOrEmpty
        proceeds = attributes.proceeds.valueOrEmpty
        relationships = .init(territoryId: schema.relationships?.territory?.data?.id)

        if let territory = included?.first(where: { $0.id == schema.relationships?.territory?.data?.id }) {
            self.included = .init(territory: .init(schema: territory))
        } else {
            self.included = nil
        }
    }

    public struct Relationships: Sendable {
        public let territoryId: String?
    }

    public struct Included: Sendable {
        public let territory: Territory?
    }
}
