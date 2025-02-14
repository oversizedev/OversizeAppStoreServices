//
// Copyright © 2024 Alexander Romanov
// Review.swift, created on 23.07.2024
//

import AppStoreAPI

import Foundation

public struct CustomerReview: Sendable, Identifiable {
    public let id: String
    public let title: String?
    public let rating: Int
    public let body: String?
    public let reviewerNickname: String?
    public let createdDate: Date?
    public let territory: TerritoryCode?

    public let included: Included?

    init?(schema: AppStoreAPI.CustomerReview, included: [AppStoreAPI.CustomerReviewResponseV1]? = nil) {
        guard let rating = schema.attributes?.rating,
              let territory = schema.attributes?.territory?.rawValue
        else { return nil }
        id = schema.id
        self.rating = rating
        title = schema.attributes?.title
        body = schema.attributes?.body
        reviewerNickname = schema.attributes?.reviewerNickname
        createdDate = schema.attributes?.createdDate
        self.territory = .init(rawValue: territory)

        if let customerReviewResponseV1 = included?.first(where: { $0.id == schema.relationships?.response?.data?.id }) {
            self.included = .init(customerReviewResponse: .init(schema: customerReviewResponseV1))
        } else {
            self.included = nil
        }
    }

    public struct Included: Sendable {
        public let customerReviewResponse: CustomerReviewResponseV1?
    }
}
