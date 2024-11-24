//
// Copyright © 2024 Alexander Romanov
// CustomerReviewResponseV1.swift, created on 22.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public struct CustomerReviewResponseV1: Sendable, Identifiable {
    public enum State: String, CaseIterable, Codable, Sendable {
        case published = "PUBLISHED"
        case pendingPublish = "PENDING_PUBLISH"
    }

    public let id: String
    public let responseBody: String
    public let lastModifiedDate: Date
    public let state: State

    init?(schema: AppStoreAPI.CustomerReviewResponseV1) {
        guard let attributes = schema.attributes,
              let responseBody = attributes.responseBody,
              let lastModifiedDate = attributes.lastModifiedDate,
              let stateRawValue = attributes.state?.rawValue,
              let state: State = .init(rawValue: stateRawValue)
        else { return nil }
        id = schema.id
        self.responseBody = responseBody
        self.lastModifiedDate = lastModifiedDate
        self.state = state
    }
}
