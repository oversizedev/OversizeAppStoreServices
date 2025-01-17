//
// Copyright © 2025 Aleksandr Romanov
// InAppPurchasePriceSchedule.swift, created on 17.01.2025
//

import AppStoreAPI
import Foundation

public struct InAppPurchasePriceSchedule: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let baseTerritoryId: String?
    public let manualPriceIds: [String]?
    public let automaticPriceIds: [String]?

    public init?(schema: AppStoreAPI.InAppPurchasePriceSchedule) {
        id = schema.id
        baseTerritoryId = schema.relationships?.baseTerritory?.data?.id
        manualPriceIds = schema.relationships?.manualPrices?.data?.map { $0.id }
        automaticPriceIds = schema.relationships?.automaticPrices?.data?.map { $0.id }
    }
}
