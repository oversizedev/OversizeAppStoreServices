//
// Copyright © 2024 Alexander Romanov
// EnvAuthenticator.swift, created on 22.07.2024
//

import AppStoreConnect

public struct EnvAuthenticator: Authenticator {
    public enum Error: Swift.Error {
        case missingEnvironmentVariable(String)
    }

    var jwt: JWT

    private let secureStorage: SecureStorageService = .init()

    public init() throws {
        guard let appStoreCertificate = secureStorage.getAppStoreCertificate(with: "AppStore.KeyID") else {
            throw Error.missingEnvironmentVariable("AppStore.KeyID")
        }

        let privateKey = try JWT.PrivateKey(pemRepresentation: appStoreCertificate.privateKey)

        jwt = JWT(
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
