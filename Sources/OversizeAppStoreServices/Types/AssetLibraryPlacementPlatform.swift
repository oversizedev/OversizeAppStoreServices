//
// Copyright © 2026 Alexander Romanov
// AssetLibraryPlacementPlatform.swift, created on 23.10.2026
//

import AppStoreAPI

public enum AssetLibraryPlacementPlatform: String, CaseIterable, Codable, Sendable {
    case iPhone = "IPHONE_APP_STORE"
    case iPad = "IPAD_APP_STORE"
    case watch = "WATCH_APP_STORE"
    case iMessage = "IMESSAGE_APP_STORE"
    case visionPro = "VISION_PRO_APP_STORE"
    case mac = "MAC_APP_STORE"
    case tv = "TV_APP_STORE"
    case any = "ANY"

    public init?(schema: AppStoreAPI.AppAssetLibraryPlacementPlatform) {
        self.init(rawValue: schema.rawValue)
    }
}
