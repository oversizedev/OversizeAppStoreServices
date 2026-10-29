//
// Copyright © 2026 Alexander Romanov
// BuildsServicesProtocol.swift, created on 29.10.2026
//

import Foundation

public protocol BuildsServicesProtocol: Sendable {
    func fetchBuild(buildId: String, forse: Bool) async -> Result<Build, Error>
    func fetchBuildDeviceFamilies(buildId: String, forse: Bool) async -> Result<BuildDeviceFamilies, Error>
    func fetchBuildBundlesId(buildBundlesId: String, forse: Bool) async -> Result<[BuildBundleFileSize], Error>
    func fetchBuildIcons(buildId: String, force: Bool) async -> Result<[BuildIconAsset], Error>
    func fetchAppBuilds(appId: String) async -> Result<[Build], Error>
    func fetchPreReleaseVersionBuilds(appId: String, versionString: String, platfrom: Platform) async -> Result<[Build], Error>
    func fetchAppStoreVersionsBuild(versionId: String) async -> Result<Build?, Error>
    func fetchAppStoreVersionsBuildImageUrl(versionId: String) async -> Result<URL?, Error>
}

// MARK: - Default-argument convenience

public extension BuildsServicesProtocol {
    func fetchBuild(buildId: String) async -> Result<Build, Error> {
        await fetchBuild(buildId: buildId, forse: false)
    }

    func fetchBuildDeviceFamilies(buildId: String) async -> Result<BuildDeviceFamilies, Error> {
        await fetchBuildDeviceFamilies(buildId: buildId, forse: false)
    }

    func fetchBuildBundlesId(buildBundlesId: String) async -> Result<[BuildBundleFileSize], Error> {
        await fetchBuildBundlesId(buildBundlesId: buildBundlesId, forse: false)
    }

    func fetchBuildIcons(buildId: String) async -> Result<[BuildIconAsset], Error> {
        await fetchBuildIcons(buildId: buildId, force: false)
    }
}
