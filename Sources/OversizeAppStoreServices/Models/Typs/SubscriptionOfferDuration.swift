//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferDuration.swift, created on 05.02.2025
//

import Foundation

public enum SubscriptionOfferDuration: String, CaseIterable, Codable, Sendable {
    case threeDays = "THREE_DAYS"
    case oneWeek = "ONE_WEEK"
    case twoWeeks = "TWO_WEEKS"
    case oneMonth = "ONE_MONTH"
    case twoMonths = "TWO_MONTHS"
    case threeMonths = "THREE_MONTHS"
    case sixMonths = "SIX_MONTHS"
    case oneYear = "ONE_YEAR"
}
