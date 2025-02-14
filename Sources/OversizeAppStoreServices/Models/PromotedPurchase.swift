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

    public init?(schema: AppStoreAPI.PromotedPurchase) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        isVisibleForAllUsers = attributes.isVisibleForAllUsers
        isEnabled = attributes.isEnabled
        state = State(rawValue: attributes.state?.rawValue ?? "")
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case approved = "APPROVED"
        case inReview = "IN_REVIEW"
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case rejected = "REJECTED"
    }
}
