import AppStoreConnect
import Foundation

public struct ASCAccountConfiguration: Sendable {
    public let accountID: UUID
    public let credentials: AppStoreConnectCredentials

    public init(accountID: UUID, credentials: AppStoreConnectCredentials) {
        self.accountID = accountID
        self.credentials = credentials
    }
}

public struct ASCServiceContext: Sendable {
    public let authenticator: any Authenticator
    public let cacheAccountID: String?

    public init(configuration: Result<ASCAccountConfiguration, Error>) {
        switch configuration {
        case let .success(configuration):
            authenticator = CredentialsAuthenticator(credentials: configuration.credentials)
            cacheAccountID = configuration.accountID.uuidString
        case let .failure(error):
            authenticator = UnavailableAuthenticator(error: error)
            cacheAccountID = nil
        }
    }
}

private struct UnavailableAuthenticator: Authenticator {
    let api: API = .appStoreConnect
    let error: any Error

    func token() throws -> String {
        throw error
    }
}
