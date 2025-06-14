//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionSubmissionsService.swift, created on 15.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
import OversizeModels

public actor AppStoreVersionSubmissionsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func postAppStoreVersionSubmission(appStoreVersionsId: String) async -> Result<String, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData: AppStoreVersionSubmissionCreateRequest.Data = .init(
            type: .appStoreVersionSubmissions,
            relationships: .init(
                appStoreVersion: .init(
                    data: .init(
                        type: .appStoreVersions,
                        id: appStoreVersionsId,
                    ),
                ),
            ),
        )

        let request = Resources.v1.appStoreVersionSubmissions.post(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            return .success(data.id)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
