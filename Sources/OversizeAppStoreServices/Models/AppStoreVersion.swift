//
// Copyright © 2024 Alexander Romanov
// Version.swift, created on 23.07.2024
//

import AppStoreAPI
import Foundation

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

    public init(
        id: String,
        versionString: String,
        platform: Platform,
        storeState: AppStoreVersionState,
        state: AppVersionState,
        copyright: String,
        reviewType: ReviewType?,
        releaseType: ReleaseType?,
        earliestReleaseDate: Date?,
        isDownloadable: Bool?,
        createdDate: Date?,
        included: Included?,
        relationships: Relationships?,
    ) {
        self.id = id
        self.versionString = versionString
        self.platform = platform
        self.storeState = storeState
        self.state = state
        self.copyright = copyright
        self.reviewType = reviewType
        self.releaseType = releaseType
        self.earliestReleaseDate = earliestReleaseDate
        self.isDownloadable = isDownloadable
        self.createdDate = createdDate
        self.included = included
        self.relationships = relationships
    }

    public init?(schema: AppStoreAPI.AppStoreVersion, included: [AppStoreAPI.AppStoreVersionsResponse.IncludedItem]? = nil) {
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
        reviewType = .init(rawValue: schema.attributes?.reviewType?.rawValue ?? "")
        releaseType = .init(rawValue: schema.attributes?.releaseType?.rawValue ?? "")

        var includedApp: AppStoreAPI.App?
        var includedBuild: AppStoreAPI.Build?
        var includedAppStoreVersionLocalizations: [AppStoreAPI.AppStoreVersionLocalization] = []
        var includedAppStoreReviewDetails: [AppStoreAPI.AppStoreReviewDetail] = []
        var includedAppStoreVersionExperiments: [AppStoreAPI.AppStoreVersionExperiment] = []
        var includedAppStoreVersionPhasedRelease: AppStoreAPI.AppStoreVersionPhasedRelease?
        var includedAppStoreVersionSubmission: AppStoreAPI.AppStoreVersionSubmission?
        var includedAppClipDefaultExperience: AppStoreAPI.AppClipDefaultExperience?
        var includedAlternativeDistributionPackage: AppStoreAPI.AlternativeDistributionPackage?
        var includedGameCenterAppVersion: AppStoreAPI.GameCenterAppVersion?
        var includedRoutingAppCoverage: AppStoreAPI.RoutingAppCoverage?

        let localizationIds = Set(schema.relationships?.appStoreVersionLocalizations?.data?.map(\.id) ?? [])
        let buildId = schema.relationships?.build?.data?.id
        let reviewDetailId = schema.relationships?.appStoreReviewDetail?.data?.id

        for includedItem in included ?? [] {
            switch includedItem {
            case let .app(app):
                includedApp = app
            case let .build(build):
                if buildId == build.id { includedBuild = build }
            case let .appStoreVersionLocalization(localization):
                if localizationIds.contains(localization.id) {
                    includedAppStoreVersionLocalizations.append(localization)
                }
            case let .appStoreReviewDetail(reviewDetail):
                if reviewDetailId == reviewDetail.id {
                    includedAppStoreReviewDetails.append(reviewDetail)
                }
            case let .appStoreVersionExperiment(experiment):
                includedAppStoreVersionExperiments.append(experiment)
            case let .appStoreVersionPhasedRelease(phasedRelease):
                includedAppStoreVersionPhasedRelease = phasedRelease
            case let .appStoreVersionSubmission(submission):
                includedAppStoreVersionSubmission = submission
            case let .appClipDefaultExperience(experience):
                includedAppClipDefaultExperience = experience
            case let .alternativeDistributionPackage(package):
                includedAlternativeDistributionPackage = package
            case let .gameCenterAppVersion(gameCenterVersion):
                includedGameCenterAppVersion = gameCenterVersion
            case let .routingAppCoverage(coverage):
                includedRoutingAppCoverage = coverage
            default:
                continue
            }
        }

        self.included = Included(
            app: includedApp.flatMap { .init(schema: $0) },
            build: includedBuild.flatMap { .init(schema: $0) },
            appStoreVersionLocalizations: includedAppStoreVersionLocalizations.compactMap(AppStoreVersionLocalization.init),
            appStoreReviewDetails: includedAppStoreReviewDetails.compactMap(AppStoreReviewDetail.init),
            appStoreVersionExperiments: includedAppStoreVersionExperiments.compactMap(AppStoreVersionExperiment.init),
            appStoreVersionPhasedRelease: includedAppStoreVersionPhasedRelease.flatMap { .init(schema: $0) },
            appStoreVersionSubmission: includedAppStoreVersionSubmission.flatMap { .init(schema: $0) },
            appClipDefaultExperience: includedAppClipDefaultExperience.flatMap { .init(schema: $0) },
            alternativeDistributionPackage: includedAlternativeDistributionPackage.flatMap { .init(schema: $0) },
            gameCenterAppVersion: includedGameCenterAppVersion.flatMap { .init(schema: $0) },
            routingAppCoverage: includedRoutingAppCoverage.flatMap { .init(schema: $0) },
        )

        relationships = .init(
            appStoreVersionLocalizationsIds: schema.relationships?.appStoreVersionLocalizations?.data?.compactMap { $0.id },
        )
    }

    public struct Included: Sendable {
        public let app: App?
        public let build: Build?
        public let appStoreVersionLocalizations: [AppStoreVersionLocalization]
        public let appStoreReviewDetails: [AppStoreReviewDetail]
        public let appStoreVersionExperiments: [AppStoreVersionExperiment]
        public let appStoreVersionPhasedRelease: AppStoreVersionPhasedRelease?
        public let appStoreVersionSubmission: AppStoreVersionSubmission?
        public let appClipDefaultExperience: AppClipDefaultExperience?
        public let alternativeDistributionPackage: AlternativeDistributionPackage?
        public let gameCenterAppVersion: GameCenterAppVersion?
        public let routingAppCoverage: RoutingAppCoverage?

        public init(
            app: App?,
            build: Build?,
            appStoreVersionLocalizations: [AppStoreVersionLocalization],
            appStoreReviewDetails: [AppStoreReviewDetail],
            appStoreVersionExperiments: [AppStoreVersionExperiment],
            appStoreVersionPhasedRelease: AppStoreVersionPhasedRelease?,
            appStoreVersionSubmission: AppStoreVersionSubmission?,
            appClipDefaultExperience: AppClipDefaultExperience?,
            alternativeDistributionPackage: AlternativeDistributionPackage?,
            gameCenterAppVersion: GameCenterAppVersion?,
            routingAppCoverage: RoutingAppCoverage?,
        ) {
            self.app = app
            self.build = build
            self.appStoreVersionLocalizations = appStoreVersionLocalizations
            self.appStoreReviewDetails = appStoreReviewDetails
            self.appStoreVersionExperiments = appStoreVersionExperiments
            self.appStoreVersionPhasedRelease = appStoreVersionPhasedRelease
            self.appStoreVersionSubmission = appStoreVersionSubmission
            self.appClipDefaultExperience = appClipDefaultExperience
            self.alternativeDistributionPackage = alternativeDistributionPackage
            self.gameCenterAppVersion = gameCenterAppVersion
            self.routingAppCoverage = routingAppCoverage
        }
    }

    public struct Relationships: Sendable {
        public let appStoreVersionLocalizationsIds: [String]?

        public init(appStoreVersionLocalizationsIds: [String]?) {
            self.appStoreVersionLocalizationsIds = appStoreVersionLocalizationsIds
        }
    }
}
