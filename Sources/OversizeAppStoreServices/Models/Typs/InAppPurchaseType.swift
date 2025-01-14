//
// Copyright © 2025 Aleksandr Romanov
// InAppPurchaseType.swift, created on 02.01.2025
//

import Foundation

public enum InAppPurchaseType: String, CaseIterable, Codable, Sendable {
    case consumable = "CONSUMABLE"
    case nonConsumable = "NON_CONSUMABLE"
    case nonRenewingSubscription = "NON_RENEWING_SUBSCRIPTION"
    
    public var displayName: String {
        switch self {
        case .consumable:
            "Consumable"
        case .nonConsumable:
            "Non-Consumable"
        case .nonRenewingSubscription:
            "Non-Renewing Subscription"
        }
    }
}
