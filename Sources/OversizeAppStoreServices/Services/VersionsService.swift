//
// Copyright © 2024 Alexander Romanov
// VersionService.swift, created on 29.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeModels

public actor VersionsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppVersions(appId: String) async -> Result<[AppStoreVersion], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersions(appId: String, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get(filterPlatform: [platform])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAllVersionLocalizations(forVersion versionId: String) async throws -> Result<[(String, AppStoreLanguage)], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
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

    public func fetchAppVersionLocalizations(forVersion versionId: String) async -> Result<[VersionLocalization], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).appStoreVersionLocalizations.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func patchBuild(versionId: String, buildId: String) async -> Result<AppStoreVersion, AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }

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

    public func patchVersionLocalization(
        localizationId: String,
        whatsNew: String? = nil,
        description: String? = nil,
        promotionalText: String? = nil,
        keywords: String? = nil,
        marketingURL: URL? = nil,
        supportURL: URL? = nil
    ) async -> Result<VersionLocalization, AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }

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
            guard let versionLocalization: VersionLocalization = .init(schema: data) else {
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
        guard let client = client else { return .failure(.network(type: .unauthorized)) }

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
        guard let client = client, let platform: AppStoreAPI.Platform = .init(rawValue: platform.rawValue) else {
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
            guard let versionLocalization: AppStoreVersion = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}

public extension VersionsService {
    func fetchAppVersions(_ app: App) async -> Result<[AppStoreVersion], AppError> {
        return await fetchAppVersions(appId: app.id)
    }

    func fetchAppVersions(_ app: App, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], AppError> {
        return await fetchAppVersions(appId: app.id, platform: platform)
    }
}
