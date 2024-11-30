//
// Copyright © 2024 Alexander Romanov
// BuildsService.swift, created on 29.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Factory
import Foundation
import OversizeCore
import OversizeModels

public actor BuildsService {
    @Injected(\.cacheService) private var cacheService: СacheService
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchBuild(buildId: String) async -> Result<Build, AppError> {
        let pathKey = "fetchBuild\(buildId)"
        if let cachedData: BuildResponse = cacheService.load(key: pathKey, as: BuildResponse.self),
           let build: Build = .init(schema: cachedData.data)
        {
            return .success(build)
        }
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.builds.id(buildId).get()
        do {
            let response = try await client.send(request)
            guard let build: Build = .init(schema: response.data) else {
                return .failure(.network(type: .decode))
            }
            cacheService.save(response, key: pathKey)
            return .success(build)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchBuildBundlesId(buildBundlesId: String) async -> Result<[BuildBundleFileSize], AppError> {
        let pathKey = "buildBundlesId\(buildBundlesId)"
        if let cachedResponse = cacheService.load(key: pathKey, as: BuildBundleFileSizesResponse.self) {
            return .success(cachedResponse.data.compactMap { .init(schema: $0) })
        }
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.buildBundles.id(buildBundlesId).buildBundleFileSizes.get()
        do {
            let response = try await client.send(request)
            cacheService.save(response, key: pathKey)
            return .success(response.data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppBuilds(appId: String) async -> Result<[Build], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.builds.get(filterApp: [appId])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchPreReleaseVersionBuilds(appId: String, versionString: String, platfrom: Platform) async -> Result<[Build], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        guard let preReleaseVersionPlatform: Resources.V1.Builds.FilterPreReleaseVersionPlatform = .init(rawValue: platfrom.rawValue) else {
            return .failure(.network(type: .invalidURL))
        }
        let request = Resources.v1.builds.get(filterPreReleaseVersionVersion: [versionString], filterPreReleaseVersionPlatform: [preReleaseVersionPlatform], filterApp: [appId])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppStoreVersionsBuild(versionId: String) async -> Result<Build?, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).build.get()
        do {
            let data = try await client.send(request).data
            return .success(.init(schema: data))
        } catch {
            return .success(nil)
        }
    }

    public func fetchAppStoreVersionsBuildImageUrl(versionId: String) async -> Result<URL?, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).build.get(
            fieldsBuilds: [.iconAssetToken]
        )
        do {
            let iconAssetToken = try await client.send(request).data.attributes?.iconAssetToken
            guard let templateURL = iconAssetToken?.templateURL else {
                return .success(nil)
            }
            let url = parseURL(
                from: constructURLString(
                    baseURL: templateURL,
                    width: iconAssetToken?.width ?? 100,
                    height: iconAssetToken?.height ?? 100,
                    format: "png"
                )
            )
            return .success(url)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
