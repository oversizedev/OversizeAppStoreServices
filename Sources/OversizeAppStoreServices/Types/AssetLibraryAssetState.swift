//
// Copyright © 2026 Alexander Romanov
// AssetLibraryAssetState.swift, created on 23.10.2026
//

import AppStoreAPI

public enum AssetLibraryAssetState: String, CaseIterable, Codable, Sendable {
    case awaitingUpload = "AWAITING_UPLOAD"
    case uploadComplete = "UPLOAD_COMPLETE"
    case failed = "FAILED"
    case complete = "COMPLETE"
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case readyForReview = "READY_FOR_REVIEW"
    case waitingForReview = "WAITING_FOR_REVIEW"
    case inReview = "IN_REVIEW"
    case accepted = "ACCEPTED"
    case approved = "APPROVED"
    case rejected = "REJECTED"
    case archived = "ARCHIVED"

    public init?(schema: AppStoreAPI.AppAssetLibraryAssetState) {
        self.init(rawValue: schema.rawValue)
    }

    public var isProcessing: Bool {
        self == .awaitingUpload || self == .uploadComplete
    }
}
