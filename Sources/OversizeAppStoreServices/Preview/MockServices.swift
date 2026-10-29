//
// Copyright © 2026 Alexander Romanov
// MockServices.swift, created on 25.07.2026
//

#if DEBUG
import AppStoreAPI
import Foundation
import OversizeCore

// MARK: - Mock services for SwiftUI previews

public struct MockAppsService: AppsServicesProtocol {
    public init() {}

    public func fetchApp(id _: String, force _: Bool) async -> Result<App, Error> {
        .success(MockAppStoreData.app)
    }

    public func fetchAppIncludeBuildsAndAppStoreVersions(id _: String, force _: Bool) async -> Result<App, Error> {
        .success(MockAppStoreData.app)
    }

    public func fetchAppIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions(appId _: String) async -> Result<App, Error> {
        .success(MockAppStoreData.app)
    }

    public func fetchApps() async -> Result<[App], Error> {
        .success([MockAppStoreData.app])
    }

    public func fetchAppsIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions(forse _: Bool) async -> Result<[App], Error> {
        .success([MockAppStoreData.app])
    }

    public func fetchAppsIncludeActualAppStoreVersionsAndBuilds(limitAppStoreVersions _: Int?, forse _: Bool) async -> Result<[App], Error> {
        .success([MockAppStoreData.app])
    }

    public func patchPrimaryLanguage(appId _: String, locale _: AppStoreLanguage) async -> Result<App, Error> {
        .success(MockAppStoreData.app)
    }
}

public struct MockVersionsService: VersionsServicesProtocol {
    public init() {}

    public func fetchAppStoreVersion(appStoreVersionId _: String) async -> Result<AppStoreVersion, Error> {
        .success(MockAppStoreData.appStoreVersion)
    }

    public func fetchAppVersions(appId _: String, platform _: Platform?, force _: Bool) async -> Result<[AppStoreVersion], Error> {
        .success(MockAppStoreData.appStoreVersions)
    }

    public func fetchEditableAppStoreVersion(appId _: String, platform _: Platform?, force _: Bool) async -> Result<[AppStoreVersion], Error> {
        .success([MockAppStoreData.appStoreVersion])
    }

    public func fetchRelisedAppVersions(appId _: String) async -> Result<[AppStoreVersion], Error> {
        .success([MockAppStoreData.appStoreVersion])
    }

    public func fetchRelisedAppVersionsIncludeLocalizations(appId _: String, platform _: Platform?, limit _: Int?, force _: Bool) async -> Result<[AppStoreVersion], Error> {
        .success(MockAppStoreData.releasedAppStoreVersions)
    }

    public func fetchActualAppStoreVersions(appId _: String, platform _: Platform?, force _: Bool) async -> Result<[AppStoreVersion], Error> {
        .success([MockAppStoreData.appStoreVersion])
    }

    public func fetchActualAppStoreVersionsIncludeBuilds(appId _: String, platform _: Platform?, limit _: Int?, force _: Bool) async -> Result<[AppStoreVersion], Error> {
        .success([MockAppStoreData.appStoreVersion])
    }

    public func fetchAppVersions(appId _: String, platform _: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], Error> {
        .success([MockAppStoreData.appStoreVersion])
    }

    public func fetchAllVersionLocalizations(forVersion _: String) async throws -> Result<[(String, AppStoreLanguage)], Error> {
        .success([])
    }

    public func fetchAppVersionLocalizations(versionId _: String, force _: Bool) async -> Result<[AppStoreVersionLocalization], Error> {
        .success([])
    }

    public func patchBuild(versionId _: String, buildId _: String) async -> Result<AppStoreVersion, Error> {
        .success(MockAppStoreData.appStoreVersion)
    }

