//
// Copyright © 2026 Alexander Romanov
// AssetLibraryAssetCategory.swift, created on 25.10.2026
//

import AppStoreAPI

public enum AssetLibraryAssetCategory: String, CaseIterable, Codable, Sendable {
    case creativeAssets = "CREATIVE_ASSETS"
    case appScreenshotsAndPreviews = "APP_SCREENSHOTS_AND_PREVIEWS"

    public init?(schema: AppStoreAPI.AppAssetLibraryAssetCategory) {
        self.init(rawValue: schema.rawValue)
    }

    var schema: AppStoreAPI.AppAssetLibraryAssetCategory {
        switch self {
        case .creativeAssets: .creativeAssets
        case .appScreenshotsAndPreviews: .appScreenshotsAndPreviews
        }
    }
}
