//
// Copyright © 2024 Alexander Romanov
// AppInfoLocalization.swift, created on 23.07.2024
//

import AppStoreAPI

import Foundation
import OversizeCore
import SwiftUI

public struct Subscription: Sendable, Identifiable {
    public let id: String
    public let name: String
    public let productID: String
    public let isFamilySharable: Bool?
    public let state: State
    public let subscriptionPeriod: SubscriptionPeriod?
    public let reviewNote: String?
    public let groupLevel: Int?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.Subscription, included: [SubscriptionResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes,
              let stateRawValue = schema.attributes?.state?.rawValue,
              let state: State = .init(rawValue: stateRawValue)
        else { return nil }
        self.state = state
        id = schema.id
        name = attributes.name.valueOrEmpty
        productID = attributes.productID.valueOrEmpty
        isFamilySharable = attributes.isFamilySharable
        reviewNote = attributes.reviewNote
        groupLevel = attributes.groupLevel
        if let subscriptionPeriod = attributes.subscriptionPeriod?.rawValue {
            self.subscriptionPeriod = .init(rawValue: subscriptionPeriod)
        } else {
            subscriptionPeriod = nil
        }

        relationships = Relationships(
            subscriptionLocalizationsIds: schema.relationships?.subscriptionLocalizations?.data?.map { $0.id },
            subscriptionPricesIds: schema.relationships?.prices?.data?.map { $0.id },
            subscriptionGroupId: schema.relationships?.group?.data?.id,
            subscriptionAppStoreReviewScreenshotId: schema.relationships?.appStoreReviewScreenshot?.data?.id,
            promotedPurchaseId: schema.relationships?.promotedPurchase?.data?.id,
            subscriptionOfferCodesIds: schema.relationships?.offerCodes?.data?.map { $0.id },
            subscriptionAvailabilityId: schema.relationships?.subscriptionAvailability?.data?.id,
            introductoryOffersIds: schema.relationships?.introductoryOffers?.data?.map { $0.id },
            promotionalOffersIds: schema.relationships?.promotionalOffers?.data?.map { $0.id },
            winBackOffersIds: schema.relationships?.winBackOffers?.data?.map { $0.id },
            imagesIds: schema.relationships?.images?.data?.map { $0.id }
        )

        self.included = .init(included: included)
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
            case .readyToSubmit, .waitingForReview, .inReview, .pendingBinaryApproval, .missingMetadata:
                .yellow
            case .developerActionNeeded, .developerRemovedFromSale, .removedFromSale, .rejected:
                .red
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

    public struct Relationships: Sendable {
        public var subscriptionLocalizationsIds: [String]?
        public var subscriptionPricesIds: [String]?
        public var subscriptionGroupId: String?
        public var subscriptionAppStoreReviewScreenshotId: String?
        public var promotedPurchaseId: String?
        public var subscriptionOfferCodesIds: [String]?
        public var subscriptionAvailabilityId: String?
        public var introductoryOffersIds: [String]?
        public var promotionalOffersIds: [String]?
        public var winBackOffersIds: [String]?
        public var imagesIds: [String]?

        public init(
            subscriptionLocalizationsIds: [String]? = nil,
            subscriptionPricesIds: [String]? = nil,
            subscriptionGroupId: String? = nil,
            subscriptionAppStoreReviewScreenshotId: String? = nil,
            promotedPurchaseId: String? = nil,
            subscriptionOfferCodesIds: [String]? = nil,
            subscriptionAvailabilityId: String? = nil,
            introductoryOffersIds: [String]? = nil,
            promotionalOffersIds: [String]? = nil,
            winBackOffersIds: [String]? = nil,
            imagesIds: [String]? = nil
        ) {
            self.subscriptionLocalizationsIds = subscriptionLocalizationsIds
            self.subscriptionPricesIds = subscriptionPricesIds
            self.subscriptionGroupId = subscriptionGroupId
            self.subscriptionAppStoreReviewScreenshotId = subscriptionAppStoreReviewScreenshotId
            self.promotedPurchaseId = promotedPurchaseId
            self.subscriptionOfferCodesIds = subscriptionOfferCodesIds
            self.subscriptionAvailabilityId = subscriptionAvailabilityId
            self.introductoryOffersIds = introductoryOffersIds
            self.promotionalOffersIds = promotionalOffersIds
            self.winBackOffersIds = winBackOffersIds
            self.imagesIds = imagesIds
        }
    }

    public struct Included: Sendable {
        public let subscriptionLocalizations: [SubscriptionLocalization]?
        public let subscriptionPrices: [SubscriptionPrice]?
        public let subscriptionGroup: SubscriptionGroup?
        public let subscriptionAppStoreReviewScreenshot: ImageAsset?
        public let promotedPurchase: PromotedPurchase?
        public let subscriptionOfferCodes: [SubscriptionOfferCode]?
        public let subscriptionAvailability: Bool?
        public let introductoryOffers: [SubscriptionIntroductoryOffer]?
        public let promotionalOffers: [SubscriptionPromotionalOffer]?
        public let winBackOffers: [WinBackOffer]?
        public let subscriptionImages: [SubscriptionImage]?

        public init(
            subscriptionLocalizations: [SubscriptionLocalization]? = nil,
            subscriptionPrices: [SubscriptionPrice]? = nil,
            subscriptionGroup: SubscriptionGroup? = nil,
            subscriptionAppStoreReviewScreenshot: ImageAsset? = nil,
            promotedPurchase: PromotedPurchase? = nil,
            subscriptionOfferCodes: [SubscriptionOfferCode]? = nil,
            subscriptionAvailability: Bool? = nil,
            introductoryOffers: [SubscriptionIntroductoryOffer]? = nil,
            promotionalOffers: [SubscriptionPromotionalOffer]? = nil,
            winBackOffers: [WinBackOffer]? = nil,
            subscriptionImages: [SubscriptionImage]? = nil
        ) {
            self.subscriptionLocalizations = subscriptionLocalizations
            self.subscriptionPrices = subscriptionPrices
            self.subscriptionGroup = subscriptionGroup
            self.subscriptionAppStoreReviewScreenshot = subscriptionAppStoreReviewScreenshot
            self.promotedPurchase = promotedPurchase
            self.subscriptionOfferCodes = subscriptionOfferCodes
            self.subscriptionAvailability = subscriptionAvailability
            self.introductoryOffers = introductoryOffers
            self.promotionalOffers = promotionalOffers
            self.winBackOffers = winBackOffers
            self.subscriptionImages = subscriptionImages
        }

        init?(included: [SubscriptionResponse.IncludedItem]?) {
            subscriptionLocalizations = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> SubscriptionLocalization? in
                if case let .subscriptionLocalization(value) = item { return .init(schema: value) }
                return nil
            }

            subscriptionPrices = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> SubscriptionPrice? in
                if case let .subscriptionPrice(value) = item { return .init(schema: value) }
                return nil
            }

            subscriptionGroup = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> SubscriptionGroup? in
                if case let .subscriptionGroup(value) = item { return .init(schema: value) }
                return nil
            }.first

