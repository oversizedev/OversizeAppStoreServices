//
// Copyright © 2024 Alexander Romanov
// AppsService.swift, created on 22.07.2024
//

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
            let apps: [App] = data.compactMap({ .init(schema: $0) })
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
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    public func fetchAppVersion(appId: String) async -> Result<[Version], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    public func fetchAppVersion(appId: String, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[Version], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get(filterPlatform: [platform])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    func fetchAllVersionLocalizations(forVersion versionId: String) async throws ->  Result<[(String, AppStoreLanguage)] , AppError> {
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
    
    public func fetchAppVersionLocalization(forVersion versionId: String) async -> Result<[VersionLocalization], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).appStoreVersionLocalizations.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    public func fetchAppInfo(forVersion versionId: String) async -> Result<[AppInfo], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(versionId).appInfos.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    public func fetchAppInfoWithCategory(forVersion versionId: String) async -> Result<[AppInfo], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(versionId).appInfos.get(include: [.primaryCategory, .secondaryCategory, .ageRatingDeclaration])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppInfoLocalizations(forInfo infoId: String) async -> Result<[AppInfoLocalization], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appInfos.id(infoId).appInfoLocalizations.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppCategoryIds(categoryId: String) async -> Result<[String], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appCategories.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ $0.id }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}

extension AppsService {
    
    public func fetchAppBuilds(_ app: App) async -> Result<[Build], AppError> {
        return await fetchAppBuilds(appId: app.id)
    }
    
    public func fetchAppVersion(_ app: App) async -> Result<[Version], AppError> {
        return await fetchAppVersion(appId: app.id)
    }
    
    public func fetchAppVersion(_ app: App, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[Version], AppError> {
        return await fetchAppVersion(appId: app.id, platform: platform)
    }
    
    public func fetchAppInfoLocalizations(_ info: AppInfo) async -> Result<[AppInfoLocalization], AppError> {
        return await fetchAppInfoLocalizations(forInfo: info.id)
    }
    
    public func fetchAppInfo(_ version: Version) async -> Result<[AppInfo], AppError> {
        return await fetchAppInfo(forVersion: version.id)
    }
    
}
