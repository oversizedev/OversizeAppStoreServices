//
// Copyright © 2024 Alexander Romanov
// InAppPurchasesService.swift, created on 22.07.2024
//

import AppStoreConnect
import Foundation
import OversizeModels

public actor InAppPurchasesService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }
}
