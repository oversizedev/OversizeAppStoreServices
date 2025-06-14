//
// Copyright © 2024 Alexander Romanov
// EnvAuthenticator.swift, created on 22.07.2024
//

import AppStoreConnect
import FactoryKit
import Foundation
import OversizeCore
import OversizeServices

public struct EnvAuthenticator: Authenticator {
    private let storage: SecureStorageService = .init()
    private var jwt: JWT
    public var api: API { jwt.api }

    public init(
        api: API = .appStoreConnect

    ) throws {
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

        jwt = JWT(
            api: api,
            keyID: appStoreCertificate.login,
            issuerID: appStoreIssuerID,
            expiryDuration: 20 * 60,
            privateKey: privateKey,
        )
    }

    public mutating func token() throws -> String {
        try jwt.token()
    }
}

public extension EnvAuthenticator {
    enum Error: Swift.Error {
        case missingEnvironmentVariable(String)
    }
}
