//
// Copyright © 2025 Aleksandr Romanov
// Territory.swift, created on 24.01.2025
//

import AppStoreAPI
import Foundation
import OversizeCore

public struct Territory: Sendable, Identifiable, Hashable {
    public let id: String
    public let currency: Locale.Currency
    public let region: TerritoryRegion
    public let code: TerritoryCode

    public init?(schema: AppStoreAPI.Territory) {
        guard let currency = schema.attributes?.currency,
              let territoryCode = TerritoryCode(rawValue: schema.id)
        else {
            return nil
        }

        id = schema.id
        self.currency = .init(currency)
        code = territoryCode
        region = TerritoryRegion(countryID: schema.id) ?? .unknown
    }

    public var displayName: String {
        code.displayName
    }

    public var displayFlag: String {
        code.flagEmoji
    }
}
