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
        owner: AssetLibraryPlacementOwner,
        placementType: AssetLibraryPlacementType,
        force: Bool,
    ) async -> Result<[AssetLibraryPlacement], Error>
    func fetchImage(id: String) async -> Result<AssetLibraryImage, Error>
    func uploadCreative(
        assetLibraryId: String,
        owner: AssetLibraryPlacementOwner,
        placementType: AssetLibraryPlacementType,
        placementGroup: String?,
        category: AssetLibraryAssetCategory,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error>
    func reorderPlacements(owner: AssetLibraryPlacementOwner, placementGroup: String, placementIds: [String]) async -> Result<Void, Error>
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

    func fetchPlacements(owner: AssetLibraryPlacementOwner, placementType: AssetLibraryPlacementType) async -> Result<[AssetLibraryPlacement], Error> {
        await fetchPlacements(owner: owner, placementType: placementType, force: false)
    }

    func fetchScreenshotPlacements(owner: AssetLibraryPlacementOwner, force: Bool = false) async -> Result<[AssetLibraryPlacement], Error> {
        await fetchPlacements(owner: owner, placementType: .appScreenshot, force: force)
    }

    func deleteScreenshot(placementId: String, imageId: String?) async -> Result<Void, Error> {
        await deletePlacement(placementId: placementId, imageId: imageId)
    }

    func uploadScreenshot(
        assetLibraryId: String,
        owner: AssetLibraryPlacementOwner,
        placementGroup: String,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        await uploadCreative(
            assetLibraryId: assetLibraryId,
            owner: owner,
            placementType: .appScreenshot,
            placementGroup: placementGroup,
            category: .appScreenshotsAndPreviews,
            fileName: fileName,
            data: data,
        )
    }
}

// MARK: - Version localization convenience

public extension AppAssetLibraryServicesProtocol {
    func fetchPlacements(
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        force: Bool = false,
    ) async -> Result<[AssetLibraryPlacement], Error> {
        await fetchPlacements(owner: .versionLocalization(localizationId), placementType: placementType, force: force)
    }

    func fetchScreenshotPlacements(localizationId: String, force: Bool = false) async -> Result<[AssetLibraryPlacement], Error> {
        await fetchPlacements(owner: .versionLocalization(localizationId), placementType: .appScreenshot, force: force)
    }

    func uploadScreenshot(
        assetLibraryId: String,
        localizationId: String,
        placementGroup: String,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        await uploadScreenshot(
            assetLibraryId: assetLibraryId,
            owner: .versionLocalization(localizationId),
            placementGroup: placementGroup,
            fileName: fileName,
            data: data,
        )
    }

    func uploadCreative(
        assetLibraryId: String,
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        placementGroup: String? = nil,
        category: AssetLibraryAssetCategory = .creativeAssets,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        await uploadCreative(
            assetLibraryId: assetLibraryId,
            owner: .versionLocalization(localizationId),
            placementType: placementType,
            placementGroup: placementGroup,
            category: category,
            fileName: fileName,
            data: data,
        )
    }

    func reorderPlacements(localizationId: String, placementGroup: String, placementIds: [String]) async -> Result<Void, Error> {
        await reorderPlacements(owner: .versionLocalization(localizationId), placementGroup: placementGroup, placementIds: placementIds)
    }
}

extension AppAssetLibraryService: AppAssetLibraryServicesProtocol {}
