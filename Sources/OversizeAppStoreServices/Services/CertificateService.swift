//
// Copyright © 2024 Alexander Romanov
// CertificateService.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public actor CertificateService {
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
    }

    public func fetchProfiles() async -> Result<[Profile], Error> {

        let request = Resources.v1.profiles.get()
        do {
            let data = try await client.send(request)
            return .success(Profile.from(data, include: { $0.isActive }))
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    func fetchActiveCertificates() async throws -> Result<[Certificate], Error> {

        let request = Resources.v1.certificates.get()
        do {
            let data = try await client.send(request)
            return .success(Certificate.from(response: data, include: { $0.expirationDate > Date() }))
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
