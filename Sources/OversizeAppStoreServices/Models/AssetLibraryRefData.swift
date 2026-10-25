//
// Copyright © 2026 Alexander Romanov
// AssetLibraryRefData.swift, created on 23.10.2026
//

import AppStoreAPI
import Foundation

public struct AssetLibraryRefData: Sendable {
    public let placementType: AssetLibraryPlacementType
    public let groups: [PlacementGroup]
    public let acceptedCategories: [AssetLibraryAssetCategory]

    public var screenshotGroups: [PlacementGroup] { groups }

    public init(
        placementType: AssetLibraryPlacementType = .appScreenshot,
        groups: [PlacementGroup],
        acceptedCategories: [AssetLibraryAssetCategory] = [],
    ) {
        self.placementType = placementType
        self.groups = groups
        self.acceptedCategories = acceptedCategories
    }

    public init(screenshotGroups: [PlacementGroup]) {
        self.init(placementType: .appScreenshot, groups: screenshotGroups)
    }

    public init(schema: [AppStoreAPI.AppAssetLibraryRefDatum], placementType: AssetLibraryPlacementType = .appScreenshot) {
        let attributes = schema.compactMap(\.attributes)
        let profileGroups = attributes.flatMap { $0.placementProfileGroups ?? [] }
        let specs = attributes.flatMap { $0.imageSpecs ?? [] }.compactMap { ImageSpec(schema: $0) }
        let specsById = Dictionary(specs.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let matchingTypes = attributes
            .flatMap { $0.placementTypes ?? [] }
            .filter { $0.placementTypeID.flatMap(AssetLibraryPlacementType.init(schema:)) == placementType }
        let mappings = matchingTypes.flatMap { $0.specMappings ?? [] }

        var groups: [PlacementGroup] = []
        for mapping in mappings {
            guard let groupId = mapping.placementGroupID, !groups.contains(where: { $0.id == groupId }) else { continue }
            let profile = profileGroups.first { $0.placementProfileGroupID == groupId }
            groups.append(
                PlacementGroup(
                    id: groupId,
                    platform: profile?.platform.flatMap { AssetLibraryPlacementPlatform(schema: $0) },
                    displayClass: profile?.displayClassID.flatMap { AssetLibraryDisplayClass(schema: $0) },
                    specs: (mapping.specs ?? []).compactMap { specsById[$0] },
                ),
            )
        }
        var categories: [AssetLibraryAssetCategory] = []
        for category in matchingTypes.flatMap({ $0.acceptsAssetCategories ?? [] }).compactMap(AssetLibraryAssetCategory.init(schema:)) where !categories.contains(category) {
            categories.append(category)
        }
        self.init(placementType: placementType, groups: groups, acceptedCategories: categories)
    }

    public func group(id: String) -> PlacementGroup? {
        groups.first { $0.id == id }
    }

    public var uploadCategory: AssetLibraryAssetCategory {
        if acceptedCategories.contains(.creativeAssets), !acceptedCategories.contains(.appScreenshotsAndPreviews) {
            return .creativeAssets
        }
        if acceptedCategories.contains(.appScreenshotsAndPreviews), !acceptedCategories.contains(.creativeAssets) {
            return .appScreenshotsAndPreviews
        }
        return placementType == .appScreenshot ? .appScreenshotsAndPreviews : .creativeAssets
    }
}

public extension AssetLibraryRefData {
    struct PlacementGroup: Identifiable, Sendable, Equatable {
        public let id: String
        public let platform: AssetLibraryPlacementPlatform?
        public let displayClass: AssetLibraryDisplayClass?
        public let specs: [ImageSpec]

        public init(
            id: String,
            platform: AssetLibraryPlacementPlatform?,
            displayClass: AssetLibraryDisplayClass?,
            specs: [ImageSpec],
        ) {
            self.id = id
            self.platform = platform
            self.displayClass = displayClass
            self.specs = specs
        }

        public func accepts(width: Int, height: Int) -> Bool {
            specs.contains { $0.accepts(width: width, height: height) }
        }

        public var preferredSize: PixelSize? {
            specs.compactMap(\.preferredSize).max { $0.width * $0.height < $1.width * $1.height }
        }
    }

    struct ImageSpec: Identifiable, Sendable, Equatable {
        public let id: String
        public let shortName: String?
        public let minWidth: Int?
        public let maxWidth: Int?
        public let minHeight: Int?
        public let maxHeight: Int?
        public let aspectRatio: String?
        public let isAlphaAllowed: Bool
        public let fileExtensions: [String]
        public let maxFileSize: Int64?
        public let mimeTypes: [String]
        public let isUniversalAsset: Bool
        public let compatiblePlacementTypes: [AssetLibraryPlacementType]

        public init(
            id: String,
            shortName: String? = nil,
            minWidth: Int? = nil,
            maxWidth: Int? = nil,
            minHeight: Int? = nil,
            maxHeight: Int? = nil,
            aspectRatio: String? = nil,
            isAlphaAllowed: Bool = false,
            fileExtensions: [String] = [],
            maxFileSize: Int64? = nil,
            mimeTypes: [String] = [],
            isUniversalAsset: Bool = false,
            compatiblePlacementTypes: [AssetLibraryPlacementType] = [],
        ) {
            self.id = id
            self.shortName = shortName
            self.minWidth = minWidth
            self.maxWidth = maxWidth
            self.minHeight = minHeight
            self.maxHeight = maxHeight
            self.aspectRatio = aspectRatio
            self.isAlphaAllowed = isAlphaAllowed
            self.fileExtensions = fileExtensions
            self.maxFileSize = maxFileSize
            self.mimeTypes = mimeTypes
            self.isUniversalAsset = isUniversalAsset
            self.compatiblePlacementTypes = compatiblePlacementTypes
        }

        init?(schema: AppStoreAPI.AppAssetLibraryRefDatum.Attributes.ImageSpec) {
            guard let id = schema.specID else { return nil }
            self.init(
                id: id,
                shortName: schema.shortName,
                minWidth: schema.dimensions?.minWidth,
                maxWidth: schema.dimensions?.maxWidth,
                minHeight: schema.dimensions?.minHeight,
                maxHeight: schema.dimensions?.maxHeight,
                aspectRatio: schema.aspectRatio,
                isAlphaAllowed: schema.isAlphaAllowed ?? false,
                fileExtensions: schema.fileExtensions ?? [],
                maxFileSize: schema.maxFileSize,
                mimeTypes: schema.mimeTypes ?? [],
                isUniversalAsset: schema.isUniversalAsset ?? false,
                compatiblePlacementTypes: (schema.compatiblePlacementTypes ?? []).compactMap(AssetLibraryPlacementType.init(schema:)),
            )
        }

        public func accepts(width: Int, height: Int) -> Bool {
            width >= (minWidth ?? 0) && width <= (maxWidth ?? Int.max)
                && height >= (minHeight ?? 0) && height <= (maxHeight ?? Int.max)
        }

        public var preferredSize: PixelSize? {
            guard let width = maxWidth ?? minWidth, let height = maxHeight ?? minHeight else { return nil }
            return PixelSize(width: width, height: height)
        }
    }

    struct PixelSize: Sendable, Equatable, Hashable {
        public let width: Int
        public let height: Int

        public init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }
}
