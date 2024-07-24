//
// Copyright © 2024 Alexander Romanov
// Review.swift, created on 23.07.2024
//

import AppStoreConnect

public struct Review {
    public let rating: Int
    init?(schema: AppStoreConnect.CustomerReview) {
        guard let rating = schema.attributes?.rating else { return nil }
        self.rating = rating
    }
}
