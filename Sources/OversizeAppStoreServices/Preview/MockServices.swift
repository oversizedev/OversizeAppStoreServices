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
        .success([MockAppStoreData.appStoreVersion])
    }

    public func fetchEditableAppStoreVersion(appId _: String, platform _: Platform?, force _: Bool) async -> Result<[AppStoreVersion], Error> {
        .success([MockAppStoreData.appStoreVersion])
    }

    public func fetchRelisedAppVersions(appId _: String) async -> Result<[AppStoreVersion], Error> {
        .success([MockAppStoreData.appStoreVersion])
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

enum MockAppStoreData {
    static var appStoreVersion: AppStoreVersion {
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
