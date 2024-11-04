//
// Copyright © 2024 Alexander Romanov
// ReleaseType.swift, created on 04.11.2024
//

import Foundation

public enum ReleaseType: String, CaseIterable, Codable, Sendable, Identifiable {
    case manual = "MANUAL"
    case afterApproval = "AFTER_APPROVAL"
    case scheduled = "SCHEDULED"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .manual:
            return "Manually release this version"
        case .afterApproval:
            return "Automatically release this version"
        case .scheduled:
            return "Automatically release this version after App Review, no earlier than"
        }
    }
}
