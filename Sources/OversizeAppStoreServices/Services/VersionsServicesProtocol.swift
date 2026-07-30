//
// Copyright © 2026 Alexander Romanov
// VersionsServicesProtocol.swift, created on 25.07.2026
//

import AppStoreAPI
import Foundation

public protocol VersionsServicesProtocol: Sendable {
    func fetchAppStoreVersion(appStoreVersionId: String) async -> Result<AppStoreVersion, Error>
    func fetchAppVersions(appId: String, platform: Platform?, force: Bool) async -> Result<[AppStoreVersion], Error>
    func fetchEditableAppStoreVersion(appId: String, platform: Platform?, force: Bool) async -> Result<[AppStoreVersion], Error>
    func fetchRelisedAppVersions(appId: String) async -> Result<[AppStoreVersion], Error>
    func fetchActualAppStoreVersions(appId: String, platform: Platform?, force: Bool) async -> Result<[AppStoreVersion], Error>
    func fetchActualAppStoreVersionsIncludeBuilds(appId: String, platform: Platform?, limit: Int?, force: Bool) async -> Result<[AppStoreVersion], Error>
    func fetchAppVersions(appId: String, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], Error>
    func fetchAllVersionLocalizations(forVersion versionId: String) async throws -> Result<[(String, AppStoreLanguage)], Error>
    func fetchAppVersionLocalizations(versionId: String, force: Bool) async -> Result<[AppStoreVersionLocalization], Error>
    func patchBuild(versionId: String, buildId: String) async -> Result<AppStoreVersion, Error>
    func postAppStoreVersionLocalization(
        appStoreVersionsId: String,
        locale: AppStoreLanguage,
        whatsNew: String?,
        description: String?,
        promotionalText: String?,
        keywords: String?,
        marketingURL: URL?,
        supportURL: URL?,
    ) async -> Result<AppStoreVersionLocalization, Error>
    func patchVersionLocalization(
        localizationId: String,
        whatsNew: String?,
        description: String?,
        promotionalText: String?,
        keywords: String?,
        marketingURL: URL?,
        supportURL: URL?,
    ) async -> Result<AppStoreVersionLocalization, Error>
    func patchVersion(
        versionId: String,
        versionString: String?,
        copyright: String?,
        reviewType: ReviewType?,
        releaseType: ReleaseType?,
        earliestReleaseDate: Date?,
        isDownloadable: Bool?,
    ) async -> Result<AppStoreVersion, Error>
    func postVersion(
        appId: String,
        platform: Platform,
        versionString: String,
        copyright: String?,
        reviewType: ReviewType?,
        releaseType: ReleaseType?,
        earliestReleaseDate: Date?,
    ) async -> Result<AppStoreVersion, Error>
    func deleteAppStoreVersionLocalizationsLocalization(localizationId: String) async -> Result<Bool, Error>
}

// MARK: - Default-argument convenience

/// Protocol requirements cannot declare default parameter values, so the short call shapes
/// used across the app are restored here. Each convenience uses a strictly smaller, unique
/// label set than its requirement, keeping overload resolution unambiguous.
public extension VersionsServicesProtocol {
    func fetchAppVersions(appId: String) async -> Result<[AppStoreVersion], Error> {
        await fetchAppVersions(appId: appId, platform: nil, force: false)
    }

    func fetchAppVersions(appId: String, force: Bool) async -> Result<[AppStoreVersion], Error> {
        await fetchAppVersions(appId: appId, platform: nil, force: force)
    }

    func fetchEditableAppStoreVersion(appId: String) async -> Result<[AppStoreVersion], Error> {
        await fetchEditableAppStoreVersion(appId: appId, platform: nil, force: false)
    }

    func fetchEditableAppStoreVersion(appId: String, force: Bool) async -> Result<[AppStoreVersion], Error> {
        await fetchEditableAppStoreVersion(appId: appId, platform: nil, force: force)
    }

    func fetchAppVersionLocalizations(versionId: String) async -> Result<[AppStoreVersionLocalization], Error> {
        await fetchAppVersionLocalizations(versionId: versionId, force: false)
    }

    func postVersion(appId: String, platform: Platform, versionString: String) async -> Result<AppStoreVersion, Error> {
        await postVersion(
            appId: appId,
            platform: platform,
            versionString: versionString,
            copyright: nil,
            reviewType: nil,
            releaseType: nil,
            earliestReleaseDate: nil,
        )
    }

    func patchVersion(
        versionId: String,
        versionString: String?,
        copyright: String?,
        releaseType: ReleaseType?,
        earliestReleaseDate: Date?,
    ) async -> Result<AppStoreVersion, Error> {
        await patchVersion(
            versionId: versionId,
            versionString: versionString,
            copyright: copyright,
            reviewType: nil,
            releaseType: releaseType,
            earliestReleaseDate: earliestReleaseDate,
            isDownloadable: nil,
        )
    }

    func patchVersionLocalization(localizationId: String, whatsNew: String?) async -> Result<AppStoreVersionLocalization, Error> {
        await patchVersionLocalization(
            localizationId: localizationId,
            whatsNew: whatsNew,
            description: nil,
            promotionalText: nil,
            keywords: nil,
            marketingURL: nil,
            supportURL: nil,
        )
    }

    func patchVersionLocalization(localizationId: String, promotionalText: String?) async -> Result<AppStoreVersionLocalization, Error> {
        await patchVersionLocalization(
            localizationId: localizationId,
            whatsNew: nil,
            description: nil,
            promotionalText: promotionalText,
            keywords: nil,
            marketingURL: nil,
            supportURL: nil,
        )
    }

    func patchVersionLocalization(localizationId: String, keywords: String?) async -> Result<AppStoreVersionLocalization, Error> {
        await patchVersionLocalization(
            localizationId: localizationId,
            whatsNew: nil,
            description: nil,
            promotionalText: nil,
            keywords: keywords,
            marketingURL: nil,
            supportURL: nil,
        )
    }

    func patchVersionLocalization(
        localizationId: String,
        whatsNew: String?,
        description: String?,
        promotionalText: String?,
        marketingURL: URL?,
        supportURL: URL?,
    ) async -> Result<AppStoreVersionLocalization, Error> {
        await patchVersionLocalization(
            localizationId: localizationId,
            whatsNew: whatsNew,
            description: description,
            promotionalText: promotionalText,
            keywords: nil,
            marketingURL: marketingURL,
            supportURL: supportURL,
        )
    }

    func fetchAppVersions(_ app: App) async -> Result<[AppStoreVersion], Error> {
        await fetchAppVersions(appId: app.id)
    }

    func fetchAppVersions(_ app: App, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], Error> {
        await fetchAppVersions(appId: app.id, platform: platform)
    }
}
