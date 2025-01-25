//
// Copyright © 2025 Aleksandr Romanov
// Territory.swift, created on 24.01.2025
//

import AppStoreAPI
import AppStoreConnect
import OversizeCore

public struct Territory: Sendable {
    public let id: String
    public let currency: String

    public init?(schema: AppStoreAPI.Territory) {
        guard let currency = schema.attributes?.currency else { return nil }
        id = schema.id
        self.currency = currency
    }
}
