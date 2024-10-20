//
// Copyright © 2024 Alexander Romanov
// Platform.swift, created on 06.10.2024
//

import Foundation

public enum Platform: String, CaseIterable, Codable, Sendable {
    case ios = "IOS"
    case macOs = "MAC_OS"
    case tvOs = "TV_OS"
    case visionOs = "VISION_OS"
}