    public func postAppStoreVersionLocalization(
        appStoreVersionsId _: String,
        locale _: AppStoreLanguage,
        whatsNew _: String?,
        description _: String?,
        promotionalText _: String?,
        keywords _: String?,
        marketingURL _: URL?,
        supportURL _: URL?,
    ) async -> Result<AppStoreVersionLocalization, Error> {
        .failure(NetworkError.noResponse)
    }

    public func patchVersionLocalization(
        localizationId _: String,
        whatsNew _: String?,
        description _: String?,
        promotionalText _: String?,
        keywords _: String?,
        marketingURL _: URL?,
        supportURL _: URL?,
    ) async -> Result<AppStoreVersionLocalization, Error> {
        .failure(NetworkError.noResponse)
    }

    public func patchVersion(
        versionId _: String,
        versionString _: String?,
        copyright _: String?,
        reviewType _: ReviewType?,
        releaseType _: ReleaseType?,
        earliestReleaseDate _: Date?,
        isDownloadable _: Bool?,
    ) async -> Result<AppStoreVersion, Error> {
        .success(MockAppStoreData.appStoreVersion)
    }

    public func postVersion(
        appId _: String,
        platform _: Platform,
        versionString _: String,
        copyright _: String?,
        reviewType _: ReviewType?,
        releaseType _: ReleaseType?,
        earliestReleaseDate _: Date?,
    ) async -> Result<AppStoreVersion, Error> {
        .success(MockAppStoreData.appStoreVersion)
    }

    public func deleteAppStoreVersionLocalizationsLocalization(localizationId _: String) async -> Result<Bool, Error> {
        .success(true)
    }
}

public struct MockAppAssetLibraryService: AppAssetLibraryServicesProtocol {
    public init() {}

    public func fetchAssetLibraryId(appId _: String, force _: Bool) async -> Result<String, Error> {
        .success("mock-asset-library")
    }

    public func fetchRefData(placementType: AssetLibraryPlacementType, force _: Bool) async -> Result<AssetLibraryRefData, Error> {
        .success(AssetLibraryRefData(placementType: placementType, groups: []))
    }

    public func fetchPlacements(
        owner _: AssetLibraryPlacementOwner,
        placementType: AssetLibraryPlacementType,
        force _: Bool,
    ) async -> Result<[AssetLibraryPlacement], Error> {
        let placements = (1 ... 3).map { index in
            AssetLibraryPlacement(
                id: "mock-placement-\(index)",
                placementType: placementType,
                placementGroup: "mock-group",
                state: "APPROVED",
                imageId: "mock-image-\(index)",
                image: AssetLibraryImage(id: "mock-image-\(index)", fileName: "Screen 0\(index).png"),
            )
        }
        return .success(placements)
    }

    public func fetchImage(id: String) async -> Result<AssetLibraryImage, Error> {
        .success(AssetLibraryImage(id: id, fileName: "Screen.png"))
    }

    public func uploadCreative(
        assetLibraryId _: String,
        owner _: AssetLibraryPlacementOwner,
        placementType: AssetLibraryPlacementType,
        placementGroup: String?,
        category _: AssetLibraryAssetCategory,
        fileName: String,
        data _: Data,
    ) async -> Result<AssetLibraryPlacement, Error> {
        .success(AssetLibraryPlacement(id: "mock-uploaded", placementType: placementType, placementGroup: placementGroup, image: AssetLibraryImage(id: "mock-uploaded-image", fileName: fileName)))
    }

    public func reorderPlacements(owner _: AssetLibraryPlacementOwner, placementGroup _: String, placementIds _: [String]) async -> Result<Void, Error> {
        .success(())
    }

    public func deletePlacement(placementId _: String, imageId _: String?) async -> Result<Void, Error> {
        .success(())
    }
}

public struct MockAppStoreVersionExperimentsService: AppStoreVersionExperimentsServicesProtocol {
    public init() {}

    public func fetchExperiments(
        appId _: String,
        states _: [AppStoreVersionExperimentV2.State]?,
        force _: Bool,
    ) async -> Result<[AppStoreVersionExperimentV2], Error> {
        .success(MockAppStoreData.experiments)
    }

