//
// Copyright © 2024 Alexander Romanov
// Build.swift, created on 22.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public struct Build: Sendable, Identifiable {
    public let id: String
    public let version: String
    public let uploadedDate: Date
    public let expirationDate: Date
    public let iconAssetToken: ImageAsset?
    public let isExpired: Bool?
    public let minOsVersion: String?
    public let lsMinimumSystemVersion: String?
    public let computedMinMacOsVersion: String?
    public let processingState: ProcessingState?
    public let buildAudienceType: BuildAudienceType?

    public let relationships: Relationships

    public init?(schema: AppStoreAPI.Build) {
        guard let version = schema.attributes?.version,
              let uploadedDate = schema.attributes?.uploadedDate,
              let expirationDate = schema.attributes?.expirationDate
        else { return nil }
        self.version = version
        self.uploadedDate = uploadedDate
        self.expirationDate = expirationDate
        id = schema.id
        isExpired = schema.attributes?.isExpired
        minOsVersion = schema.attributes?.minOsVersion
        lsMinimumSystemVersion = schema.attributes?.lsMinimumSystemVersion
        computedMinMacOsVersion = schema.attributes?.computedMinMacOsVersion
        if let iconAssetToken = schema.attributes?.iconAssetToken {
            self.iconAssetToken = .init(schema: iconAssetToken)
        } else {
            iconAssetToken = nil
        }
        if let processingState = schema.attributes?.processingState?.rawValue {
            self.processingState = .init(rawValue: processingState)
        } else {
            processingState = .none
        }
        if let buildAudienceType = schema.attributes?.buildAudienceType?.rawValue {
            self.buildAudienceType = .init(rawValue: buildAudienceType)
        } else {
            buildAudienceType = .none
        }
        let templateUrl = schema.attributes?.iconAssetToken?.templateURL
        relationships = .init(
            buildBundlesIds: schema.relationships?.buildBundles?.data?.compactMap { $0.id }
        )
    }

    public struct Relationships: Sendable, Equatable {
        public let buildBundlesIds: [String]?
    }
}
