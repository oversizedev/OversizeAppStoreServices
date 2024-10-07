//
// Copyright © 2024 Alexander Romanov
// Version.swift, created on 23.07.2024
//

import AppStoreConnect
import Foundation
import OversizeCore

public struct Version {

    public let id: String
    public let version: String
    public let platform: Platform
    public let storeState: AppStoreVersionState
    public let state: AppVersionState?
    public let copyright: String?
    public let reviewType: ReviewType?
    public let releaseType: ReviewType?
    public let earliestReleaseDate: Date?
    public let isDownloadable: Bool?
    public let createdDate: Date?
    
    init?(schema: AppStoreConnect.AppStoreVersion) {
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
        self.copyright = schema.attributes?.copyright.valueOrEmpty
        self.earliestReleaseDate = schema.attributes?.earliestReleaseDate
        self.isDownloadable = schema.attributes?.isDownloadable
        self.createdDate = schema.attributes?.createdDate
        self.reviewType = .init(rawValue: schema.attributes?.createdDate?.rawValue ?? "")
        self.releaseType = .init(rawValue: schema.attributes?.releaseType?.rawValue ?? "")
    }
}
