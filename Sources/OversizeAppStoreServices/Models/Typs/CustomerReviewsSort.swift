//
// Copyright © 2024 Alexander Romanov
// CustomerReviewsSort.swift, created on 24.11.2024
//

import Foundation

public enum CustomerReviewsSort: String, CaseIterable, Codable, Sendable, Identifiable {
    case minusCreatedDate = "-createdDate"
    case createdDate
    case minusRating = "-rating"
    case rating

    public var displayName: String {
        switch self {
        case .rating:
            "Negative first"
        case .minusRating:
            "Positive first"
        case .createdDate:
            "Oldest first"
        case .minusCreatedDate:
            "Newest first"
        }
    }

    public var id: String {
        rawValue
    }
}
