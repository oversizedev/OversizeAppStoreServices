//
// Copyright © 2024 Alexander Romanov
// ReviewService.swift, created on 23.07.2024
//

import AppStoreConnect
import OversizeModels

public actor ReviewService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchCustomerReviews(version: Version) async -> Result<[Review], AppError> {
        return await fetchCustomerReviews(versionId: version.id)
    }
    
    public func fetchCustomerReviews(versionId: String) async -> Result<[Review], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).customerReviews.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap({ .init(schema: $0) }))
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    public func fetchComputeRatings(for version: Version) async -> Result<Double, AppError> {
        let result = await fetchCustomerReviews(version: version)
        switch result {
        case .success(let reviews):
            guard reviews.count > 0 else { return .success(0) }
            let ratingSum = reviews.map(\.rating).reduce(0, +)
            return .success(Double(ratingSum) / Double(reviews.count))
        case .failure(let error):
            return .failure(error)
        }
    }
}
