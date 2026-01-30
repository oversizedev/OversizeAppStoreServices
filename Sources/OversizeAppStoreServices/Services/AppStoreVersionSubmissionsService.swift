//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionSubmissionsService.swift, created on 15.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public actor AppStoreVersionSubmissionsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func postAppStoreVersionSubmission(
        appId: String,
        appStoreVersionsId: String,
        platform: Platform,
    ) async -> Result<String, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        do {
            let apiPlatform: AppStoreAPI.Platform = switch platform {
            case .ios: .iOS
            case .macOs: .macOS
            case .tvOs: .tvOS
            case .visionOs: .visionOS
            }

            let reviewSubmissionRequest = ReviewSubmissionCreateRequest(
                data: .init(
                    type: .reviewSubmissions,
                    attributes: .init(platform: apiPlatform),
                    relationships: .init(
                        app: .init(data: .init(type: .apps, id: appId)),
                    ),
                ),
            )

            let createRequest = Resources.v1.reviewSubmissions.post(reviewSubmissionRequest)
            let reviewSubmission = try await client.send(createRequest).data

            let itemRequest = ReviewSubmissionItemCreateRequest(
                data: .init(
                    type: .reviewSubmissionItems,
                    relationships: .init(
                        reviewSubmission: .init(
                            data: .init(type: .reviewSubmissions, id: reviewSubmission.id),
                        ),
                        appStoreVersion: .init(
                            data: .init(type: .appStoreVersions, id: appStoreVersionsId),
                        ),
                    ),
                ),
            )

            let itemCreateRequest = Resources.v1.reviewSubmissionItems.post(itemRequest)
            _ = try await client.send(itemCreateRequest)

            let submitRequest = ReviewSubmissionUpdateRequest(
                data: .init(
                    type: .reviewSubmissions,
                    id: reviewSubmission.id,
                    attributes: .init(isSubmitted: true),
                ),
            )

            let patchRequest = Resources.v1.reviewSubmissions.id(reviewSubmission.id).patch(submitRequest)
            _ = try await client.send(patchRequest)

            return .success(reviewSubmission.id)

        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func fetchReviewSubmission(
        appId: String,
    ) async -> Result<ReviewSubmission?, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        do {
            let request = Resources.v1.reviewSubmissions.get(
                filterState: [.readyForReview, .waitingForReview, .inReview],
                filterApp: [appId],
            )

            let response = try await client.send(request)
            return .success(response.data.first)

        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func cancelReviewSubmission(
        id: String,
    ) async -> Result<Void, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        do {
            let cancelRequest = ReviewSubmissionUpdateRequest(
                data: .init(
                    type: .reviewSubmissions,
                    id: id,
                    attributes: .init(isCanceled: true),
                ),
            )

            let request = Resources.v1.reviewSubmissions.id(id).patch(cancelRequest)
            _ = try await client.send(request)

            return .success(())

        } catch {
            return handleRequestFailure(error: error)
        }
    }
}

private extension AppStoreVersionSubmissionsService {
    func handleRequestFailure<T>(error: Error) -> Result<T, Error> {
        if let responseError = error as? ResponseError {
            switch responseError {
            case let .requestFailure(errorResponse, _, _):
                if let errors = errorResponse?.errors, let firstError = errors.first {
                    let title = firstError.title
                    let detail = firstError.detail
                    return .failure(NetworkError.apiError(title: title, detail: detail))
                }
                return .failure(NetworkError.unknown)
            default:
                return .failure(NetworkError.unknown)
            }
        }
        return .failure(NetworkError.unknown)
    }
}
