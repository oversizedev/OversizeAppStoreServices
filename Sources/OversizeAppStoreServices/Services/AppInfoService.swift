//
// Copyright © 2024 Alexander Romanov
// BuildsService_2.swift, created on 30.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
import OversizeModels

public actor AppInfoService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }
}
