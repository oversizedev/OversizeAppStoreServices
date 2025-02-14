//
// Copyright © 2025 Alexander Romanov
// SubscriptionImage.swift, created on 05.02.2025
//

import AppStoreAPI
import Foundation

public struct SubscriptionImage: Sendable, Identifiable {
    public let id: String
    public let fileSize: Int?
    public let fileName: String?
    public let sourceFileChecksum: String?
    public let assetToken: String?
    public let imageAsset: ImageAsset?
    public let uploadOperations: [UploadOperation]?
    public let state: State?

    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.SubscriptionImage) {
        guard let attributes = schema.attributes else { return nil }

        id = schema.id
        fileSize = attributes.fileSize
        fileName = attributes.fileName
        sourceFileChecksum = attributes.sourceFileChecksum
        assetToken = attributes.assetToken
        imageAsset = attributes.imageAsset.flatMap { ImageAsset(schema: $0) }
        uploadOperations = attributes.uploadOperations?.compactMap { UploadOperation(schema: $0) }
        state = attributes.state.flatMap { State(rawValue: $0.rawValue) }

        relationships = Relationships(
            subscriptionId: schema.relationships?.subscription?.data?.id
        )
    }

    public struct Relationships: Sendable {
        public let subscriptionId: String?

        public init(subscriptionId: String?) {
            self.subscriptionId = subscriptionId
        }
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case awaitingUpload = "AWAITING_UPLOAD"
        case uploadComplete = "UPLOAD_COMPLETE"
        case failed = "FAILED"
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case approved = "APPROVED"
        case rejected = "REJECTED"
    }
}
