//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionSubmissionsService.swift, created on 15.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
import OversizeModels
import OversizeAppStoreModels

public actor AppStoreVersionSubmissionsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func postAppStoreVersionSubmission(appStoreVersionsId _: String) async -> Result<String, AppError> {
        .failure(.network(type: .noResponse))
    }
}
