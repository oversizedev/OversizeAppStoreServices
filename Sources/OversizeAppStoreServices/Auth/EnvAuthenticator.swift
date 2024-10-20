//
// Copyright © 2024 Alexander Romanov
// EnvAuthenticator.swift, created on 22.07.2024
//

import AppStoreConnect
import Foundation

public struct EnvAuthenticator: Authenticator {
    private let secureStorage: KeychainService = .init()

    private var jwt: JWT

    public var api: API { jwt.api }

    public init(
        api: API = .appStoreConnect

    ) throws {
        guard let keyLabel = UserDefaults.standard.string(forKey: "AppStore.Account") else {
            throw Error.missingEnvironmentVariable("AppStore.Account")
        }

        guard let appStoreCertificate = secureStorage.getAppStoreCertificate(with: keyLabel) else {
            throw Error.missingEnvironmentVariable("AppStore.Key.Default")
        }

        let privateKey = try JWT.PrivateKey(pemRepresentation: appStoreCertificate.privateKey)

        jwt = JWT(
            api: api,
            keyID: appStoreCertificate.keyId,
            issuerID: appStoreCertificate.issuerId,
            expiryDuration: 20 * 60,
            privateKey: privateKey
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
