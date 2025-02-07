//
// Copyright © 2025 Alexander Romanov
// PromotedPurchase.swift, created on 17.01.2025
//

import AppStoreAPI
import Foundation

public struct PromotedPurchase: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let isVisibleForAllUsers: Bool?
    public let isEnabled: Bool?
    public let state: State?
    public let inAppPurchaseV2Id: String?
    public let subscriptionId: String?
    public let promotionImageIds: [String]?

    public init?(schema: AppStoreAPI.PromotedPurchase) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        isVisibleForAllUsers = attributes.isVisibleForAllUsers
        isEnabled = attributes.isEnabled
        state = State(rawValue: attributes.state?.rawValue ?? "")
        inAppPurchaseV2Id = schema.relationships?.inAppPurchaseV2?.data?.id
        subscriptionId = schema.relationships?.subscription?.data?.id
        promotionImageIds = schema.relationships?.promotionImages?.data?.map { $0.id }
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case approved = "APPROVED"
        case inReview = "IN_REVIEW"
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case rejected = "REJECTED"
    }
}
