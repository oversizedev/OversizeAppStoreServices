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
        guard let keyID = secureStorage.getKeychain(forKey: "AppStore.KeyID") else {
            throw Error.missingEnvironmentVariable("AppStore.KeyID")
        }
        guard let issuerID = secureStorage.getKeychain(forKey: "AppStore.IssuerID") else {
            throw Error.missingEnvironmentVariable("AppStore.IssuerID")
        }
        guard let privateKeyRepresentation = secureStorage.getKeychain(forKey: "AppStore.PrivateKey") else {
            throw Error.missingEnvironmentVariable("AppStore.PrivateKey")
        }

        let privateKey = try JWT.PrivateKey(pemRepresentation: privateKeyRepresentation)

        jwt = JWT(
            keyID: keyID,
            issuerID: issuerID,
            expiryDuration: 20 * 60,
            privateKey: privateKey
        )
    }

    public mutating func token() throws -> String {
        try jwt.token()
    }
}
