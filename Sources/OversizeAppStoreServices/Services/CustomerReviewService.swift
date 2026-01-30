//
// Copyright © 2024 Alexander Romanov
// CustomerReviewService.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeAppStoreModels
import OversizeCore

public actor CustomerReviewService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchCustomerReviews(version: AppStoreVersion) async -> Result<[CustomerReview], Error> {
        await fetchCustomerReviews(versionId: version.id)
    }

    public func fetchAppCustomerReviews(appId: String) async -> Result<[CustomerReview], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }
        let request = Resources.v1.apps.id(appId).customerReviews.get(sort: [.minusCreatedDate])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchAppCustomerReviewsIncludeResponse(appId: String, sort: CustomerReviewsSort = .minusCreatedDate) async -> Result<[CustomerReview], Error> {
        guard let client, let sort: Resources.V1.Apps.WithID.CustomerReviews.Sort = .init(rawValue: sort.rawValue) else {
            return .failure(NetworkError.unauthorized)
        }
        let request = Resources.v1.apps.id(appId).customerReviews.get(
            sort: [sort],
            include: [.response],
        )
        do {
            let result = try await client.send(request)
            return .success(result.data.compactMap { .init(schema: $0, included: result.included) })
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchCustomerReviews(versionId: String) async -> Result<[CustomerReview], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }
        let request = Resources.v1.appStoreVersions.id(versionId).customerReviews.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchComputeRatings(versionId: String) async -> Result<Double, Error> {
        let result = await fetchCustomerReviews(versionId: versionId)
        switch result {
        case let .success(reviews):
            guard reviews.count > 0 else { return .success(0) }
            let ratingSum = reviews.map(\.rating).reduce(0, +)
            return .success(Double(ratingSum) / Double(reviews.count))
        case let .failure(error):
            return .failure(error)
        }
    }

    public func postCustomerReviewResponse(
        customerReviewsId: String,
        responseBody: String,
    ) async -> Result<CustomerReviewResponseV1, Error> {
        guard let client else {
            return .failure(NetworkError.unauthorized)
        }

        let requestAttributes: CustomerReviewResponseV1CreateRequest.Data.Attributes = .init(
            responseBody: responseBody,
        )
        let requestData: CustomerReviewResponseV1CreateRequest.Data = .init(
            type: .customerReviewResponses,
            attributes: requestAttributes,
            relationships: .init(
                review: .init(data: .init(type: .customerReviews, id: customerReviewsId)),
            ),
        )
        let request = Resources.v1.customerReviewResponses.post(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: CustomerReviewResponseV1 = .init(schema: data) else {
                return .failure(NetworkError.decode)
            }
            return .success(versionLocalization)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
