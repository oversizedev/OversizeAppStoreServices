//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferCodeCustomCode.swift, created on 05.02.2025
//

import AppStoreAPI
import Foundation

public struct SubscriptionOfferCodeCustomCode: Identifiable, Sendable {
    public let id: String
    public let customCode: String
    public let numberOfCodes: Int
    public let createdDate: Date?
    public let expirationDate: String?
    public let isActive: Bool

    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.SubscriptionOfferCodeCustomCode) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        customCode = attributes.customCode ?? ""
        numberOfCodes = attributes.numberOfCodes ?? 0
        createdDate = attributes.createdDate
        expirationDate = attributes.expirationDate
        isActive = attributes.isActive ?? false

        relationships = .init(offerCodeId: schema.relationships?.offerCode?.data?.id)
    }

    public struct Relationships: Sendable {
        public let offerCodeId: String?
    }
}
