//
// Copyright © 2024 Alexander Romanov
// EnvAuthenticator.swift, created on 22.07.2024
//

#if canImport(Darwin)
import AppStoreConnect
import Foundation
import OversizeCore

public struct EnvAuthenticator: Authenticator {
    private let credentialsStorage = AppStoreConnectCredentialsStorage()
    private let configuredAPI: API
    private var jwt: JWT?
    public let accountID: UUID?
    public var api: API {
        configuredAPI
    }

    public init(
        api: API = .appStoreConnect,
        accountID: UUID? = nil,
    ) {
        configuredAPI = api
        self.accountID = accountID ?? UserDefaults.standard
            .string(forKey: "AppStore.Account")
            .flatMap(UUID.init(uuidString:))
    }

    public mutating func token() throws -> String {
        var resolvedJWT = try jwt ?? makeJWT()
        let token = try resolvedJWT.token()
        jwt = resolvedJWT
        return token
    }

    private func makeJWT() throws -> JWT {
        let resolvedAccountID = accountID ?? UserDefaults.standard
            .string(forKey: "AppStore.Account")
            .flatMap(UUID.init(uuidString:))
        guard let accountID = resolvedAccountID else {
            Log.error("Get UserDefaults value for 'AppStore.Account'")
            throw Error.missingEnvironmentVariable("AppStore.Account")
        }

        guard let credentials = credentialsStorage.credentials(for: accountID) else {
            Log.error("Get Keychain value for App Store Connect credentials")
            throw Error.missingEnvironmentVariable("AppStore.Key.Default")
        }

        let privateKey = try JWT.PrivateKey(pemRepresentation: credentials.privateKey)

        return JWT(
            api: configuredAPI,
            keyID: credentials.keyID,
            issuerID: credentials.issuerID,
            expiryDuration: 20 * 60,
            privateKey: privateKey,
        )
    }
}

public extension EnvAuthenticator {
    enum Error: Swift.Error {
        case missingEnvironmentVariable(String)
    }
}
#endif
