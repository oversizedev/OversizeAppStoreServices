//
// Copyright © 2024 Alexander Romanov
// Build.swift, created on 22.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public struct Build: Sendable, Identifiable, Equatable {
    public let id: String
    public let version: String
    public let uploadedDate: Date
    public let expirationDate: Date
    public let iconURL: URL?
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
        iconURL = parseURL(
            from: constructURLString(
                baseURL: templateUrl ?? "",
                width: schema.attributes?.iconAssetToken?.width ?? 100,
                height: schema.attributes?.iconAssetToken?.height ?? 100,
                format: "png"
            )
        )
        relationships = .init(
            buildBundlesIds: schema.relationships?.buildBundles?.data?.compactMap { $0.id }
        )
    }

    public struct Relationships: Sendable, Equatable {
        public let buildBundlesIds: [String]?
    }
}

func parseURL(from urlString: String) -> URL? {
    if let url = URL(string: urlString), let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
        if let scheme = components.scheme, let host = components.host {
            if !scheme.isEmpty, !host.isEmpty {
                return url
            }
        }
    }
    return nil
}

func constructURLString(baseURL: String, width: Int, height: Int, format: String) -> String {
    let replacedURL = baseURL.replacingOccurrences(of: "{w}", with: "\(width)")
        .replacingOccurrences(of: "{h}", with: "\(height)")
        .replacingOccurrences(of: "{f}", with: format)
    return replacedURL
}
