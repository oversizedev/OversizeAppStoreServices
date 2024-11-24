//
// Copyright © 2024 Alexander Romanov
// Platform.swift, created on 06.10.2024
//

import Foundation
import SwiftUI

public enum Platform: String, CaseIterable, Codable, Sendable, Identifiable {
    case ios = "IOS"
    case macOs = "MAC_OS"
    case tvOs = "TV_OS"
    case visionOs = "VISION_OS"

    // Computed property for display name
    public var displayName: String {
        switch self {
        case .ios:
            "iOS"
        case .macOs:
            "macOS"
        case .tvOs:
            "tvOS"
        case .visionOs:
            "visionOS"
        }
    }

    // Computed property for icon
    public var icon: Image {
        switch self {
        case .ios:
            Image(systemName: "iphone")
        case .macOs:
            Image(systemName: "laptopcomputer")
        case .tvOs:
            Image(systemName: "appletv.fill")
        case .visionOs:
            Image(systemName: "vision.pro")
        }
    }

    public var id: String { rawValue }
}
