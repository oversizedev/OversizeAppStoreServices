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
    public let releaseType: ReleaseType?
    public let earliestReleaseDate: Date?
    public let isDownloadable: Bool?
    public let createdDate: Date?

    public let included: Included?
    public let relationships: Relationships?

    init?(schema: AppStoreAPI.AppStoreVersion, included: [AppStoreAPI.AppStoreVersionsResponse.IncludedItem]? = nil) {
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

        var includedApp: AppStoreAPI.App?
        var includedAgeRatingDeclaration: AppStoreAPI.AgeRatingDeclaration?
        var includedAppStoreVersionLocalizations: [AppStoreAPI.AppStoreVersionLocalization]?
        var includedBuild: AppStoreAPI.Build?
        var includedAppStoreReviewDetail: [AppStoreAPI.AppStoreReviewDetail]?

        if let includedItems = included {
            for includedItem in includedItems {
                switch includedItem {
                case let .app(app):
                    includedApp = app
                case let .ageRatingDeclaration(ageRatingDeclaration):
                    includedAgeRatingDeclaration = ageRatingDeclaration
                case let .appStoreVersionLocalization(appStoreVersionLocalization):
                    includedAppStoreVersionLocalizations?.append(appStoreVersionLocalization)
                case let .build(build):
                    includedBuild = build
                case let .appStoreReviewDetail(appStoreReviewDetail):
                    includedAppStoreReviewDetail?.append(appStoreReviewDetail)
                default: continue
                }
            }
        }

        self.included = Included(
            app: includedApp.flatMap { .init(schema: $0) },
            build: includedBuild.flatMap { .init(schema: $0) },
            ageRatingDeclaration: includedAgeRatingDeclaration.flatMap { .init(schema: $0) },
            appStoreVersionLocalizations: includedAppStoreVersionLocalizations.flatMap { localizations in
                localizations.compactMap(AppStoreVersionLocalization.init)
            },
            appStoreReviewDetail: includedAppStoreReviewDetail.flatMap { reviewDetails in
                reviewDetails.compactMap(AppStoreReviewDetail.init)
            }
        )

        relationships = .init(
            appStoreVersionLocalizationsIds: schema.relationships?.appStoreVersionLocalizations?.data?.compactMap { $0.id }
        )
    }

    public struct Included: Sendable {
        public let app: App?
        public let build: Build?
        public let ageRatingDeclaration: AgeRatingDeclaration?
        public let appStoreVersionLocalizations: [AppStoreVersionLocalization]?
        public let appStoreReviewDetail: [AppStoreReviewDetail]?
    }

    public struct Relationships: Sendable {
        public let appStoreVersionLocalizationsIds: [String]?
    }
}
