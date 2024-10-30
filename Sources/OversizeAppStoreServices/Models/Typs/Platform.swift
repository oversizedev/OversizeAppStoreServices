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
            return "iOS"
        case .macOs:
            return "macOS"
        case .tvOs:
            return "tvOS"
        case .visionOs:
            return "visionOS"
        }
    }

    // Computed property for icon
    public var icon: Image {
        switch self {
        case .ios:
            return Image(systemName: "iphone")
        case .macOs:
            return Image(systemName: "laptopcomputer")
        case .tvOs:
            return Image(systemName: "appletv.fill")
        case .visionOs:
            return Image(systemName: "vision.pro")
        }
    }

    private var title: String {
        switch self {
        case .ios:
            return "iOS"
        case .macOs:
            return "macOS"
        case .tvOs:
            return "tvOS"
        case .visionOs:
            return "visionOS"
        }
    }

    public var id: String { rawValue }
}
