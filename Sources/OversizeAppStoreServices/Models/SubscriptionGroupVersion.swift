//
// Copyright © 2026 Alexander Romanov
// SubscriptionGroupVersion.swift, created on 21.08.2026
//

import AppStoreAPI
import Foundation

public struct SubscriptionGroupVersion: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let version: Int?
    public let state: State

    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.SubscriptionGroupVersion) {
        guard let stateRawValue = schema.attributes?.state?.rawValue,
              let state: State = .init(rawValue: stateRawValue)
        else { return nil }
        self.state = state
        id = schema.id
        version = schema.attributes?.version

        relationships = .init(
            subscriptionGroupId: schema.relationships?.subscriptionGroup?.data?.id,
            localizationsIds: schema.relationships?.localizations?.data?.map { $0.id },
        )
    }

    public struct Relationships: Equatable, Hashable, Sendable {
        public let subscriptionGroupId: String?
        public let localizationsIds: [String]?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case readyForReview = "READY_FOR_REVIEW"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case inReview = "IN_REVIEW"
        case accepted = "ACCEPTED"
        case approved = "APPROVED"
        case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
        case rejected = "REJECTED"
        case developerRejected = "DEVELOPER_REJECTED"
    }
}
