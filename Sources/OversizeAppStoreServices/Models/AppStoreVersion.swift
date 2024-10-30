//
// Copyright © 2024 Alexander Romanov
// Version.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public struct AppStoreVersion: Sendable, Identifiable {
    public let id: String
    public let versionString: String
    public let platform: Platform
    public let storeState: AppStoreVersionState
    public let state: AppVersionState
    public let copyright: String
    public let reviewType: ReviewType?
    public let releaseType: ReviewType?
    public let earliestReleaseDate: Date?
    public let isDownloadable: Bool?
    public let createdDate: Date?

    public var included: Included?

    init?(schema: AppStoreAPI.AppStoreVersion, builds: [AppStoreAPI.Build] = []) {
        guard let storeState = schema.attributes?.appStoreState?.rawValue,
              let storeStateType: AppStoreVersionState = .init(rawValue: storeState),
              let state = schema.attributes?.appVersionState?.rawValue,
              let stateType: AppVersionState = .init(rawValue: state),
              let platform = schema.attributes?.platform?.rawValue,
              let platformType: Platform = .init(rawValue: platform),
              let versionString = schema.attributes?.versionString else { return nil }
        id = schema.id
        self.storeState = storeStateType
        self.state = stateType
        self.platform = platformType
        self.versionString = versionString

        copyright = schema.attributes?.copyright ?? ""
        earliestReleaseDate = schema.attributes?.earliestReleaseDate
        isDownloadable = schema.attributes?.isDownloadable
        createdDate = schema.attributes?.createdDate
        reviewType = .init(rawValue: schema.attributes?.createdDate?.rawValue ?? "")
        releaseType = .init(rawValue: schema.attributes?.releaseType?.rawValue ?? "")

        if let build = builds.first(where: { $0.id == schema.relationships?.build?.data?.id ?? "" }) {
            included = .init(
                builds: builds.compactMap { .init(schema: $0) }.sorted(by: { $0.uploadedDate > $1.uploadedDate }),
                build: .init(schema: build)
            )

        } else {
            included = .init(
                builds: builds.compactMap { .init(schema: $0) }.sorted(by: { $0.uploadedDate > $1.uploadedDate }),
                build: nil
            )
        }
    }

    public struct Included: Sendable {
        public let builds: [Build]
        public let build: Build?
    }
}
