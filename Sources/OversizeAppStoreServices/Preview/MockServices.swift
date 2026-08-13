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
