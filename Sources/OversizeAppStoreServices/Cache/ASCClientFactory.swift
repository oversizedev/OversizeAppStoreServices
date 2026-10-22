//
// Copyright © 2026 Alexander Romanov
// ASCClientFactory.swift, created on 30.07.2026
//

import AppStoreConnect
import Foundation

public enum ASCClientFactory {
    public static func makeClient(
        authenticator: some Authenticator,
        cacheAccountID: String? = nil,
    ) -> AppStoreConnectClient {
        #if canImport(Darwin)
        AppStoreConnectClient(
            transport: ASCCachingTransport(accountID: cacheAccountID),
            authenticator: authenticator,
        )
        #else
        AppStoreConnectClient(authenticator: authenticator)
        #endif
    }
}
