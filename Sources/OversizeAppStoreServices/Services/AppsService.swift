//
// Copyright © 2024 Alexander Romanov
// AppsService.swift, created on 22.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeModels

public actor AppsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchApps() async -> Result<[App], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.get()
        do {
            let data = try await client.send(request).data
            let apps: [App] = data.compactMap { .init(schema: $0) }
            return .success(apps)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppBuilds(appId: String) async -> Result<[Build], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.builds.get(filterApp: [appId])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersions(appId: String) async -> Result<[Version], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersions(appId: String, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[Version], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get(filterPlatform: [platform])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    func fetchAllVersionLocalizations(forVersion versionId: String) async throws -> Result<[(String, AppStoreLanguage)], AppError> {
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

    public func fetchAppInfos(forVersion versionId: String) async -> Result<[AppInfo], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(versionId).appInfos.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppInfoWithCategory(forVersion versionId: String) async -> Result<[AppInfo], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(versionId).appInfos.get(include: [.primaryCategory, .secondaryCategory, .ageRatingDeclaration])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppInfoLocalizations(forInfo infoId: String) async -> Result<[AppInfoLocalization], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appInfos.id(infoId).appInfoLocalizations.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppCategoryIds() async -> Result<[String], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appCategories.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { $0.id })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func updateVersionLocalization(
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

    func createBundleId(
        name: String,
        platform: BundleIDPlatform,
        identifier: String,
        seedID: String? = nil
    ) async -> Result<Bool, AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }

        let requestData: BundleIDCreateRequest.Data = .init(
            type: .bundleIDs,
            attributes: .init(
                name: name,
                platform: platform,
                identifier: identifier,
                seedID: seedID
            )
        )

        let request = Resources.v1.bundleIDs.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            return .success(true)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}

public extension AppsService {
    func fetchAppBuilds(_ app: App) async -> Result<[Build], AppError> {
        return await fetchAppBuilds(appId: app.id)
    }

    func fetchAppVersions(_ app: App) async -> Result<[Version], AppError> {
        return await fetchAppVersions(appId: app.id)
    }

    func fetchAppVersions(_ app: App, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[Version], AppError> {
        return await fetchAppVersions(appId: app.id, platform: platform)
    }

    func fetchAppInfoLocalizations(_ info: AppInfo) async -> Result<[AppInfoLocalization], AppError> {
        return await fetchAppInfoLocalizations(forInfo: info.id)
    }

    func fetchAppInfos(_ version: Version) async -> Result<[AppInfo], AppError> {
        return await fetchAppInfos(forVersion: version.id)
    }
}
