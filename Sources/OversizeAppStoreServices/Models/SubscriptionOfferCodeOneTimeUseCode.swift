//
// Copyright © 2025 Alexander Romanov
// SubscriptionOfferCodeOneTimeUseCode.swift, created on 05.02.2025
//

import AppStoreAPI
import Foundation

public struct SubscriptionOfferCodeOneTimeUseCode: Identifiable, Sendable {
    public let id: String
    public let numberOfCodes: Int?
    public let createdDate: Date?
    public let expirationDate: String?
    public let isActive: Bool?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.SubscriptionOfferCodeOneTimeUseCode, included: [AppStoreAPI.SubscriptionOfferCode]? = nil) {
        guard let attributes = schema.attributes else { return nil }

        id = schema.id
        numberOfCodes = attributes.numberOfCodes
        createdDate = attributes.createdDate
        expirationDate = attributes.expirationDate
        isActive = attributes.isActive

        relationships = .init(
            offerCodeId: schema.relationships?.offerCode?.data?.id
        )

        if let offerCode = included?.first(where: { $0.id == schema.relationships?.offerCode?.data?.id }) {
            self.included = .init(offerCode: .init(schema: offerCode))
        } else {
            self.included = nil
        }
    }

    public struct Relationships: Sendable {
        public let offerCodeId: String?
    }

    public struct Included: Sendable {
        public let offerCode: SubscriptionOfferCode?
    }
}
