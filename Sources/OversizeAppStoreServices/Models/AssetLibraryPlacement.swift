//
// Copyright © 2026 Alexander Romanov
// AssetLibraryPlacement.swift, created on 23.10.2026
//

import AppStoreAPI
import Foundation

public struct AssetLibraryPlacement: Identifiable, Sendable {
    public let id: String
    public var placementType: AssetLibraryPlacementType?
    public var placementGroup: String?
    public var state: String?
    public var stateDetails: [AppMediaStateError]
    public var imageId: String?
    public var image: AssetLibraryImage?

    public init(
        id: String,
        placementType: AssetLibraryPlacementType? = nil,
        placementGroup: String? = nil,
        state: String? = nil,
        stateDetails: [AppMediaStateError] = [],
        imageId: String? = nil,
        image: AssetLibraryImage? = nil,
    ) {
        self.id = id
        self.placementType = placementType
        self.placementGroup = placementGroup
        self.state = state
        self.stateDetails = stateDetails
        self.imageId = imageId
        self.image = image
    }

    public init(schema: AppStoreAPI.AppAssetLibraryPlacement, image: AssetLibraryImage? = nil) {
        id = schema.id
        placementType = schema.attributes?.placementType.flatMap(AssetLibraryPlacementType.init(schema:))
        placementGroup = schema.attributes?.placementGroup
        state = schema.attributes?.state?.rawValue
        stateDetails = schema.attributes?.stateDetails?.map { AppMediaStateError(code: $0.code, description: $0.description) } ?? []
        if case let .appAssetLibraryPlacementImageRelationships(relationships)? = schema.relationships {
            imageId = relationships.image?.data?.id
        }
        self.image = image
    }

    public var isFailed: Bool {
        state == AppStoreAPI.AppAssetLibraryPlacementState.failed.rawValue || image?.state == .failed
    }
}
