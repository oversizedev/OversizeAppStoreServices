//
// Copyright © 2024 Alexander Romanov
// EnvAuthenticator.swift, created on 22.07.2024
//

#if canImport(Darwin)
import AppStoreConnect
import Foundation
import OversizeCore
import OversizeServices

public struct EnvAuthenticator: Authenticator {
    private let storage: SecureStorageService = .init()
    private let configuredAPI: API
    private var jwt: JWT?
    public var api: API {
        configuredAPI
    }

    public init(
        api: API = .appStoreConnect,
    ) {
        configuredAPI = api
    }

    public mutating func token() throws -> String {
        var resolvedJWT = try jwt ?? makeJWT()
        let token = try resolvedJWT.token()
        jwt = resolvedJWT
        return token
    }

    private func makeJWT() throws -> JWT {
        guard let keyLabel = UserDefaults.standard.string(forKey: "AppStore.Account") else {
            logError("Get UserDefaults value for 'AppStore.Account'")
            throw Error.missingEnvironmentVariable("AppStore.Account")
        }

        guard let appStoreIssuerID = storage.getPassword(for: "DevConnector-IssuerID-" + keyLabel) else {
            logError("Get Keychain value for IssuerID")
            throw Error.missingEnvironmentVariable("AppStore.Key.Default")
        }

        guard let appStoreCertificate = storage.getCredentials(with: "DevConnector-Certificate-" + keyLabel) else {
            logError("Get Keychain value for Certificate")
            throw Error.missingEnvironmentVariable("AppStore.Key.Default")
        }

        let privateKey = try JWT.PrivateKey(pemRepresentation: appStoreCertificate.password)

        return JWT(
            api: configuredAPI,
            keyID: appStoreCertificate.login,
            issuerID: appStoreIssuerID,
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