    public func fetchExperiment(id: String, force _: Bool) async -> Result<AppStoreVersionExperimentV2, Error> {
        .success(MockAppStoreData.experiments.first { $0.id == id } ?? MockAppStoreData.experiments[0])
    }

    public func postExperiment(
        appId _: String,
        name: String,
        platform: Platform,
        trafficProportion: Int,
    ) async -> Result<AppStoreVersionExperimentV2, Error> {
        .success(AppStoreVersionExperimentV2(id: "mock-experiment-new", name: name, platform: platform, trafficProportion: trafficProportion, state: .prepareForSubmission))
    }

    public func patchExperiment(
        id: String,
        name: String?,
        trafficProportion: Int?,
        isStarted _: Bool?,
    ) async -> Result<AppStoreVersionExperimentV2, Error> {
        .success(AppStoreVersionExperimentV2(id: id, name: name, platform: .ios, trafficProportion: trafficProportion, state: .prepareForSubmission))
    }

    public func deleteExperiment(id _: String) async -> Result<Void, Error> {
        .success(())
    }

    public func fetchTreatments(experimentId _: String, force _: Bool) async -> Result<[AppStoreVersionExperimentTreatment], Error> {
        .success(MockAppStoreData.experimentTreatments)
    }

    public func postTreatment(experimentId: String, name: String, appIconName: String?) async -> Result<AppStoreVersionExperimentTreatment, Error> {
        .success(AppStoreVersionExperimentTreatment(id: "mock-treatment-new", name: name, appIconName: appIconName, experimentId: experimentId))
    }

    public func patchTreatment(id: String, name: String?, appIconName: String?) async -> Result<AppStoreVersionExperimentTreatment, Error> {
        .success(AppStoreVersionExperimentTreatment(id: id, name: name, appIconName: appIconName))
    }

    public func deleteTreatment(id _: String) async -> Result<Void, Error> {
        .success(())
    }

    public func fetchTreatmentLocalizations(treatmentId _: String, force _: Bool) async -> Result<[AppStoreVersionExperimentTreatmentLocalization], Error> {
        .success(MockAppStoreData.experimentTreatments[0].localizations)
    }

    public func postTreatmentLocalization(
        treatmentId: String,
        locale: AppStoreLanguage,
        placementIds: [String],
    ) async -> Result<AppStoreVersionExperimentTreatmentLocalization, Error> {
        .success(AppStoreVersionExperimentTreatmentLocalization(id: "mock-treatment-localization-new", locale: locale, treatmentId: treatmentId, placementIds: placementIds))
    }

    public func deleteTreatmentLocalization(id _: String) async -> Result<Void, Error> {
        .success(())
    }
}

public struct MockReviewSubmissionsService: ReviewSubmissionsServicesProtocol {
    public init() {}

    public func postReviewSubmission(appId _: String, platform _: Platform) async -> Result<ReviewSubmission, Error> {
        .success(MockAppStoreData.reviewSubmission)
    }

    public func postReviewSubmissionItems(reviewSubmissionId _: String, appStoreVersionsId _: String) async -> Result<ReviewSubmissionItem, Error> {
        .success(MockAppStoreData.reviewSubmissionItem)
    }

    public func patchReviewSubmissions(reviewSubmissionId _: String, isSubmitted _: Bool, isCanceled _: Bool?) async -> Result<ReviewSubmission, Error> {
        .success(MockAppStoreData.reviewSubmission)
    }

    public func postAppStoreVersionSubmissionWithItems(appId _: String, appStoreVersionsId _: String, platform _: Platform) async -> Result<ReviewSubmission, Error> {
        .success(MockAppStoreData.reviewSubmission)
    }

