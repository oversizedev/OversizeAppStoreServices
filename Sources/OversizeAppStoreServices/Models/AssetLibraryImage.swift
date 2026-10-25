//
// Copyright © 2026 Alexander Romanov
// AssetLibraryImage.swift, created on 23.10.2026
//

import AppStoreAPI
import Foundation

public struct AssetLibraryImage: Identifiable, Sendable {
    public let id: String
    public var fileName: String?
    public var fileSize: Int?
    public var specId: String?
    public var state: AssetLibraryAssetState?
    public var stateDetails: [AppMediaStateError]
    public var imageAsset: ImageAsset?
    public var uploadOperations: [UploadOperation]
    public var placementIds: [String]

    public init(
        id: String,
        fileName: String? = nil,
        fileSize: Int? = nil,
        specId: String? = nil,
        state: AssetLibraryAssetState? = nil,
        stateDetails: [AppMediaStateError] = [],
        imageAsset: ImageAsset? = nil,
        uploadOperations: [UploadOperation] = [],
        placementIds: [String] = [],
    ) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.specId = specId
        self.state = state
        self.stateDetails = stateDetails
        self.imageAsset = imageAsset
        self.uploadOperations = uploadOperations
        self.placementIds = placementIds
    }

    public init(schema: AppStoreAPI.AppAssetLibraryImage) {
        let flat = (try? JSONEncoder().encode(schema.attributes)).flatMap {
            try? JSONDecoder().decode(Flat.self, from: $0)
        }
        id = schema.id
        fileName = flat?.fileName
        fileSize = flat?.fileSize
        specId = flat?.specId
        state = flat?.state.flatMap { AssetLibraryAssetState(rawValue: $0) }
        stateDetails = flat?.stateDetails?.map { AppMediaStateError(code: $0.code, description: $0.description) } ?? []
        imageAsset = flat?.imageAsset.map { ImageAsset(schema: $0) }
        uploadOperations = flat?.uploadOperations?.map { UploadOperation(schema: $0) } ?? []
        placementIds = schema.relationships?.placements?.data?.map(\.id) ?? []
    }
}

private extension AssetLibraryImage {
    struct Flat: Decodable {
        let fileName: String?
        let fileSize: Int?
        let specId: String?
        let state: String?
        let stateDetails: [AppStoreAPI.StateDetail]?
        let imageAsset: AppStoreAPI.ImageAsset?
        let uploadOperations: [AppStoreAPI.UploadOperation]?
    }
}
