//
// Copyright © 2026 Alexander Romanov
// ReviewSubmissionsServicesProtocol.swift, created on 14.08.2026
//

import Foundation

public protocol ReviewSubmissionsServicesProtocol: Sendable {
    func postReviewSubmission(appId: String, platform: Platform) async -> Result<ReviewSubmission, Error>
    func postReviewSubmissionItems(reviewSubmissionId: String, appStoreVersionsId: String) async -> Result<ReviewSubmissionItem, Error>
    func patchReviewSubmissions(reviewSubmissionId: String, isSubmitted: Bool, isCanceled: Bool?) async -> Result<ReviewSubmission, Error>
    func postAppStoreVersionSubmissionWithItems(appId: String, appStoreVersionsId: String, platform: Platform) async -> Result<ReviewSubmission, Error>
    func fetchReviewSubmissions(appId: String) async -> Result<[ReviewSubmission], Error>
    func fetchReviewSubmissionsIncludedAll(appId: String, force: Bool) async -> Result<[ReviewSubmission], Error>
    func fetchReviewSubmissionItemsIncludedAll(reviewSubmissionId: String, force: Bool) async -> Result<[ReviewSubmissionItem], Error>
    func cancelReviewSubmission(id: String) async -> Result<Void, Error>
    func cancelIrisReviewSubmission(id: String) async -> Result<Void, Error>
}

// MARK: - Default-argument convenience

/// Protocol requirements cannot declare default parameter values, so the short call shapes
/// used across the app are restored here. Each convenience uses a strictly smaller, unique
/// label set than its requirement, keeping overload resolution unambiguous.
public extension ReviewSubmissionsServicesProtocol {
    func patchReviewSubmissions(reviewSubmissionId: String, isSubmitted: Bool) async -> Result<ReviewSubmission, Error> {
        await patchReviewSubmissions(reviewSubmissionId: reviewSubmissionId, isSubmitted: isSubmitted, isCanceled: nil)
    }

    func fetchReviewSubmissionsIncludedAll(appId: String) async -> Result<[ReviewSubmission], Error> {
        await fetchReviewSubmissionsIncludedAll(appId: appId, force: false)
    }

    func fetchReviewSubmissionItemsIncludedAll(reviewSubmissionId: String) async -> Result<[ReviewSubmissionItem], Error> {
        await fetchReviewSubmissionItemsIncludedAll(reviewSubmissionId: reviewSubmissionId, force: false)
    }
}