    public func postReviewSubmissionItems(reviewSubmissionId _: String, experimentId _: String) async -> Result<ReviewSubmissionItem, Error> {
        .success(MockAppStoreData.reviewSubmissionItem)
    }

    public func postExperimentSubmissionWithItems(appId _: String, experimentId _: String, platform _: Platform) async -> Result<ReviewSubmission, Error> {
        .success(MockAppStoreData.reviewSubmission)
    }

    public func fetchReviewSubmissions(appId _: String) async -> Result<[ReviewSubmission], Error> {
        .success(MockAppStoreData.reviewSubmissions)
    }

    public func fetchReviewSubmissionsIncludedAll(appId _: String, force _: Bool) async -> Result<[ReviewSubmission], Error> {
        .success(MockAppStoreData.reviewSubmissions)
    }

    public func fetchReviewSubmissionItemsIncludedAll(reviewSubmissionId _: String, force _: Bool) async -> Result<[ReviewSubmissionItem], Error> {
        .success(MockAppStoreData.reviewSubmissionItems)
    }

    public func cancelReviewSubmission(id _: String) async -> Result<Void, Error> {
        .success(())
    }

    public func cancelIrisReviewSubmission(id _: String) async -> Result<Void, Error> {
        .success(())
    }
}

public struct MockAppStoreReviewService: AppStoreReviewServicesProtocol {
    public init() {}

    public func fetchAppStoreReviewDetail(versionId _: String) async -> Result<AppStoreReviewDetail, Error> {
        .success(MockAppStoreData.appStoreReviewDetail)
    }

    public func fetchAppStoreReviewDetailAttachments(versionId _: String) async -> Result<[AppStoreReviewAttachment], Error> {
        .success([])
    }

    public func patchAppStoreReviewDetail(
        appStoreReviewDetailId _: String,
        contactFirstName _: String?,
        contactLastName _: String?,
        contactPhone _: String?,
        contactEmail _: String?,
        demoAccountName _: String?,
        demoAccountPassword _: String?,
        isDemoAccountRequired _: Bool?,
        notes _: String?,
    ) async -> Result<AppStoreReviewDetail, Error> {
        .success(MockAppStoreData.appStoreReviewDetail)
    }

    public func postAppStoreReviewDetail(
        versionId _: String,
        contactFirstName _: String?,
        contactLastName _: String?,
        contactPhone _: String?,
        contactEmail _: String?,
        demoAccountName _: String?,
        demoAccountPassword _: String?,
        isDemoAccountRequired _: Bool?,
        notes _: String?,
    ) async -> Result<AppStoreReviewDetail, Error> {
        .success(MockAppStoreData.appStoreReviewDetail)
    }
}

public struct MockBuildsService: BuildsServicesProtocol {
    public init() {}

    public func fetchBuild(buildId _: String, forse _: Bool) async -> Result<Build, Error> {
        .success(MockAppStoreData.build)
    }

    public func fetchBuildDeviceFamilies(buildId _: String, forse _: Bool) async -> Result<BuildDeviceFamilies, Error> {
        .success(BuildDeviceFamilies(supportsiPhone: true, supportsiPad: true))
    }

    public func fetchBuildBundlesId(buildBundlesId _: String, forse _: Bool) async -> Result<[BuildBundleFileSize], Error> {
        .success([])
    }

    public func fetchBuildIcons(buildId _: String, force _: Bool) async -> Result<[BuildIconAsset], Error> {
        .success(MockAppStoreData.buildIcons)
    }

    public func fetchAppBuilds(appId _: String) async -> Result<[Build], Error> {
        .success([MockAppStoreData.build])
    }

    public func fetchPreReleaseVersionBuilds(appId _: String, versionString _: String, platfrom _: Platform) async -> Result<[Build], Error> {
        .success([MockAppStoreData.build])
    }

    public func fetchAppStoreVersionsBuild(versionId _: String) async -> Result<Build?, Error> {
        .success(MockAppStoreData.build)
    }

