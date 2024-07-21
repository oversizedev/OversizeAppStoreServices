import AppStoreConnect
import Foundation

public struct EnvAuthenticator: Authenticator {
    public enum Error: Swift.Error {
        case missingEnvironmentVariable(String)
    }

    var jwt: JWT

    public init() throws {
        guard let keyID = UserDefaults.standard.string(forKey: "AppStore.KeyID") else {
            throw Error.missingEnvironmentVariable("AppStore.KeyID")
        }
        guard let issuerID = UserDefaults.standard.string(forKey: "AppStore.IssuerID") else {
            throw Error.missingEnvironmentVariable("AppStore.IssuerID")
        }
        guard let privateKeyRepresentation = UserDefaults.standard.string(forKey: "AppStore.PrivateKey") else {
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
