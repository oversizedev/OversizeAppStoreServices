//
// Copyright © 2025 Alexander Romanov
// InAppPurchasePriceSchedule.swift, created on 17.01.2025
//

import AppStoreAPI
import Foundation

public struct InAppPurchasePriceSchedule: Identifiable, Sendable {
    public let id: String

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.InAppPurchasePriceSchedule, included: [AppStoreAPI.InAppPurchasePriceScheduleResponse.IncludedItem]? = nil) {
        id = schema.id

        relationships = .init(
            baseTerritoryId: schema.relationships?.baseTerritory?.data?.id,
            manualPriceIds: schema.relationships?.manualPrices?.data?.map { $0.id },
            automaticPriceIds: schema.relationships?.automaticPrices?.data?.map { $0.id }
        )

        self.included = .init(
            baseTerritory: included?.compactMap { (item: InAppPurchasePriceScheduleResponse.IncludedItem) -> Territory? in
                if case let .territory(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first,
            inAppPurchasePrices: included?.compactMap {
                if case let .inAppPurchasePrice(value) = $0 { return .init(schema: value) }
                return nil
            }
        )
    }

    public struct Relationships: Sendable {
        public let baseTerritoryId: String?
        public let manualPriceIds: [String]?
        public let automaticPriceIds: [String]?
    }

    public struct Included: Sendable {
        public let baseTerritory: Territory?
        public let inAppPurchasePrices: [InAppPurchasePrice]?
    }
}