    public func fetchAppStoreVersionsBuildImageUrl(versionId _: String) async -> Result<URL?, Error> {
        .success(nil)
    }
}

// MARK: - Mock data

public enum MockAppStoreData {
    public static var appStoreVersion: AppStoreVersion {
        AppStoreVersion(
            id: "1",
            versionString: "1.2.0",
            platform: .ios,
            storeState: .readyForSale,
            state: .readyForDistribution,
            copyright: "© 2026 Oversize",
            reviewType: nil,
            releaseType: nil,
            earliestReleaseDate: nil,
            isDownloadable: true,
            createdDate: Date(),
            included: nil,
            relationships: nil,
        )
    }

    public static var latestAppStoreVersion: AppStoreVersion {
        AppStoreVersion(
            id: "4",
            versionString: "1.3.0",
            platform: .ios,
            storeState: .waitingForReview,
            state: .waitingForReview,
            copyright: "© 2026 Oversize",
            reviewType: nil,
            releaseType: .manual,
            earliestReleaseDate: nil,
            isDownloadable: false,
            createdDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            included: AppStoreVersion.Included(
                app: nil,
                build: build,
                appStoreVersionLocalizations: [],
                appStoreReviewDetails: [],
                appStoreVersionExperiments: [],
                appStoreVersionPhasedRelease: nil,
                appStoreVersionSubmission: nil,
                appClipDefaultExperience: nil,
                alternativeDistributionPackage: nil,
                gameCenterAppVersion: nil,
                routingAppCoverage: nil,
            ),
            relationships: nil,
        )
    }

    public static var appStoreVersions: [AppStoreVersion] {
        [latestAppStoreVersion] + releasedAppStoreVersions + [macOsAppStoreVersion]
    }

    public static var macOsAppStoreVersion: AppStoreVersion {
        AppStoreVersion(
            id: "5",
            versionString: "1.2.0",
            platform: .macOs,
            storeState: .readyForSale,
            state: .readyForDistribution,
            copyright: "© 2026 Oversize",
            reviewType: nil,
            releaseType: nil,
            earliestReleaseDate: nil,
            isDownloadable: true,
            createdDate: Calendar.current.date(byAdding: .day, value: -20, to: Date()),
            included: AppStoreVersion.Included(
                app: nil,
                build: build,
                appStoreVersionLocalizations: [],
                appStoreReviewDetails: [],
                appStoreVersionExperiments: [],
                appStoreVersionPhasedRelease: nil,
                appStoreVersionSubmission: nil,
                appClipDefaultExperience: nil,
                alternativeDistributionPackage: nil,
                gameCenterAppVersion: nil,
                routingAppCoverage: nil,
            ),
            relationships: nil,
        )
    }

    public static var buildIcons: [BuildIconAsset] {
        [
            BuildIconAsset(id: "icon-primary", name: "AppIcon", iconType: .appStore),
            BuildIconAsset(id: "icon-dark", name: "AppIconDark", iconType: .alternateExperiment),
            BuildIconAsset(id: "icon-gradient", name: "AppIconGradient", iconType: .alternateExperiment),
        ]
    }

    public static var build: Build {
        Build(
            id: "build-1",
            version: "482",
            uploadedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            expirationDate: Calendar.current.date(byAdding: .day, value: 88, to: Date()) ?? Date(),
            iconAssetToken: nil,
            isExpired: false,
            minOsVersion: "17.0",
            lsMinimumSystemVersion: nil,
            computedMinMacOsVersion: nil,
            processingState: .valid,
            buildAudienceType: nil,
            relationships: .init(buildBundlesIds: nil),
        )
    }

