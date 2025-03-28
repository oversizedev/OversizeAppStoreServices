//
// Copyright © 2024 Alexander Romanov
// VersionService.swift, created on 29.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Factory
import Foundation
import OversizeModels

public actor VersionsService {
    @Injected(\.cacheService) private var cacheService: CacheService
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppStoreVersion(appStoreVersionId: String) async -> Result<AppStoreVersion, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(appStoreVersionId).get()
        do {
            let data = try await client.send(request).data
            guard let appStoreVersion: AppStoreVersion = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(appStoreVersion)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersions(appId: String, platform: Platform? = nil, force: Bool = false) async -> Result<[AppStoreVersion], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let filterPlatforms: [Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform]? = if let platform, let filteredPlatform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform = .init(rawValue: platform.rawValue) {
            [filteredPlatform]
        } else {
            nil
        }
        return await cacheService.fetchWithCache(key: "fetchAppVersions\(appId)\(platform?.rawValue ?? "")", force: force) {
            let request = Resources.v1.apps.id(appId).appStoreVersions.get(filterPlatform: filterPlatforms)
            let response = try await client.send(request)
            return response.data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchEditableAppStoreVersion(appId: String, platform: Platform? = nil, force: Bool = false) async -> Result<[AppStoreVersion], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let filterPlatforms: [Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform]? = if let platform, let filteredPlatform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform = .init(rawValue: platform.rawValue) {
            [filteredPlatform]
        } else {
            nil
        }
        return await cacheService.fetchWithCache(key: "fetchEditableAppStoreVersion\(appId)\(platform?.rawValue ?? "")", force: force) {
            let request = Resources.v1.apps.id(appId).appStoreVersions.get(
                filterPlatform: filterPlatforms,
                filterAppVersionState: [
                    .prepareForSubmission,
                    .metadataRejected,
                    .developerRejected,
                    .rejected,
                    .invalidBinary,
                ]
            )
            let response = try await client.send(request)
            return response.data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchRelisedAppVersions(appId: String) async -> Result<[AppStoreVersion], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get(
            filterAppVersionState: [
                .replacedWithNewVersion,
                .readyForDistribution,
            ]
        )
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchActualAppStoreVersions(appId: String, platform: Platform? = nil, force: Bool = false) async -> Result<[AppStoreVersion], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let filterPlatforms: [Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform]? = if let platform, let filteredPlatform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform = .init(rawValue: platform.rawValue) {
            [filteredPlatform]
        } else {
            nil
        }
        return await cacheService.fetchWithCache(key: "fetchActualAppStoreVersions\(appId)\(platform?.rawValue ?? "")", force: force) {
            let request = Resources.v1.apps.id(appId).appStoreVersions.get(
                filterPlatform: filterPlatforms,
                filterAppVersionState: [
                    .accepted,
                    .developerRejected,
                    .inReview,
                    .invalidBinary,
                    .metadataRejected,
                    .pendingAppleRelease,
                    .pendingDeveloperRelease,
                    .prepareForSubmission,
                    .processingForDistribution,
                    .readyForDistribution,
                    .readyForReview,
                    .rejected,
                    .waitingForExportCompliance,
                    .waitingForReview,
                ]
            )
            let response = try await client.send(request)
            return response.data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchActualAppStoreVersionsIncludeBuilds(appId: String, platform: Platform? = nil, limit: Int? = nil, force: Bool = false) async -> Result<[AppStoreVersion], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let filterPlatforms: [Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform]? = if let platform, let filteredPlatform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform = .init(rawValue: platform.rawValue) {
            [filteredPlatform]
        } else {
            nil
        }
        return await cacheService.fetchWithCache(key: "fetchActualAppStoreVersionsIncludeBuilds\(appId)\(platform?.rawValue ?? "")", force: force) {
            let request = Resources.v1.apps.id(appId).appStoreVersions.get(
                filterPlatform: filterPlatforms,
                filterAppVersionState: [
                    .accepted,
                    .developerRejected,
                    .inReview,
                    .invalidBinary,
                    .metadataRejected,
                    .pendingAppleRelease,
                    .pendingDeveloperRelease,
                    .prepareForSubmission,
                    .processingForDistribution,
                    .readyForDistribution,
                    .readyForReview,
                    .rejected,
                    .waitingForExportCompliance,
                    .waitingForReview,
                ],
                limit: limit,
                include: [
                    .build,
                    .appStoreVersionLocalizations,
                ]
            )

            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }

    public func fetchAppVersions(appId: String, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get(filterPlatform: [platform])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAllVersionLocalizations(forVersion versionId: String) async throws -> Result<[(String, AppStoreLanguage)], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).appStoreVersionLocalizations.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { localization in
                guard let locale = localization.attributes?.locale, let language = AppStoreLanguage(rawValue: locale) else {
                    return nil
                }
                return (localization.id, language)
            }
            )
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersionLocalizations(versionId: String, force: Bool = false) async -> Result<[AppStoreVersionLocalization], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppVersionLocalizations\(versionId)", force: force) {
            let request = Resources.v1.appStoreVersions.id(versionId).appStoreVersionLocalizations.get()
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func patchBuild(versionId: String, buildId: String) async -> Result<AppStoreVersion, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let relationships: AppStoreVersionUpdateRequest.Data.Relationships = .init(
            build: .init(data: .init(type: .builds, id: buildId))
        )

        let requestData: AppStoreVersionUpdateRequest.Data = .init(
            type: .appStoreVersions,
            id: versionId,
            relationships: relationships
        )

        let request = Resources.v1.appStoreVersions.id(versionId).patch(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: AppStoreVersion = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func postAppStoreVersionLocalization(
        appStoreVersionsId: String,
        locale: AppStoreLanguage,
        whatsNew: String? = nil,
        description: String? = nil,
        promotionalText: String? = nil,
        keywords: String? = nil,
        marketingURL: URL? = nil,
        supportURL: URL? = nil
    ) async -> Result<AppStoreVersionLocalization, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppStoreVersionLocalizationCreateRequest.Data.Attributes = .init(
            description: description,
            locale: locale.rawValue,
            keywords: keywords,
            marketingURL: marketingURL,
            promotionalText: promotionalText,
            supportURL: supportURL,
            whatsNew: whatsNew
        )

        let requestRelationships: AppStoreVersionLocalizationCreateRequest.Data.Relationships = .init(
            appStoreVersion: .init(data: .init(type: .appStoreVersions, id: appStoreVersionsId))
        )

        let requestData: AppStoreVersionLocalizationCreateRequest.Data = .init(
            type: .appStoreVersionLocalizations,
            attributes: requestAttributes,
            relationships: requestRelationships
        )

        let request = Resources.v1.appStoreVersionLocalizations.post(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: AppStoreVersionLocalization = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func patchVersionLocalization(
        localizationId: String,
        whatsNew: String? = nil,
        description: String? = nil,
        promotionalText: String? = nil,
        keywords: String? = nil,
        marketingURL: URL? = nil,
        supportURL: URL? = nil
    ) async -> Result<AppStoreVersionLocalization, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppStoreVersionLocalizationUpdateRequest.Data.Attributes = .init(
            description: description,
            keywords: keywords,
            marketingURL: marketingURL,
            promotionalText: promotionalText,
            supportURL: supportURL,
            whatsNew: whatsNew
        )

        let requestData: AppStoreVersionLocalizationUpdateRequest.Data = .init(
            type: .appStoreVersionLocalizations,
            id: localizationId,
            attributes: requestAttributes
        )

        let request = Resources.v1.appStoreVersionLocalizations.id(localizationId).patch(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: AppStoreVersionLocalization = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func patchVersion(
        versionId: String,
        versionString: String? = nil,
        copyright: String? = nil,
        reviewType: ReviewType? = nil,
        releaseType: ReleaseType? = nil,
        earliestReleaseDate _: Date? = nil,
        isDownloadable: Bool? = nil
    ) async -> Result<AppStoreVersion, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppStoreVersionUpdateRequest.Data.Attributes = .init(
            versionString: versionString,
            copyright: copyright,
            reviewType: .init(rawValue: reviewType?.rawValue ?? ""),
            releaseType: .init(rawValue: releaseType?.rawValue ?? ""),
            // earliestReleaseDate: earliestReleaseDate,
            isDownloadable: isDownloadable
        )

        let requestData: AppStoreVersionUpdateRequest.Data = .init(
            type: .appStoreVersions,
            id: versionId,
            attributes: requestAttributes
        )

        let request = Resources.v1.appStoreVersions.id(versionId).patch(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: AppStoreVersion = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func postVersion(
        appId: String,
        platform: Platform,
        versionString: String,
        copyright: String? = nil,
        reviewType: ReviewType? = nil,
        releaseType: ReleaseType? = nil,
        earliestReleaseDate: Date? = nil
    ) async -> Result<AppStoreVersion, AppError> {
        guard let client, let platform: AppStoreAPI.Platform = .init(rawValue: platform.rawValue) else {
            return .failure(.network(type: .unauthorized))
        }

        let requestAttributes: AppStoreVersionCreateRequest.Data.Attributes = .init(
            platform: platform,
            versionString: versionString,
            copyright: copyright,
            reviewType: .init(rawValue: reviewType?.rawValue ?? ""),
            releaseType: .init(rawValue: releaseType?.rawValue ?? ""),
            earliestReleaseDate: earliestReleaseDate
        )

        let requestData: AppStoreVersionCreateRequest.Data = .init(
            type: .appStoreVersions,
            attributes: requestAttributes,
            relationships: .init(
                app: .init(data: .init(id: appId)),
                appStoreVersionLocalizations: nil,
                build: nil
            )
        )

        let request = Resources.v1.appStoreVersions.post(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let appStoreVersion: AppStoreVersion = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(appStoreVersion)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func deleteAppStoreVersionLocalizationsLocalization(localizationId: String) async -> Result<Bool, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersionLocalizations.id(localizationId).delete
        do {
            let _ = try await client.send(request)
            return .success(true)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}

public extension VersionsService {
    func fetchAppVersions(_ app: App) async -> Result<[AppStoreVersion], AppError> {
        await fetchAppVersions(appId: app.id)
    }

    func fetchAppVersions(_ app: App, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], AppError> {
        await fetchAppVersions(appId: app.id, platform: platform)
    }
}
