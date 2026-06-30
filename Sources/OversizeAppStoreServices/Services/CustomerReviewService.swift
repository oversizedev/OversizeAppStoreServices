//
// Copyright © 2024 Alexander Romanov
// CustomerReviewService.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeCore

public actor CustomerReviewService {
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
    }

    public func fetchCustomerReviews(version: AppStoreVersion) async -> Result<[CustomerReview], Error> {
        await fetchCustomerReviews(versionId: version.id)
    }

    public func fetchAppCustomerReviews(appId: String) async -> Result<[CustomerReview], Error> {

        let request = Resources.v1.apps.id(appId).customerReviews.get(sort: [.minusCreatedDate])
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(error.asNetworkError)
        }
    }

    public func fetchAppCustomerReviewsIncludeResponse(appId: String, sort: CustomerReviewsSort = .minusCreatedDate) async -> Result<[CustomerReview], Error> {
        guard let sort: Resources.V1.Apps.WithID.CustomerReviews.Sort = .init(rawValue: sort.rawValue) else {
            return .failure(NetworkError.invalidURL)
        }
        let request = Resources.v1.apps.id(appId).customerReviews.get(
            sort: [sort],
            include: [.response],
        )
        do {
            let result = try await client.send(request)
            let responses: [AppStoreAPI.CustomerReviewResponseV1]? = result.included?.compactMap { included in
                if case let .customerReviewResponseV1(response) = included { response } else { nil }
            }
            return .success(result.data.compactMap { .init(schema: $0, included: responses) })
        } catch {
            return .failure(error.asNetworkError)
        }
    }

    public func fetchCustomerReviews(versionId: String) async -> Result<[CustomerReview], Error> {

        let request = Resources.v1.appStoreVersions.id(versionId).customerReviews.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(error.asNetworkError)
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
            return .failure(error.asNetworkError)
        }
    }
}
