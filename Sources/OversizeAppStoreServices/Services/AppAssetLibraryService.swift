//
// Copyright © 2026 Alexander Romanov
// AppAssetLibraryService.swift, created on 23.10.2026
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public actor AppAssetLibraryService {
    private let client: AppStoreConnectClient

    private static let pollAttempts = 60
    private static let pollInterval: Duration = .seconds(1)

    public init(authenticator: some AppStoreConnect.Authenticator, cacheAccountID: String? = nil) {
        client = ASCClientFactory.makeClient(authenticator: authenticator, cacheAccountID: cacheAccountID)
    }

    public func fetchAssetLibraryId(appId: String, force: Bool = false) async -> Result<String, Error> {
        await ASCCache.cached(ttl: ASCCache.TTL.veryLong, force: force) {
            try await client.send(Resources.v1.apps.id(appId).assetLibrary.get()).data.id
        }
    }

    public func fetchScreenshotRefData(force: Bool = false) async -> Result<AssetLibraryRefData, Error> {
        await fetchRefData(placementType: .appScreenshot, force: force)
    }

    public func fetchRefData(
        placementType: AssetLibraryPlacementType,
        force: Bool = false,
    ) async -> Result<AssetLibraryRefData, Error> {
        await ASCCache.cached(ttl: ASCCache.TTL.long, force: force) {
            let request = Resources.v1.appAssetLibraryRefData.get(filterPlacementTypes: [placementType.rawValue])
            return try await client.send(request).data
        }.map { AssetLibraryRefData(schema: $0, placementType: placementType) }
    }

    public func fetchScreenshotPlacements(localizationId: String, force: Bool = false) async -> Result<[AssetLibraryPlacement], Error> {
        await fetchPlacements(localizationId: localizationId, placementType: .appScreenshot, force: force)
    }

    public func fetchPlacements(
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        force: Bool = false,
    ) async -> Result<[AssetLibraryPlacement], Error> {
        guard let filterType = Self.placementFilter(for: placementType) else {
            return .failure(NetworkError.noResponse)
        }
        return await ASCCache.cached(force: force) {
            let request = Resources.v1.appStoreVersionLocalizations.id(localizationId).placements.get(
                filterPlacementType: [filterType],
                sort: [.placementGroupPosition],
                limit: 200,
                include: [.image],
            )
            return try await client.send(request.tolerantPlacements).value
        }.map { response in
            let images: [String: AssetLibraryImage] = (response.included ?? []).reduce(into: [:]) { result, item in
                if case let .appAssetLibraryImage(image) = item {
                    result[image.id] = AssetLibraryImage(schema: image)
                }
            }
            return response.data.map { placement in
                let model = AssetLibraryPlacement(schema: placement)
                return AssetLibraryPlacement(
                    id: model.id,
                    placementType: model.placementType,
                    placementGroup: model.placementGroup,
                    state: model.state,
                    stateDetails: model.stateDetails,
                    imageId: model.imageId,
                    image: model.imageId.flatMap { images[$0] },
                )
            }
        }
    }

    public func fetchImage(id: String) async -> Result<AssetLibraryImage, Error> {
        do {
            let response = try await client.send(Resources.v1.appAssetLibraryImages.id(id).get())
            return .success(AssetLibraryImage(schema: response.data))
        } catch {
            return .failure(error.asNetworkError)
        }
    }

    public func uploadScreenshot(
        assetLibraryId: String,
        localizationId: String,
        placementGroup: String,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        await upload(
            assetLibraryId: assetLibraryId,
            localizationId: localizationId,
            placementType: .appScreenshot,
            placementGroup: placementGroup,
            category: .appScreenshotsAndPreviews,
            fileName: fileName,
            data: data,
        )
    }

    public func uploadCreative(
        assetLibraryId: String,
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        placementGroup: String? = nil,
        category: AssetLibraryAssetCategory = .creativeAssets,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        await upload(
            assetLibraryId: assetLibraryId,
            localizationId: localizationId,
            placementType: placementType,
            placementGroup: placementGroup,
            category: category,
            fileName: fileName,
            data: data,
        )
    }

    public func reorderPlacements(
        localizationId: String,
        placementGroup: String,
        placementIds: [String],
    ) async -> Result<Void, Error> {
        let body: AnyJSON = .object([
            "data": .object([
                "type": .string("appAssetLibraryPlacementOrderingRequests"),
                "attributes": .object(["placementGroup": .string(placementGroup)]),
                "relationships": .object([
                    "orderedPlacements": .object([
                        "data": .array(placementIds.map { .object(["type": .string("appAssetLibraryPlacements"), "id": .string($0)]) }),
                    ]),
                    "appStoreVersionLocalization": .object([
                        "data": .object(["type": .string("appStoreVersionLocalizations"), "id": .string(localizationId)]),
                    ]),
                ]),
            ]),
        ])
        let path = Resources.v1.appAssetLibraryPlacementOrderingRequests.path
        do {
            let request = Request<AppStoreAPI.AppAssetLibraryPlacementOrderingRequestResponse>(
                path: path,
                method: "POST",
                body: body,
                id: "appAssetLibraryPlacementOrderingRequests_createInstance",
            )
            _ = try await client.send(request)
            return .success(())
        } catch {
            return .failure(error.asNetworkError)
        }
    }

    public func deleteScreenshot(placementId: String, imageId: String?) async -> Result<Void, Error> {
        await deletePlacement(placementId: placementId, imageId: imageId)
    }

    public func deletePlacement(placementId: String, imageId: String?) async -> Result<Void, Error> {
        do {
            _ = try await client.send(Resources.v1.appAssetLibraryPlacements.id(placementId).delete)
            if let imageId {
                _ = try? await client.send(Resources.v1.appAssetLibraryImages.id(imageId).delete)
            }
            return .success(())
        } catch {
            return .failure(error.asNetworkError)
        }
    }
}

