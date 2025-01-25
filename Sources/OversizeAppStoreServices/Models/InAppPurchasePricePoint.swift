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

    public init?(schema: AppStoreAPI.InAppPurchasePricePoint) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        customerPrice = attributes.customerPrice.valueOrEmpty
        proceeds = attributes.proceeds.valueOrEmpty
        relationships = .init(territoryId: schema.relationships?.territory?.data?.id)
    }

    public struct Relationships: Sendable {
        public let territoryId: String?
    }
}
