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
        await ASCCache.cached(ttl: ASCCache.TTL.long, force: force) {
            let request = Resources.v1.appAssetLibraryRefData.get(filterPlacementTypes: [AppAssetLibraryPlacementType.appScreenshot.rawValue])
            return try await client.send(request).data
        }.map { AssetLibraryRefData(schema: $0) }
    }

    public func fetchScreenshotPlacements(localizationId: String, force: Bool = false) async -> Result<[AssetLibraryPlacement], Error> {
        await ASCCache.cached(force: force) {
            let request = Resources.v1.appStoreVersionLocalizations.id(localizationId).placements.get(
                filterPlacementType: [.appScreenshot],
                sort: [.placementGroupPosition],
                limit: 200,
                include: [.image],
            )
            return try await client.send(request)
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
        var imageId: String?
        do {
            let reserved = try await createImage(assetLibraryId: assetLibraryId, fileName: fileName, fileSize: data.count)
            imageId = reserved.id
            guard !reserved.uploadOperations.isEmpty else { throw NetworkError.noResponse }

            try await ASCAssetUpload.upload(data: data, operations: reserved.uploadOperations.map(\.schema), client: client)
            try await commitImage(id: reserved.id)
            let image = try await waitForImage(id: reserved.id)
            let placement = try await createPlacement(imageId: image.id, localizationId: localizationId, placementGroup: placementGroup)
            return .success(
                AssetLibraryPlacement(
                    id: placement.id,
                    placementGroup: placement.placementGroup,
                    state: placement.state,
                    stateDetails: placement.stateDetails,
                    imageId: image.id,
                    image: image,
                ),
            )
        } catch {
            if let imageId {
                _ = try? await client.send(Resources.v1.appAssetLibraryImages.id(imageId).delete)
            }
            return .failure(error.asNetworkError)
        }
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
        do {
            _ = try await client.send(Resources.v1.appAssetLibraryPlacements.id(placementId).delete)
            if let imageId {
                _ = try await client.send(Resources.v1.appAssetLibraryImages.id(imageId).delete)
            }
            return .success(())
        } catch {
            return .failure(error.asNetworkError)
        }
    }
}

private extension AppAssetLibraryService {
    func createImage(assetLibraryId: String, fileName: String, fileSize: Int) async throws -> AssetLibraryImage {
        let request = Resources.v1.appAssetLibraryImages.post(
            .init(
                data: .init(
                    attributes: .init(category: .appScreenshotsAndPreviews, fileName: fileName, fileSize: Int64(fileSize)),
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
        for _ in 0 ..< Self.pollAttempts {
            let image = AssetLibraryImage(schema: try await client.send(Resources.v1.appAssetLibraryImages.id(id).get()).data)
            if image.state == .failed {
                let detail = image.stateDetails.compactMap(\.description).joined(separator: "\n")
                throw NetworkError.apiError(title: "Screenshot processing failed", detail: detail.isEmpty ? nil : detail)
            }
            if let state = image.state, !state.isProcessing {
                return image
            }
            try await Task.sleep(for: Self.pollInterval)
        }
        throw NetworkError.timeout
    }

    func createPlacement(imageId: String, localizationId: String, placementGroup: String) async throws -> AssetLibraryPlacement {
        let body: AnyJSON = .object([
            "data": .object([
                "type": .string("appAssetLibraryPlacements"),
                "attributes": .object([
                    "placementType": .string(AppAssetLibraryPlacementType.appScreenshot.rawValue),
                    "placementGroup": .string(placementGroup),
                ]),
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
        return AssetLibraryPlacement(schema: try await client.send(request).data)
    }
}
