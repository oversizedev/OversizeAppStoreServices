import AppStoreConnect
import Foundation

public struct CredentialsAuthenticator: Authenticator {
    public let api: API
    private let credentials: AppStoreConnectCredentials
    private var jwt: JWT?

    public init(credentials: AppStoreConnectCredentials, api: API = .appStoreConnect) {
        self.credentials = credentials
        self.api = api
    }

    public mutating func token() throws -> String {
        var resolvedJWT = try jwt ?? makeJWT()
        let token = try resolvedJWT.token()
        jwt = resolvedJWT
        return token
    }

    private func makeJWT() throws -> JWT {
        let privateKey: JWT.PrivateKey
        do {
            privateKey = try JWT.PrivateKey(pemRepresentation: credentials.privateKey)
        } catch {
            throw ASCAuthenticationError.invalidPrivateKey(error)
        }
        return JWT(
            api: api,
            keyID: credentials.keyID,
            issuerID: credentials.issuerID,
            expiryDuration: 20 * 60,
            privateKey: privateKey,
        )
    }
}

public enum ASCAuthenticationError: Error, LocalizedError {
    case missingCredentials
    case invalidPrivateKey(any Error)

    public var errorDescription: String? {
        switch self {
        case .missingCredentials:
            "App Store Connect credentials are not configured."
        case let .invalidPrivateKey(error):
            "Invalid App Store Connect private key: \(error.localizedDescription)"
        }
    }
}
