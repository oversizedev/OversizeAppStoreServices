//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferMode.swift, created on 02.02.2025
//

import Foundation

public enum SubscriptionOfferMode: String, CaseIterable, Codable, Sendable {
    case payAsYouGo = "PAY_AS_YOU_GO"
    case payUpFront = "PAY_UP_FRONT"
    case freeTrial = "FREE_TRIAL"
}
