//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionPeriod.swift, created on 02.02.2025
//

import Foundation

public enum SubscriptionPeriod: String, CaseIterable, Codable, Sendable {
    case oneWeek = "ONE_WEEK"
    case oneMonth = "ONE_MONTH"
    case twoMonths = "TWO_MONTHS"
    case threeMonths = "THREE_MONTHS"
    case sixMonths = "SIX_MONTHS"
    case oneYear = "ONE_YEAR"

    public var displayName: String {
        switch self {
        case .oneWeek:
            "One Week"
        case .oneMonth:
            "One Month"
        case .twoMonths:
            "Two Months"
        case .threeMonths:
            "Three Months"
        case .sixMonths:
            "Six Months"
        case .oneYear:
            "One Year"
        }
    }
}