    public static var releasedAppStoreVersions: [AppStoreVersion] {
        [
            makeReleasedVersion(
                id: "3",
                versionString: "1.2.0",
                state: .readyForDistribution,
                daysAgo: 14,
                whatsNew: [
                    .englishUS: "Dark mode support and a redesigned dashboard.",
                    .german: "Unterstützung für den Dunkelmodus und ein neu gestaltetes Dashboard.",
                    .russian: "Поддержка тёмной темы и обновлённая панель.",
                ],
            ),
            makeReleasedVersion(
                id: "2",
                versionString: "1.1.0",
                state: .replacedWithNewVersion,
                daysAgo: 96,
                whatsNew: [
                    .englishUS: "Faster sync and bug fixes.",
                    .russian: "Ускоренная синхронизация и исправление ошибок.",
                ],
            ),
            makeReleasedVersion(
                id: "1",
                versionString: "1.0.0",
                state: .replacedWithNewVersion,
                daysAgo: 210,
                whatsNew: [
                    .englishUS: "First release.",
                ],
            ),
        ]
    }

    static func makeReleasedVersion(
        id: String,
        versionString: String,
        state: AppVersionState,
        daysAgo: Int,
        whatsNew: [AppStoreLanguage: String],
    ) -> AppStoreVersion {
        AppStoreVersion(
            id: id,
            versionString: versionString,
            platform: .ios,
            storeState: .readyForSale,
            state: state,
            copyright: "© 2026 Oversize",
            reviewType: nil,
            releaseType: nil,
            earliestReleaseDate: nil,
            isDownloadable: true,
            createdDate: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()),
            included: AppStoreVersion.Included(
                app: nil,
                build: nil,
                appStoreVersionLocalizations: whatsNew.map { locale, text in
                    AppStoreVersionLocalization(
                        id: "\(id)-\(locale.rawValue)",
                        locale: locale,
                        description: "Mock description for \(locale.displayName).",
                        keywords: "mock,preview,appstore",
                        marketingURL: nil,
                        promotionalText: "Mock promotional text.",
                        supportURL: nil,
                        whatsNew: text,
                    )
                },
                appStoreReviewDetails: [],
                appStoreVersionExperiments: [],
                appStoreVersionPhasedRelease: nil,
                appStoreVersionSubmission: nil,
                appClipDefaultExperience: nil,
                alternativeDistributionPackage: nil,
                gameCenterAppVersion: nil,
                routingAppCoverage: nil,
            ),
            relationships: nil,
        )
    }

    // MARK: - Review submissions

    public static var experimentTreatments: [AppStoreVersionExperimentTreatment] {
        ["A", "B"].map { letter in
            let treatmentId = "mock-treatment-\(letter.lowercased())"
            let localizations = [AppStoreLanguage.englishUS, .german].enumerated().map { index, locale in
                AppStoreVersionExperimentTreatmentLocalization(
                    id: "\(treatmentId)-localization-\(index)",
                    locale: locale,
                    treatmentId: treatmentId,
                    placementIds: ["mock-placement-1", "mock-placement-2", "mock-placement-3"],
                )
            }
            return AppStoreVersionExperimentTreatment(
                id: treatmentId,
                name: "Treatment \(letter)",
                experimentId: "mock-experiment-1",
                localizationIds: localizations.map(\.id),
                localizations: localizations,
            )
        }
    }

    public static var experiments: [AppStoreVersionExperimentV2] {
        [
            AppStoreVersionExperimentV2(
                id: "mock-experiment-1",
                name: "Dark background screenshots",
                platform: .ios,
                trafficProportion: 30,
                state: .prepareForSubmission,
                isReviewRequired: true,
                relationships: .init(appId: "mock-app", appStoreVersionExperimentTreatmentIds: experimentTreatments.map(\.id)),
                treatments: experimentTreatments,
            ),
            AppStoreVersionExperimentV2(
                id: "mock-experiment-2",
                name: "Feature-first captions",
                platform: .ios,
                trafficProportion: 50,
                state: .completed,
                isReviewRequired: false,
                startDate: Date(timeIntervalSinceNow: -86400 * 40),
                endDate: Date(timeIntervalSinceNow: -86400 * 10),
            ),
        ]
    }

    public static var reviewSubmission: ReviewSubmission {
        makeReviewSubmission(
            id: "submission-1",
            state: .inReview,
            daysAgo: 1,
            version: latestAppStoreVersion,
            items: reviewSubmissionItems,
        )
    }

    public static var reviewSubmissions: [ReviewSubmission] {
        [
            reviewSubmission,
            makeReviewSubmission(
                id: "submission-2",
                state: .unresolvedIssues,
                daysAgo: 6,
                version: latestAppStoreVersion,
                items: [makeReviewSubmissionItem(id: "item-rejected", state: .rejected, version: latestAppStoreVersion)],
            ),
            makeReviewSubmission(
                id: "submission-3",
                state: .complete,
                daysAgo: 14,
                version: appStoreVersion,
                items: [makeReviewSubmissionItem(id: "item-approved", state: .approved, version: appStoreVersion)],
            ),
            makeReviewSubmission(
                id: "submission-4",
                state: .complete,
                daysAgo: 20,
                version: macOsAppStoreVersion,
                items: [makeReviewSubmissionItem(id: "item-macos", state: .approved, version: macOsAppStoreVersion)],
            ),
        ]
    }

    public static var reviewSubmissionItem: ReviewSubmissionItem {
        makeReviewSubmissionItem(id: "item-1", state: .readyForReview, version: latestAppStoreVersion)
    }

    public static var reviewSubmissionItems: [ReviewSubmissionItem] {
        [
            makeReviewSubmissionItem(id: "item-1", state: .readyForReview, version: latestAppStoreVersion),
            makeReviewSubmissionItem(id: "item-2", state: .accepted, version: nil),
        ]
    }

    public static var appStoreReviewDetail: AppStoreReviewDetail {
        AppStoreReviewDetail(
            id: "review-detail-1",
            contactFirstName: "Alexander",
            contactLastName: "Romanov",
            contactPhone: "+1 555 0100",
            contactEmail: "review@oversize.dev",
            demoAccountName: "demo@oversize.dev",
            demoAccountPassword: "demo-password",
            isDemoAccountRequired: true,
            notes: "The app requires an App Store Connect API key to sign in. Use the demo account above.",
        )
    }

    static var submittedByActor: Actor {
        Actor(
            id: "actor-1",
            actorType: .user,
            userFirstName: "Alexander",
            userLastName: "Romanov",
            userEmail: "aromanov@oversize.dev",
            apiKeyId: nil,
        )
    }

    static var lastUpdatedByActor: Actor {
        Actor(
            id: "actor-2",
            actorType: .apple,
            userFirstName: nil,
            userLastName: nil,
            userEmail: nil,
            apiKeyId: nil,
        )
    }

    static func makeReviewSubmission(
        id: String,
        state: ReviewSubmissionState,
        daysAgo: Int,
        version: AppStoreVersion?,
        items: [ReviewSubmissionItem],
    ) -> ReviewSubmission {
        ReviewSubmission(
            id: id,
            platform: version?.platform ?? .ios,
            submittedDate: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()),
            state: state,
            relationships: .init(
                appId: app.id,
                itemIds: items.map(\.id),
                appStoreVersionForReviewId: version?.id,
                submittedByActorId: submittedByActor.id,
                lastUpdatedByActorId: lastUpdatedByActor.id,
            ),
            included: .init(
                app: app,
                appStoreVersionForReview: version,
                reviewSubmissionItems: items,
                submittedByActor: submittedByActor,
                lastUpdatedByActor: lastUpdatedByActor,
            ),
        )
    }

    static func makeReviewSubmissionItem(
        id: String,
        state: ReviewSubmissionItem.State,
        version: AppStoreVersion?,
    ) -> ReviewSubmissionItem {
        ReviewSubmissionItem(
            id: id,
            state: state,
            relationships: .init(
                appStoreVersionId: version?.id,
                appCustomProductPageVersionId: nil,
                appStoreVersionExperimentId: nil,
                appStoreVersionExperimentV2Id: nil,
                appEventId: nil,
                backgroundAssetVersionId: nil,
                gameCenterAchievementVersionId: nil,
                gameCenterActivityVersionId: nil,
                gameCenterChallengeVersionId: nil,
                gameCenterLeaderboardSetVersionId: nil,
                gameCenterLeaderboardVersionId: nil,
                inAppPurchaseVersionId: nil,
                subscriptionVersionId: nil,
                subscriptionGroupVersionId: nil,
            ),
            included: .init(
                appStoreVersion: version,
                appCustomProductPageVersion: nil,
                appStoreVersionExperiment: nil,
                appEvent: nil,
                backgroundAssetVersion: nil,
                gameCenterAchievementVersionV2: nil,
                gameCenterActivityVersion: nil,
                gameCenterChallengeVersion: nil,
                gameCenterLeaderboardSetVersionV2: nil,
                gameCenterLeaderboardVersionV2: nil,
                inAppPurchaseVersion: nil,
                subscriptionVersion: nil,
                subscriptionGroupVersion: nil,
            ),
        )
    }

    static var app: App {
        App(
            id: "1",
            name: "AppConnector",
            bundleID: "com.oversize.appconnector",
            sku: "SKU-APPCONNECTOR",
            primaryLocale: .englishUS,
            included: App.Included(
                appStoreVersions: [appStoreVersion],
                builds: [],
                prereleaseVersions: [],
            ),
        )
    }
}

