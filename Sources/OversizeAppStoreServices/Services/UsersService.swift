//
// Copyright © 2024 Alexander Romanov
// UsersService.swift, created on 22.09.2024
//

import AppStoreConnect
import OversizeModels

public actor UsersService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchCustomerReviews(versionId _: String) async -> Result<[User], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.users.get()
        do {
            let data = try await client.send(request).data
            return .success(data)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
