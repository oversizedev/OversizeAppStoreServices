//
// Copyright © 2024 Alexander Romanov
// CertificateService.swift, created on 23.07.2024
//  

import AppStoreConnect
import Foundation
import OversizeModels

public actor CertificateService {
    private let client: AppStoreConnectClient?
    
    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }
    
    public func fetchProfiles() async -> Result<[Profile], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.profiles.get()
        do {
            let data = try await client.send(request)
            return .success(Profile.from(data, include: { $0.isActive }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    func fetchActiveCertificates() async throws -> Result<[Certificate], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.certificates.get()
        do {
            let data = try await client.send(request)
            return .success(Certificate.from(response: data, include: { $0.expirationDate > Date() }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
