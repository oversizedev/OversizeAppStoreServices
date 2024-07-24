//
// Copyright © 2024 Alexander Romanov
// BundleID.swift, created on 23.07.2024
//

import AppStoreConnect

public enum BundleID {
    public enum Platform {
        case ios
        case macOS

        init(schema: AppStoreConnect.BundleIDPlatform) {
            self = schema == .ios ? .ios : .macOS
        }
    }
}
