//
// Copyright © 2024 Alexander Romanov
// UsersService.swift, created on 22.09.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeAppStoreModels
import OversizeCore

public actor UsersService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchUsers(versionId _: String) async -> Result<[User], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }
        let request = Resources.v1.users.get()
        do {
            let data = try await client.send(request).data
            return .success(data)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
