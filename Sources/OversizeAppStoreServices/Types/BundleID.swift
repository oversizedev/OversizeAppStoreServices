//
// Copyright © 2024 Alexander Romanov
// BundleID.swift, created on 23.07.2024
//

import AppStoreAPI

public enum BundleIDPlatform: String, CaseIterable, Codable, Sendable {
    case iOS = "IOS"
    case macOS = "MAC_OS"
    case universal = "UNIVERSAL"
}