private extension AppAssetLibraryService {
    static func placementFilter(
        for placementType: AssetLibraryPlacementType,
    ) -> Resources.V1.AppStoreVersionLocalizations.WithID.Placements.FilterPlacementType? {
        .init(rawValue: placementType.rawValue)
    }

    func upload(
        assetLibraryId: String,
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        placementGroup: String?,
        category: AssetLibraryAssetCategory,
        fileName: String,
        data: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        var imageId: String?
        var step = "createImage"
        do {
            let reserved = try await createImage(
                assetLibraryId: assetLibraryId,
                category: category,
                fileName: fileName,
                fileSize: data.count,
            )
            imageId = reserved.id
            guard !reserved.uploadOperations.isEmpty else { throw NetworkError.noResponse }

            step = "uploadParts"
            try await ASCAssetUpload.upload(data: data, operations: reserved.uploadOperations.map(\.schema), client: client)
            step = "commitImage"
            try await commitImage(id: reserved.id)
            step = "waitForImage"
            let image = try await waitForImage(id: reserved.id)
            step = "createPlacement"
            let placement = try await createPlacement(
                imageId: image.id,
                localizationId: localizationId,
                placementType: placementType,
                placementGroup: placementGroup,
            )
            return .success(
                AssetLibraryPlacement(
                    id: placement.id,
                    placementType: placement.placementType ?? placementType,
                    placementGroup: placement.placementGroup,
                    state: placement.state,
                    stateDetails: placement.stateDetails,
                    imageId: image.id,
                    image: image,
                ),
            )
        } catch {
            Log.error("Asset upload failed at \(step) for \(fileName)", error: error)
            if let imageId {
                _ = try? await client.send(Resources.v1.appAssetLibraryImages.id(imageId).delete)
            }
            return .failure(error.asNetworkError)
        }
    }

    func createImage(
        assetLibraryId: String,
        category: AssetLibraryAssetCategory,
        fileName: String,
        fileSize: Int,
    ) async throws -> AssetLibraryImage {
        let request = Resources.v1.appAssetLibraryImages.post(
            .init(
                data: .init(
                    attributes: .init(category: category.schema, fileName: fileName, fileSize: Int64(fileSize)),
                    relationships: .init(assetLibrary: .init(data: .init(id: assetLibraryId))),
                ),
            ),
        )
        return AssetLibraryImage(schema: try await client.send(request).data)
    }

    func commitImage(id: String) async throws {
        let request = Resources.v1.appAssetLibraryImages.id(id).patch(
            .init(data: .init(id: id, attributes: .init(isUploaded: true))),
        )
        _ = try await client.send(request)
    }

    func waitForImage(id: String) async throws -> AssetLibraryImage {
        var lastState: AssetLibraryAssetState?
        for _ in 0 ..< Self.pollAttempts {
            let image = AssetLibraryImage(schema: try await client.send(Resources.v1.appAssetLibraryImages.id(id).get()).data)
            lastState = image.state
            if image.state == .failed {
                let detail = image.stateDetails.compactMap(\.description).joined(separator: "\n")
                throw NetworkError.apiError(title: "Image processing failed", detail: detail.isEmpty ? nil : detail)
            }
            if let state = image.state, !state.isProcessing {
                return image
            }
            try await Task.sleep(for: Self.pollInterval)
        }
        Log.error("Image \(id) still processing, last state: \(lastState?.rawValue ?? "nil")")
        throw NetworkError.timeout
    }

    func createPlacement(
        imageId: String,
        localizationId: String,
        placementType: AssetLibraryPlacementType,
        placementGroup: String?,
    ) async throws -> AssetLibraryPlacement {
        var attributes: [String: AnyJSON] = ["placementType": .string(placementType.rawValue)]
        if let placementGroup {
            attributes["placementGroup"] = .string(placementGroup)
        }
        let body: AnyJSON = .object([
            "data": .object([
                "type": .string("appAssetLibraryPlacements"),
                "attributes": .object(attributes),
                "relationships": .object([
                    "image": .object(["data": .object(["type": .string("appAssetLibraryImages"), "id": .string(imageId)])]),
                    "appStoreVersionLocalization": .object([
                        "data": .object(["type": .string("appStoreVersionLocalizations"), "id": .string(localizationId)]),
                    ]),
                ]),
            ]),
        ])
        let request = Request<AppStoreAPI.AppAssetLibraryPlacementResponse>(
            path: Resources.v1.appAssetLibraryPlacements.path,
            method: "POST",
            body: body,
            id: "appAssetLibraryPlacements_createInstance",
        )
        return AssetLibraryPlacement(schema: try await client.send(request.tolerantPlacements).value.data)
    }
}
