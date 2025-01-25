//
// Copyright © 2025 Aleksandr Romanov
// InAppPurchaseAvailability.swift, created on 24.01.2025
//

import AppStoreAPI
import OversizeCore

public struct InAppPurchaseAvailability: Sendable {
    public let id: String
    public let isAvailableInNewTerritories: Bool

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.InAppPurchaseAvailability, included: [AppStoreAPI.Territory]? = nil) {
        guard let isAvailableInNewTerritories = schema.attributes?.isAvailableInNewTerritories else { return nil }
        id = schema.id
        self.isAvailableInNewTerritories = isAvailableInNewTerritories

        if let availableTerritoriesIds = schema.relationships?.availableTerritories?.data {
            relationships = .init(availableTerritoriesIds: availableTerritoriesIds.compactMap { $0.id })

        } else {
            relationships = nil
        }

        if let included {
            self.included = .init(territories: included.compactMap { .init(schema: $0) })
        } else {
            self.included = nil
        }
    }

    public struct Relationships: Sendable {
        public var availableTerritoriesIds: [String]?
    }

    public struct Included: Sendable {
        public let territories: [Territory]?
    }
}
