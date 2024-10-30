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

    public func patchBuild(platform _: Platform, versionId: String, buildId: String) async -> Result<AppStoreVersion, AppError> {
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
}
