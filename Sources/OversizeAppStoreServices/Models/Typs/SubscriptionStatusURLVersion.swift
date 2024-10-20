//
// Copyright © 2024 Alexander Romanov
// SubscriptionStatusURLVersion.swift, created on 28.08.2024
//

import Foundation

public enum SubscriptionStatusURLVersion: String, CaseIterable, Codable, Sendable {
    case v1 = "V1"
    case v2 = "V2"
    case v12 = "v1"
    case v22 = "v2"
}
