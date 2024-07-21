// The Swift Programming Language
// https://docs.swift.org/swift-book

import AppStoreConnect
import Foundation
import OversizeModels

public actor AppStoreConnectServices {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchApps() async -> Result<[AppStoreConnect.App], AppError> {
        guard let client = client else { return .failure(.network(type: .noResponse)) }

        let request = Resources
            .v1
            .apps
            .get()
        do {
            let data = try await client.send(request).data
            return .success(data)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
