//
// Copyright © 2026 Alexander Romanov
// AppsServicesProtocol.swift, created on 25.07.2026
//

import Foundation

public protocol AppsServicesProtocol: Sendable {
    func fetchApp(id: String, force: Bool) async -> Result<App, Error>
    func fetchAppIncludeBuildsAndAppStoreVersions(id: String, force: Bool) async -> Result<App, Error>
    func fetchAppIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions(appId: String) async -> Result<App, Error>
    func fetchApps() async -> Result<[App], Error>
    func fetchAppsIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions(forse: Bool) async -> Result<[App], Error>
    func fetchAppsIncludeActualAppStoreVersionsAndBuilds(limitAppStoreVersions: Int?, forse: Bool) async -> Result<[App], Error>
    func patchPrimaryLanguage(appId: String, locale: AppStoreLanguage) async -> Result<App, Error>
}

// MARK: - Default-argument convenience

/// Protocol requirements cannot declare default parameter values, so short call shapes
/// used across the app are restored here. Each convenience uses a strictly smaller,
/// unique label set than its requirement, so overload resolution stays unambiguous.
public extension AppsServicesProtocol {
    func fetchApp(id: String) async -> Result<App, Error> {
        await fetchApp(id: id, force: false)
    }

    func fetchAppIncludeBuildsAndAppStoreVersions(id: String) async -> Result<App, Error> {
        await fetchAppIncludeBuildsAndAppStoreVersions(id: id, force: false)
    }

    func fetchAppsIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions() async -> Result<[App], Error> {
        await fetchAppsIncludeAppStoreVersionsAndBuildsAndPreReleaseVersions(forse: false)
    }

    func fetchAppsIncludeActualAppStoreVersionsAndBuilds(limitAppStoreVersions: Int? = nil) async -> Result<[App], Error> {
        await fetchAppsIncludeActualAppStoreVersionsAndBuilds(limitAppStoreVersions: limitAppStoreVersions, forse: false)
    }
}
