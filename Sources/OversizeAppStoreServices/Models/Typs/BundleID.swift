//
// Copyright © 2024 Alexander Romanov
// BundleID.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect

public enum BundleID {
    public enum Platform {
        case iOS
        case macOS

        init(schema: AppStoreAPI.BundleIDPlatform) {
            self = schema == .iOS ? .iOS : .macOS
        }
    }
}
