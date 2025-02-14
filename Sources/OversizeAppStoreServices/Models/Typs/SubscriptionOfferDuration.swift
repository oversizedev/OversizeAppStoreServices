//
// Copyright © 2025 Alexander Romanov
// SubscriptionOfferDuration.swift, created on 05.02.2025
//

import Foundation

public enum SubscriptionOfferDuration: String, CaseIterable, Codable, Sendable, Identifiable {
    case threeDays = "THREE_DAYS"
    case oneWeek = "ONE_WEEK"
    case twoWeeks = "TWO_WEEKS"
    case oneMonth = "ONE_MONTH"
    case twoMonths = "TWO_MONTHS"
    case threeMonths = "THREE_MONTHS"
    case sixMonths = "SIX_MONTHS"
    case oneYear = "ONE_YEAR"

    public var displayName: String {
        switch self {
        case .threeDays: "3 Days"
        case .oneWeek: "1 Week"
        case .twoWeeks: "2 Weeks"
        case .oneMonth: "1 Month"
        case .twoMonths: "2 Months"
        case .threeMonths: "3 Months"
        case .sixMonths: "6 Months"
        case .oneYear: "1 Year"
        }
    }

    public var id: String {
        rawValue
    }
}
