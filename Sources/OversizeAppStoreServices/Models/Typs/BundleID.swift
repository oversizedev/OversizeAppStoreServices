//
// Copyright © 2024 Alexander Romanov
// BundleID.swift, created on 23.07.2024
//

import AppStoreAPI

public enum BundleID: Sendable {
    public enum Platform: Sendable {
        case iOS
        case macOS

        init(schema: AppStoreAPI.BundleIDPlatform) {
            self = schema == .iOS ? .iOS : .macOS
        }
    }
}
