//
// Copyright © 2024 Alexander Romanov
// CertificateService.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeAppStoreModels
import OversizeCore

public actor CertificateService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchProfiles() async -> Result<[Profile], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }
        let request = Resources.v1.profiles.get()
        do {
            let data = try await client.send(request)
            return .success(Profile.from(data, include: { $0.isActive }))
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    func fetchActiveCertificates() async throws -> Result<[Certificate], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }
        let request = Resources.v1.certificates.get()
        do {
            let data = try await client.send(request)
            return .success(Certificate.from(response: data, include: { $0.expirationDate > Date() }))
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
