//
// Copyright © 2024 Alexander Romanov
// BuildsService.swift, created on 29.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
import OversizeModels

public actor BuildsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
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

    public func fetchPreReleaseVersionBuilds(appId: String, versionString: String, platfrom: Platform) async -> Result<[Build], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
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
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).build.get()
        do {
            let data = try await client.send(request).data
            return .success(.init(schema: data))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
