//
// Copyright © 2024 Alexander Romanov
// BuildsService.swift, created on 29.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public actor BuildsService {
    private let cacheService: CacheService
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator, cacheService: CacheService = CacheService()) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
        self.cacheService = cacheService
    }

    public func fetchBuild(buildId: String, forse: Bool = false) async -> Result<Build, Error> {

        return await cacheService.fetchWithCache(key: "fetchBuild\(buildId)", force: forse) {
            let request = Resources.v1.builds.id(buildId).get()
            return try await client.send(request)
        }.flatMap {
            guard let build: Build = .init(schema: $0.data) else {
                return .failure(NetworkError.decode)
            }
            return .success(build)
        }
    }

    public func fetchBuildBundlesId(buildBundlesId: String, forse: Bool = false) async -> Result<[BuildBundleFileSize], Error> {

        return await cacheService.fetchWithCache(key: "buildBundlesId\(buildBundlesId)", force: forse) {
            let request = Resources.v1.buildBundles.id(buildBundlesId).buildBundleFileSizes.get()
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchAppBuilds(appId: String) async -> Result<[Build], Error> {

        let request = Resources.v1.builds.get(filterApp: [appId])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchPreReleaseVersionBuilds(appId: String, versionString: String, platfrom: Platform) async -> Result<[Build], Error> {

        guard let preReleaseVersionPlatform: Resources.V1.Builds.FilterPreReleaseVersionPlatform = .init(rawValue: platfrom.rawValue) else {
            return .failure(NetworkError.invalidURL)
        }
        let request = Resources.v1.builds.get(filterPreReleaseVersionVersion: [versionString], filterPreReleaseVersionPlatform: [preReleaseVersionPlatform], filterApp: [appId])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchAppStoreVersionsBuild(versionId: String) async -> Result<Build?, Error> {

        let request = Resources.v1.appStoreVersions.id(versionId).build.get()
        do {
            let data = try await client.send(request).data
            return .success(.init(schema: data))
        } catch {
            return .success(nil)
        }
    }

    public func fetchAppStoreVersionsBuildImageUrl(versionId: String) async -> Result<URL?, Error> {

        let request = Resources.v1.appStoreVersions.id(versionId).build.get(
            fieldsBuilds: [.iconAssetToken],
        )
        do {
            let iconAssetToken = try await client.send(request).data.attributes?.iconAssetToken
            guard let iconAssetToken else {
                return .success(nil)
            }
            let imageAsset = ImageAsset(schema: iconAssetToken)
            return .success(imageAsset.imageURL)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
