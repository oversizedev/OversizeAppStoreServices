//
// Copyright © 2026 Alexander Romanov
// AppAssetLibraryServicesProtocol.swift, created on 25.10.2026
//

import AppStoreAPI
import Foundation

public protocol AppAssetLibraryServicesProtocol: Sendable {
    func fetchAssetLibraryId(appId: String, force: Bool) async -> Result<String, Error>
    func fetchRefData(placementType: AssetLibraryPlacementType, force: Bool) async -> Result<AssetLibraryRefData, Error>
    func fetchPlacements(
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        force: Bool,
    ) async -> Result<[AssetLibraryPlacement], Error>
    func fetchImage(id: String) async -> Result<AssetLibraryImage, Error>
    func uploadScreenshot(
        assetLibraryId: String,
        localizationId: String,
        placementGroup: String,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error>
    func uploadCreative(
        assetLibraryId: String,
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        placementGroup: String?,
        category: AssetLibraryAssetCategory,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error>
    func reorderPlacements(localizationId: String, placementGroup: String, placementIds: [String]) async -> Result<Void, Error>
    func deletePlacement(placementId: String, imageId: String?) async -> Result<Void, Error>
}

// MARK: - Default-argument convenience

public extension AppAssetLibraryServicesProtocol {
    func fetchAssetLibraryId(appId: String) async -> Result<String, Error> {
        await fetchAssetLibraryId(appId: appId, force: false)
    }

    func fetchRefData(placementType: AssetLibraryPlacementType) async -> Result<AssetLibraryRefData, Error> {
        await fetchRefData(placementType: placementType, force: false)
    }

    func fetchScreenshotRefData(force: Bool = false) async -> Result<AssetLibraryRefData, Error> {
        await fetchRefData(placementType: .appScreenshot, force: force)
    }

    func fetchPlacements(localizationId: String, placementType: AssetLibraryPlacementType) async -> Result<[AssetLibraryPlacement], Error> {
        await fetchPlacements(localizationId: localizationId, placementType: placementType, force: false)
    }

    func fetchScreenshotPlacements(localizationId: String, force: Bool = false) async -> Result<[AssetLibraryPlacement], Error> {
        await fetchPlacements(localizationId: localizationId, placementType: .appScreenshot, force: force)
    }

    func deleteScreenshot(placementId: String, imageId: String?) async -> Result<Void, Error> {
        await deletePlacement(placementId: placementId, imageId: imageId)
    }

    func uploadCreative(
        assetLibraryId: String,
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        await uploadCreative(
            assetLibraryId: assetLibraryId,
            localizationId: localizationId,
            placementType: placementType,
            placementGroup: nil,
            category: .creativeAssets,
            fileName: fileName,
            data: data,
        )
    }
}

extension AppAssetLibraryService: AppAssetLibraryServicesProtocol {}
