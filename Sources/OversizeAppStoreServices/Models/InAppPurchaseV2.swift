//
// Copyright © 2025 Aleksandr Romanov
// InAppPurchaseV2.swift, created on 02.01.2025
//

import AppStoreAPI
import Foundation

public struct InAppPurchaseV2: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let productID: String
    public let inAppPurchaseType: InAppPurchaseType
    public let state: InAppPurchaseState
    public let isFamilySharable: Bool?
    public let isContentHosting: Bool?

    public init?(schema: AppStoreAPI.InAppPurchaseV2) {
        guard let attributes = schema.attributes,
              let name = attributes.name,
              let productID = attributes.productID,
              let inAppPurchaseTypeRaw = attributes.inAppPurchaseType,
              let inAppPurchaseType: InAppPurchaseType = .init(rawValue: inAppPurchaseTypeRaw.rawValue),
              let stateRaw = attributes.state,
              let state: InAppPurchaseState = .init(rawValue: stateRaw.rawValue)
        else { return nil }
        id = schema.id
        self.name = name
        self.productID = productID
        self.inAppPurchaseType = inAppPurchaseType
        self.state = state
        isFamilySharable = schema.attributes?.isFamilySharable
        isContentHosting = schema.attributes?.isContentHosting
    }
}
