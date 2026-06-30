//
// Copyright © 2025 Alexander Romanov
// InAppPurchaseImage.swift, created on 17.01.2025
//

import AppStoreAPI
import Foundation

public struct InAppPurchaseImage: Sendable, Identifiable {
    public let id: String
    public let fileSize: Int?
    public let fileName: String?
    public let sourceFileChecksum: String?
    public let assetToken: String?
    public let imageAsset: ImageAsset?
    public let uploadOperations: [UploadOperation]?
    public let state: State?

    public init?(schema: AppStoreAPI.InAppPurchaseImage) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        fileSize = attributes.fileSize
        fileName = attributes.fileName
        sourceFileChecksum = attributes.sourceFileChecksum
        assetToken = attributes.assetToken
        imageAsset = attributes.imageAsset.flatMap { ImageAsset(schema: $0) }
        uploadOperations = attributes.uploadOperations?.compactMap { UploadOperation(schema: $0) }
        state = attributes.state.flatMap { State(rawValue: $0.rawValue) }
    }

    public struct Relationships: Sendable {
        public let inAppPurchaseV2Id: String?

        public init(inAppPurchaseV2Id: String?) {
            self.inAppPurchaseV2Id = inAppPurchaseV2Id
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
