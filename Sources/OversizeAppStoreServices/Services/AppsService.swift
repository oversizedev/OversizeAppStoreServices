//
// Copyright © 2024 Alexander Romanov
// AppsService.swift, created on 22.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Factory
import Foundation
import OversizeCore
import OversizeModels

public actor AppsService {
    @Injected(\.cacheService) private var cacheService: CacheService
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchApp(id: String, force: Bool = false) async -> Result<App, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchApp\(id)", force: force) {
            let request = Resources.v1.apps.id(id).get()
            let response = try await client.send(request)
            return response.data
        }.flatMap { data in
            guard let app = App(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        }
    }

    public func fetchAppIncludeBuildsAndAppStoreVersions(id: String, force: Bool = false) async -> Result<App, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppIncludeBuildsAndAppStoreVersions\(id)", force: force) {
            let request = Resources.v1.apps.id(id).get(
                include: [
                    .builds,
                    .appStoreVersions,
                ]
            )
            return try await client.send(request)
        }.flatMap {
            guard let app = App(schema: $0.data, included: $0.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        }
    }

    public func fetchAppIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions(appId: String) async -> Result<App, AppError> {
        do {
            guard let client else {
                return .failure(.network(type: .unauthorized))
            }
            let request = Resources.v1.apps.id(appId).get(
                include: [
                    .builds,
                    .appStoreVersions,
                    .preReleaseVersions,
                ]
            )
            let result = try await client.send(request)
            guard let app: App = .init(schema: result.data, included: result.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchApps() async -> Result<[App], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.get()
        do {
            let data = try await client.send(request).data
            let apps: [App] = data.compactMap { .init(schema: $0) }
            return .success(apps)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppsIncludeAppStoreVersionsAndPreReleaseVersions() async -> Result<[App], AppError> {
        guard let client else {
            return .failure(.network(type: .unauthorized))
        }
        let request = Resources.v1.apps.get(
            include: [
                .appStoreVersions,
                .preReleaseVersions,
            ]
        )
        do {
            let result = try await client.send(request)
            let apps: [App] = result.data.compactMap { schema in
                let filteredIncluded = result.included?.filter { includedItem in
                    switch includedItem {
                    case let .appStoreVersion(appStoreVersion):
                        schema.relationships?.appStoreVersions?.data?.first(where: { $0.id == appStoreVersion.id }) != nil
                    case let .prereleaseVersion(prereleaseVersion):
                        schema.relationships?.preReleaseVersions?.data?.first(where: { $0.id == prereleaseVersion.id }) != nil
                    default:
                        false
                    }
                }
                return App(schema: schema, included: filteredIncluded)
            }
            return .success(apps)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppsIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions(forse: Bool = false) async -> Result<[App], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppsIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions", force: forse) {
            let request = Resources.v1.apps.get(
                include: [
                    .builds,
                    .appStoreVersions,
                    .preReleaseVersions,
                ]
            )
            return try await client.send(request)
        }.flatMap {
            .success(processAppsResponse($0))
        }
    }

    public func fetchAppsIncludeActualAppStoreVersionsAndBuilds(limitAppStoreVersions: Int? = nil) async -> Result<[App], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
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
            ],
            limitAppStoreVersions: limitAppStoreVersions
        )
        do {
            let result = try await client.send(request)
            let apps: [App] = result.data.compactMap { schema in
                let filteredIncluded = result.included?.filter { includedItem in
                    switch includedItem {
                    case let .appStoreVersion(appStoreVersion):
                        schema.relationships?.appStoreVersions?.data?.first(where: { $0.id == appStoreVersion.id }) != nil
                    case let .build(build):
                        schema.relationships?.builds?.data?.first(where: { $0.id == build.id }) != nil
                    default:
                        false
                    }
                }
                return App(schema: schema, included: filteredIncluded)
            }
            return .success(apps)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    func postBundleId(
        name: String,
        platform: BundleIDPlatform,
        identifier: String,
        seedID: String? = nil
    ) async -> Result<Bool, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        guard let bundleIDPlatform: AppStoreAPI.BundleIDPlatform = .init(rawValue: platform.rawValue) else { return .failure(.network(type: .invalidURL)) }

        let requestData: BundleIDCreateRequest.Data = .init(
            type: .bundleIDs,
            attributes: .init(
                name: name,
                platform: bundleIDPlatform,
                identifier: identifier,
                seedID: seedID
            )
        )

        let request = Resources.v1.bundleIDs.post(.init(data: requestData))
        do {
            _ = try await client.send(request).data
            return .success(true)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func patchPrimaryLanguage(
        appId: String,
        locale: AppStoreLanguage
    ) async -> Result<App, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData: AppUpdateRequest.Data = .init(
            type: .apps,
            id: appId,
            attributes: .init(primaryLocale: locale.rawValue)
        )
        let request = Resources.v1.apps.id(appId).patch(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let app = App(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            let replacements = ["@@LANGUAGE_VALUE@@": locale.displayName]
            return handleRequestFailure(error: error, replaces: replacements)
        }
    }
}

private extension AppsService {
    func processAppsResponse(_ response: AppsResponse) -> [App] {
        response.data.compactMap { schema in
            let filteredIncluded = response.included?.filter { includedItem in
                switch includedItem {
                case let .appStoreVersion(appStoreVersion):
                    schema.relationships?.appStoreVersions?.data?.contains(where: { $0.id == appStoreVersion.id }) ?? false
                case let .build(build):
                    schema.relationships?.builds?.data?.contains(where: { $0.id == build.id }) ?? false
                case let .prereleaseVersion(prereleaseVersion):
                    schema.relationships?.preReleaseVersions?.data?.contains(where: { $0.id == prereleaseVersion.id }) ?? false
                default:
                    false
                }
            }
            return App(schema: schema, included: filteredIncluded)
        }
    }

    func handleRequestFailure<T>(error: Error, replaces: [String: String] = [:]) -> Result<T, AppError> {
        if let responseError = error as? ResponseError {
            switch responseError {
            case let .requestFailure(errorResponse, _, _):
                if let errors = errorResponse?.errors, let firstError = errors.first {
                    var title = firstError.title
                    var detail = firstError.detail

                    for (placeholder, replacement) in replaces {
                        title = title.replacingOccurrences(of: placeholder, with: replacement)
                        detail = detail.replacingOccurrences(of: placeholder, with: replacement)
                    }

                    return .failure(AppError.network(type: .apiError(title, detail)))
                }
                return .failure(AppError.network(type: .unknown))
            default:
                return .failure(AppError.network(type: .unknown))
            }
        }
        return .failure(AppError.network(type: .unknown))
    }
}
