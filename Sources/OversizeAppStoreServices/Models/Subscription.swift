//
// Copyright © 2024 Alexander Romanov
// AppInfoLocalization.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
import SwiftUI

public struct Subscription: Sendable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let productID: String
    public let isFamilySharable: Bool?
    public let state: State
    public let subscriptionPeriod: SubscriptionPeriod
    public let reviewNote: String?
    public let groupLevel: Int?

    public init?(schema: AppStoreAPI.Subscription) {
        guard let attributes = schema.attributes,
              let stateRawValue = schema.attributes?.state?.rawValue,
              let state: State = .init(rawValue: stateRawValue),
              let subscriptionPeriodValue = schema.attributes?.subscriptionPeriod?.rawValue,
              let subscriptionPeriod: SubscriptionPeriod = .init(rawValue: subscriptionPeriodValue)
        else { return nil }
        self.state = state
        self.subscriptionPeriod = subscriptionPeriod
        id = schema.id
        name = attributes.name.valueOrEmpty
        productID = attributes.productID.valueOrEmpty
        isFamilySharable = attributes.isFamilySharable
        reviewNote = attributes.reviewNote
        groupLevel = attributes.groupLevel
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case missingMetadata = "MISSING_METADATA"
        case readyToSubmit = "READY_TO_SUBMIT"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case inReview = "IN_REVIEW"
        case developerActionNeeded = "DEVELOPER_ACTION_NEEDED"
        case pendingBinaryApproval = "PENDING_BINARY_APPROVAL"
        case approved = "APPROVED"
        case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
        case removedFromSale = "REMOVED_FROM_SALE"
        case rejected = "REJECTED"

        // Computed property to return color based on the state
        public var statusColor: Color {
            switch self {
            case .approved:
                .green
            case .readyToSubmit, .waitingForReview, .inReview, .pendingBinaryApproval:
                .yellow
            case .developerActionNeeded, .developerRemovedFromSale, .removedFromSale, .rejected:
                .red
            case .missingMetadata:
                .gray
            }
        }

        // Computed property to return display-friendly name
        public var displayName: String {
            switch self {
            case .missingMetadata:
                "Missing Metadata"
            case .readyToSubmit:
                "Ready to Submit"
            case .waitingForReview:
                "Waiting for Review"
            case .inReview:
                "In Review"
            case .developerActionNeeded:
                "Developer Action Needed"
            case .pendingBinaryApproval:
                "Pending Binary Approval"
            case .approved:
                "Approved"
            case .developerRemovedFromSale:
                "Developer Removed from Sale"
            case .removedFromSale:
                "Removed from Sale"
            case .rejected:
                "Rejected"
            }
        }

        // Computed property to determine if the state is editable
        public var isEditable: Bool {
            switch self {
            case .missingMetadata, .developerActionNeeded, .rejected:
                true
            default:
                false
            }
        }
    }

    public enum SubscriptionPeriod: String, CaseIterable, Codable, Sendable {
        case oneWeek = "ONE_WEEK"
        case oneMonth = "ONE_MONTH"
        case twoMonths = "TWO_MONTHS"
        case threeMonths = "THREE_MONTHS"
        case sixMonths = "SIX_MONTHS"
        case oneYear = "ONE_YEAR"
        
        public var displayName: String {
            switch self {
            case .oneWeek:
                "One Week"
            case .oneMonth:
                "One Month"
            case .twoMonths:
                "Two Months"
            case .threeMonths:
                "Three Months"
            case .sixMonths:
                "Six Months"
            case .oneYear:
                "One Year"
            }
        }
    }
}
