//
// Copyright © 2024 Alexander Romanov
// Version.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public struct Version: Sendable, Identifiable {
    public let id: String
    public let version: String
    public let platform: Platform
    public let storeState: AppStoreVersionState
    public let state: AppVersionState
    public let copyright: String
    public let reviewType: ReviewType?
    public let releaseType: ReviewType?
    public let earliestReleaseDate: Date?
    public let isDownloadable: Bool?
    public let createdDate: Date?

    init?(schema: AppStoreAPI.AppStoreVersion) {
        guard let storeState = schema.attributes?.appStoreState?.rawValue,
              let storeStateType: AppStoreVersionState = .init(rawValue: storeState),
              let state = schema.attributes?.appVersionState?.rawValue,
              let stateType: AppVersionState = .init(rawValue: state),
              let platform = schema.attributes?.platform?.rawValue,
              let platformType: Platform = .init(rawValue: platform),
              let version = schema.attributes?.versionString else { return nil }
        id = schema.id
        self.storeState = storeStateType
        self.state = stateType
        self.platform = platformType
        self.version = version
        copyright = schema.attributes?.copyright ?? ""
        earliestReleaseDate = schema.attributes?.earliestReleaseDate
        isDownloadable = schema.attributes?.isDownloadable
        createdDate = schema.attributes?.createdDate
        reviewType = .init(rawValue: schema.attributes?.createdDate?.rawValue ?? "")
        releaseType = .init(rawValue: schema.attributes?.releaseType?.rawValue ?? "")
    }
}
