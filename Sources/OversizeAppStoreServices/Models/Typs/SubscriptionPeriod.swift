//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionPeriod.swift, created on 02.02.2025
//

import Foundation

public enum SubscriptionPeriod: String, CaseIterable, Codable, Sendable, Identifiable {
    case oneWeek = "ONE_WEEK"
    case oneMonth = "ONE_MONTH"
    case twoMonths = "TWO_MONTHS"
    case threeMonths = "THREE_MONTHS"
    case sixMonths = "SIX_MONTHS"
    case oneYear = "ONE_YEAR"
    
    public var id: String {
        return rawValue
    }

    public var displayName: String {
        switch self {
        case .oneWeek:
            "1 Week"
        case .oneMonth:
            "1 Month"
        case .twoMonths:
            "2 Months"
        case .threeMonths:
            "3 Months"
        case .sixMonths:
            "6 Months"
        case .oneYear:
            "1 Year"
        }
    }
}