// MARK: - Preview memberwise init

extension ReviewSubmission {
    init(
        id: String,
        platform: Platform?,
        submittedDate: Date?,
        state: ReviewSubmissionState?,
        relationships: Relationships?,
        included: Included?,
    ) {
        self.id = id
        self.platform = platform
        self.submittedDate = submittedDate
        self.state = state
        self.relationships = relationships
        self.included = included
    }
}

extension ReviewSubmissionItem {
    init(
        id: String,
        state: State?,
        relationships: Relationships?,
        included: Included?,
    ) {
        self.id = id
        self.state = state
        self.relationships = relationships
        self.included = included
    }
}

extension Actor {
    init(
        id: String,
        actorType: ActorType?,
        userFirstName: String?,
        userLastName: String?,
        userEmail: String?,
        apiKeyId: String?,
    ) {
        self.id = id
        self.actorType = actorType
        self.userFirstName = userFirstName
        self.userLastName = userLastName
        self.userEmail = userEmail
        self.apiKeyId = apiKeyId
    }
}

extension AppStoreReviewDetail {
    init(
        id: String,
        contactFirstName: String,
        contactLastName: String,
        contactPhone: String,
        contactEmail: String,
        demoAccountName: String,
        demoAccountPassword: String,
        isDemoAccountRequired: Bool,
        notes: String,
    ) {
        self.id = id
        self.contactFirstName = contactFirstName
        self.contactLastName = contactLastName
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        self.demoAccountName = demoAccountName
        self.demoAccountPassword = demoAccountPassword
        self.isDemoAccountRequired = isDemoAccountRequired
        self.notes = notes
    }
}

extension App {
    init(
        id: String,
        name: String,
        bundleID: String,
        sku: String,
        primaryLocale: AppStoreLanguage,
        included: Included?,
    ) {
        self.id = id
        self.name = name
        self.bundleID = bundleID
        self.sku = sku
        self.primaryLocale = primaryLocale
        contentRightsDeclaration = nil
        isOrEverWasMadeForKids = nil
        subscriptionStatusURL = nil
        subscriptionStatusURLVersion = nil
        subscriptionStatusURLForSandbox = nil
        subscriptionStatusURLVersionForSandbox = nil
        self.included = included
    }
}
#endif
