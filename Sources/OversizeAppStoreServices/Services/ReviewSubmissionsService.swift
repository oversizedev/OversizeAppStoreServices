//
// Copyright © 2024 Alexander Romanov
// reviewSubmissionsService.swift, created on 15.11.2024
//

import AppStoreAPI
import AppStoreConnect
import FactoryKit
import Foundation
import OversizeAppStoreModels
import OversizeCore

public actor ReviewSubmissionsService {
    private let client: AppStoreConnectClient?
    @Injected(\.cacheService) private var cacheService: CacheService

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func postReviewSubmission(
        appId: String,
        platform: Platform,
    ) async -> Result<ReviewSubmission, Error> {
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

            guard let submission: ReviewSubmission = .init(schema: reviewSubmission) else {
                return .failure(NetworkError.decode)
            }

            return .success(submission)

        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func postReviewSubmissionItems(
        reviewSubmissionId: String,
        appStoreVersionsId: String,
    ) async -> Result<ReviewSubmissionItem, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        do {
            let reviewSubmissionItemCreateRequest = ReviewSubmissionItemCreateRequest(
                data: .init(
                    type: .reviewSubmissionItems,
                    relationships: .init(
                        reviewSubmission: .init(
                            data: .init(type: .reviewSubmissions, id: reviewSubmissionId),
                        ),
                        appStoreVersion: .init(
                            data: .init(type: .appStoreVersions, id: appStoreVersionsId),
                        ),
                    ),
                ),
            )

            let itemCreateRequest = Resources.v1.reviewSubmissionItems.post(reviewSubmissionItemCreateRequest)
            let item = try await client.send(itemCreateRequest).data

            guard let submissionItem: ReviewSubmissionItem = .init(schema: item) else {
                return .failure(NetworkError.decode)
            }

            return .success(submissionItem)

        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func patchReviewSubmissions(
        reviewSubmissionId: String,
        isSubmitted: Bool,
        isCanceled: Bool? = nil,
    ) async -> Result<ReviewSubmission, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        do {
            let submitRequest = ReviewSubmissionUpdateRequest(
                data: .init(
                    type: .reviewSubmissions,
                    id: reviewSubmissionId,
                    attributes: .init(
                        isSubmitted: isSubmitted,
                        isCanceled: isCanceled,
                    ),
                ),
            )

            let patchRequest = Resources.v1.reviewSubmissions.id(reviewSubmissionId).patch(submitRequest)
            let submission = try await client.send(patchRequest).data

            guard let updated: ReviewSubmission = .init(schema: submission) else {
                return .failure(NetworkError.decode)
            }

            return .success(updated)

        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func postAppStoreVersionSubmissionWithItems(
        appId: String,
        appStoreVersionsId: String,
        platform: Platform,
    ) async -> Result<ReviewSubmission, Error> {
        switch await fetchOrCreateReviewSubmission(appId: appId, platform: platform) {
        case let .success(submission):
            switch await postReviewSubmissionItems(reviewSubmissionId: submission.id, appStoreVersionsId: appStoreVersionsId) {
            case .success:
                switch await patchReviewSubmissions(reviewSubmissionId: submission.id, isSubmitted: true) {
                case let .success(reviewSubmission):
                    .success(reviewSubmission)
                case let .failure(error):
                    .failure(error)
                }
            case let .failure(itemsError):
                .failure(itemsError)
            }
        case let .failure(error):
            .failure(error)
        }
    }

    public func fetchReviewSubmissions(appId: String) async -> Result<[ReviewSubmission], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        do {
            let request = Resources.v1.reviewSubmissions.get(filterApp: [appId])
            let response = try await client.send(request)
            let submission = response.data.compactMap { ReviewSubmission(schema: $0) }
            return .success(submission)

        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func fetchReviewSubmissionsIncludedAll(
        appId: String,
        force: Bool = false,
    ) async -> Result<[ReviewSubmission], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        return await cacheService.fetchWithCache(key: "fetchReviewSubmissionsIncludedAll\(appId)", force: force) {
            let request = Resources.v1.reviewSubmissions.get(
                filterApp: [appId],
                include: [
                    .app,
                    .items,
                    .appStoreVersionForReview,
                    .submittedByActor,
                    .lastUpdatedByActor,
                ],
            )
            return try await client.send(request)
        }.map { response in
            response.data.compactMap { ReviewSubmission(schema: $0, included: response.included) }
        }
    }

    public func fetchReviewSubmissionItemsIncludedAll(
        reviewSubmissionId: String,
        force: Bool = false,
    ) async -> Result<[ReviewSubmissionItem], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        return await cacheService.fetchWithCache(key: "fetchReviewSubmissionItemsIncludedAll\(reviewSubmissionId)", force: force) {
            let request = Resources.v1.reviewSubmissions.id(reviewSubmissionId).items.get(
                limit: 200,
                include: [
                    .appStoreVersion,
                    .appCustomProductPageVersion,
                    .appStoreVersionExperiment,
                    .appEvent,
                ],
            )
            return try await client.send(request)
        }.map { (response: AppStoreAPI.ReviewSubmissionItemsResponse) in
            response.data.compactMap { ReviewSubmissionItem(schema: $0, included: response.included) }
        }
    }

    public func cancelReviewSubmission(id: String) async -> Result<Void, Error> {
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

    public func cancelIrisReviewSubmission(id: String) async -> Result<Void, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        struct CancelBody: Encodable, Sendable {
            struct DataPayload: Encodable, Sendable {
                let type: String
                let id: String
                let attributes: Attributes
                struct Attributes: Encodable, Sendable {
                    let canceled: Bool
                }
            }

            let data: DataPayload
        }

        do {
            let body = CancelBody(
                data: .init(
                    type: "reviewSubmissions",
                    id: id,
                    attributes: .init(canceled: true),
                ),
            )
            let irisURL = URL(string: "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions/\(id)")!
            let request = Request<Void>.patch(irisURL, body: body)
            try await client.send(request)
            return .success(())
        } catch {
            return handleRequestFailure(error: error)
        }
    }
}

private extension ReviewSubmissionsService {
    func fetchOrCreateReviewSubmission(
        appId: String,
        platform: Platform,
    ) async -> Result<ReviewSubmission, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        let filterPlatform: Resources.V1.ReviewSubmissions.FilterPlatform = switch platform {
        case .ios: .iOS
        case .macOs: .macOS
        case .tvOs: .tvOS
        case .visionOs: .visionOS
        }

        do {
            let request = Resources.v1.reviewSubmissions.get(
                filterPlatform: [filterPlatform],
                filterState: [.readyForReview],
                filterApp: [appId],
            )
            let submissions = try await client.send(request).data
            if let existing = submissions.first,
               let mapped: ReviewSubmission = .init(schema: existing)
            {
                return .success(mapped)
            }
        } catch {}

        return await postReviewSubmission(appId: appId, platform: platform)
    }
}

private extension ReviewSubmissionsService {
    func handleRequestFailure<T>(error: Error) -> Result<T, Error> {
        if let responseError = error as? ResponseError {
            switch responseError {
            case let .requestFailure(errorResponse, _, _):
                if let errors = errorResponse?.errors, let firstError = errors.first {
                    let associatedErrors = extractAssociatedErrors(from: errors)
                    if associatedErrors.isEmpty == false {
                        return .failure(
                            ReviewSubmissionAssociatedErrors(
                                title: firstError.title,
                                detail: firstError.detail,
                                errors: associatedErrors,
                            ),
                        )
                    }
                    return .failure(NetworkError.apiError(title: firstError.title, detail: firstError.detail))
                }
                return .failure(NetworkError.unknown(error))
            default:
                return .failure(NetworkError.unknown(error))
            }
        }
        return .failure(NetworkError.unknown(error))
    }

    func extractAssociatedErrors(from errors: [ErrorResponse.Error]) -> [ReviewSubmissionAssociatedErrors.AssociatedError] {
        var result: [ReviewSubmissionAssociatedErrors.AssociatedError] = []

        for error in errors {
            if let meta = error.meta,
               case let .object(associatedErrors) = meta["associatedErrors"]
            {
                for value in associatedErrors.values {
                    guard case let .array(items) = value else { continue }
                    for item in items {
                        if let associatedError = mapAssociatedError(item) {
                            result.append(associatedError)
                        }
                    }
                }
            } else {
                var pointer: String?
                if let source = error.source, case let .errorSourcePointer(p) = source {
                    pointer = p.pointer
                }
                result.append(.init(
                    id: error.id,
                    title: error.title,
                    detail: error.detail,
                    code: error.code,
                    pointer: pointer,
                ))
            }
        }

        return result
    }

    func mapAssociatedError(_ value: AnyJSON) -> ReviewSubmissionAssociatedErrors.AssociatedError? {
        guard case let .object(object) = value else { return nil }

        let title = stringValue(object["title"])
        let detail = stringValue(object["detail"])

        guard let title, let detail else { return nil }

        let id = stringValue(object["id"])
        let code = stringValue(object["code"])

        var pointer: String?
        if let source = object["source"],
           case let .object(sourceObject) = source,
           let sourcePointer = sourceObject["pointer"],
           case let .string(pointerValue) = sourcePointer
        {
            pointer = pointerValue
        }

        return .init(
            id: id,
            title: title,
            detail: detail,
            code: code,
            pointer: pointer,
        )
    }

    func stringValue(_ value: AnyJSON?) -> String? {
        guard let value else { return nil }
        guard case let .string(result) = value else { return nil }
        return result
    }
}
