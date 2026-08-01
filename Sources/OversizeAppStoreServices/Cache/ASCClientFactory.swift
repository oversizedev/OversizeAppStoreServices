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
            transport: ASCCachingTransport(
                accountID: resolveCacheAccountID(for: authenticator, explicit: cacheAccountID),
            ),
            authenticator: authenticator,
        )
        #else
        AppStoreConnectClient(authenticator: authenticator)
        #endif
    }

    /// Resolves the account the caches are scoped to. Returns `nil` when the account cannot be
    /// determined, in which case caching is disabled rather than shared between accounts.
    public static func resolveCacheAccountID(
        for authenticator: some Authenticator,
        explicit: String? = nil,
    ) -> String? {
        if let explicit {
            return explicit
        }
        #if canImport(Darwin)
        if let envAuthenticator = authenticator as? EnvAuthenticator {
            return envAuthenticator.accountID?.uuidString
        }
        #endif
        return nil
    }
}
