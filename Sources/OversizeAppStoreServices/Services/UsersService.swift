//
// Copyright © 2024 Alexander Romanov
// UsersService.swift, created on 22.09.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeCore

public actor UsersService {
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
    }

    public func fetchUsers(versionId _: String) async -> Result<[User], Error> {

        let request = Resources.v1.users.get()
        do {
            let data = try await client.send(request).data
            return .success(data)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
