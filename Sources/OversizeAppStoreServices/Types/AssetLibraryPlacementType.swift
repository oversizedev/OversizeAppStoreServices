//
// Copyright © 2026 Alexander Romanov
// AssetLibraryPlacementType.swift, created on 25.10.2026
//

import AppStoreAPI

public enum AssetLibraryPlacementType: String, CaseIterable, Codable, Sendable {
    case appScreenshot = "APP_SCREENSHOT"
    case imessageAppScreenshot = "IMESSAGE_APP_SCREENSHOT"
    case appPreview = "APP_PREVIEW"
    case productPageHeaderAsset = "PRODUCT_PAGE_HEADER_ASSET"
    case appStoreSearchResultsAsset = "APP_STORE_SEARCH_RESULTS_ASSET"
    case searchResultsAdsAsset = "SEARCH_RESULTS_ADS_ASSET"
    case todayTabAdsAsset = "TODAY_TAB_ADS_ASSET"
    case eventCardAsset = "EVENT_CARD_ASSET"
    case eventDetailsPageAsset = "EVENT_DETAILS_PAGE_ASSET"
    case retentionMessageAsset = "RETENTION_MESSAGE_ASSET"

    public init?(schema: AppStoreAPI.AppAssetLibraryPlacementType) {
        self.init(rawValue: schema.rawValue)
    }
}
