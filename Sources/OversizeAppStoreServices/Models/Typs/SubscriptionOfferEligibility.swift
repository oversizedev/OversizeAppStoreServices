//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferEligibility.swift, created on 05.02.2025
//

import Foundation

public enum SubscriptionOfferEligibility: String, CaseIterable, Codable, Sendable {
    case stackWithIntroOffers = "STACK_WITH_INTRO_OFFERS"
    case replaceIntroOffers = "REPLACE_INTRO_OFFERS"
}
