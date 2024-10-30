//
// Copyright © 2024 Alexander Romanov
// AppsService.swift, created on 22.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
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

    public func fetchAppsIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions() async -> Result<[App], AppError> {
        do {
            guard let client = client else {
                return .failure(.network(type: .unauthorized))
            }
            let request = Resources.v1.apps.get(
                include: [
                    .builds,
                    .appStoreVersions,
                    .preReleaseVersions,
                ]
            )
            let result = try await client.send(request)
            let apps: [App] = result.data.compactMap { schema in
                let filteredIncluded = result.included?.filter { includedItem in
                    switch includedItem {
                    case let .appStoreVersion(appStoreVersion):
                        return schema.relationships?.appStoreVersions?.data?.first(where: { $0.id == appStoreVersion.id }) != nil
                    case let .build(build):
                        return schema.relationships?.builds?.data?.first(where: { $0.id == build.id }) != nil
                    case let .prereleaseVersion(prereleaseVersion):
                        return schema.relationships?.preReleaseVersions?.data?.first(where: { $0.id == prereleaseVersion.id }) != nil
                    default:
                        return false
                    }
                }
                return App(schema: schema, included: filteredIncluded)
            }
            return .success(apps)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppsIncludeActualAppStoreVersionsAndBuilds() async -> Result<[App], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.get(
            filterAppStoreVersionsAppStoreState: [
                .accepted,
                .developerRemovedFromSale,
                .developerRejected,
                .inReview,
                .invalidBinary,
                .metadataRejected,
                .pendingAppleRelease,
                .pendingContract,
                .pendingDeveloperRelease,
                .prepareForSubmission,
                .preorderReadyForSale,
                .processingForAppStore,
                .readyForReview,
                .readyForSale,
                .rejected,
                .removedFromSale,
                .waitingForExportCompliance,
                .waitingForReview,
                .notApplicable,
            ],
            include: [
                .builds,
                .appStoreVersions,
            ]
        )
        do {
            let result = try await client.send(request)
            let apps: [App] = result.data.compactMap { schema in
                let filteredIncluded = result.included?.filter { includedItem in
                    switch includedItem {
                    case let .appStoreVersion(appStoreVersion):
                        return schema.relationships?.appStoreVersions?.data?.first(where: { $0.id == appStoreVersion.id }) != nil
                    case let .build(build):
                        return schema.relationships?.builds?.data?.first(where: { $0.id == build.id }) != nil
                    default:
                        return false
                    }
                }
                return App(schema: schema, included: filteredIncluded)
            }
            return .success(apps)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersions(appId: String) async -> Result<[AppStoreVersion], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0, builds: []) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersions(appId: String, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appStoreVersions.get(filterPlatform: [platform])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0, builds: []) })
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
    func fetchAppVersions(_ app: App) async -> Result<[AppStoreVersion], AppError> {
        return await fetchAppVersions(appId: app.id)
    }

    func fetchAppVersions(_ app: App, platform: Resources.V1.Apps.WithID.AppStoreVersions.FilterPlatform) async -> Result<[AppStoreVersion], AppError> {
        return await fetchAppVersions(appId: app.id, platform: platform)
    }
}