            subscriptionAppStoreReviewScreenshot = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> ImageAsset? in
                if case let .subscriptionAppStoreReviewScreenshot(value) = item, let imageAsset = value.attributes?.imageAsset {
                    return .init(schema: imageAsset)
                }
                return nil
            }.first

            promotedPurchase = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> PromotedPurchase? in
                if case let .promotedPurchase(value) = item { return .init(schema: value) }
                return nil
            }.first

            subscriptionOfferCodes = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> SubscriptionOfferCode? in
                if case let .subscriptionOfferCode(value) = item { return .init(schema: value) }
                return nil
            }

            subscriptionAvailability = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> Bool? in
                if case let .subscriptionAvailability(value) = item { return value.attributes?.isAvailableInNewTerritories }
                return nil
            }.first

            introductoryOffers = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> SubscriptionIntroductoryOffer? in
                if case let .subscriptionIntroductoryOffer(value) = item { return .init(schema: value) }
                return nil
            }

            promotionalOffers = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> SubscriptionPromotionalOffer? in
                if case let .subscriptionPromotionalOffer(value) = item { return .init(schema: value) }
                return nil
            }

            winBackOffers = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> WinBackOffer? in
                if case let .winBackOffer(value) = item { return .init(schema: value) }
                return nil
            }

            subscriptionImages = included?.compactMap { (item: SubscriptionResponse.IncludedItem) -> SubscriptionImage? in
                if case let .subscriptionImage(value) = item { return .init(schema: value) }
                return nil
            }
        }
    }
}
