//
// Copyright © 2025 Aleksandr Romanov
// InAppPurchaseV2.swift, created on 02.01.2025
//

import AppStoreAPI
import Foundation

public struct InAppPurchaseV2: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let productID: String
    public let inAppPurchaseType: InAppPurchaseType
    public let state: InAppPurchaseState
    public let isFamilySharable: Bool?
    public let isContentHosting: Bool?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.InAppPurchaseV2, included: [InAppPurchaseV2Response.IncludedItem]? = nil) {
        guard let attributes = schema.attributes,
              let name = attributes.name,
              let productID = attributes.productID,
              let inAppPurchaseTypeRaw = attributes.inAppPurchaseType,
              let inAppPurchaseType: InAppPurchaseType = .init(rawValue: inAppPurchaseTypeRaw.rawValue),
              let stateRaw = attributes.state,
              let state: InAppPurchaseState = .init(rawValue: stateRaw.rawValue)
        else { return nil }
        id = schema.id
        self.name = name
        self.productID = productID
        self.inAppPurchaseType = inAppPurchaseType
        self.state = state
        isFamilySharable = schema.attributes?.isFamilySharable
        isContentHosting = schema.attributes?.isContentHosting

        relationships = Relationships(
            inAppPurchaseLocalizationsIds: schema.relationships?.inAppPurchaseLocalizations?.data?.map { $0.id },
            pricePointsIds: schema.relationships?.pricePoints?.data?.map { $0.id },
            contentId: schema.relationships?.content?.data?.id,
            appStoreReviewScreenshotId: schema.relationships?.appStoreReviewScreenshot?.data?.id,
            promotedPurchaseId: schema.relationships?.promotedPurchase?.data?.id,
            iapPriceScheduleId: schema.relationships?.iapPriceSchedule?.data?.id,
            inAppPurchaseAvailabilityId: schema.relationships?.inAppPurchaseAvailability?.data?.id,
            imagesIds: schema.relationships?.images?.data?.map { $0.id }
        )

        self.included = .init(
            inAppPurchaseLocalization: included?.compactMap {
                if case let .inAppPurchaseLocalization(value) = $0 { return .init(schema: value) }
                return nil
            },
            inAppPurchasePricePoint: included?.compactMap {
                if case let .inAppPurchasePricePoint(value) = $0 { return .init(schema: value) }
                return nil
            },
            inAppPurchaseContent: included?.compactMap { (item: InAppPurchaseV2Response.IncludedItem) -> InAppPurchaseContent? in
                if case let .inAppPurchaseContent(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first,
            inAppPurchaseAppStoreReviewScreenshot: included?.compactMap { (item: InAppPurchaseV2Response.IncludedItem) -> ImageAsset? in
                if case let .inAppPurchaseAppStoreReviewScreenshot(value) = item, let imageAsset = value.attributes?.imageAsset {
                    return .init(schema: imageAsset)
                }
                return nil
            }.first,
            promotedPurchase: included?.compactMap { (item: InAppPurchaseV2Response.IncludedItem) -> PromotedPurchase? in
                if case let .promotedPurchase(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first,
            inAppPurchasePriceSchedule: included?.compactMap { (item: InAppPurchaseV2Response.IncludedItem) -> InAppPurchasePriceSchedule? in
                if case let .inAppPurchasePriceSchedule(value) = item {
                    return .init(schema: value)
                }
                return nil
            }.first,
            inAppPurchaseAvailability: included?.compactMap {
                if case let .inAppPurchaseAvailability(value) = $0 { return value.attributes?.isAvailableInNewTerritories }
                return nil
            }.first,
            inAppPurchaseImage: included?.compactMap {
                if case let .inAppPurchaseImage(value) = $0 { return .init(schema: value) }
                return nil
            }
        )
    }

    public struct Relationships: Sendable {
        public var inAppPurchaseLocalizationsIds: [String]?
        public var pricePointsIds: [String]?
        public var contentId: String?
        public var appStoreReviewScreenshotId: String?
        public var promotedPurchaseId: String?
        public var iapPriceScheduleId: String?
        public var inAppPurchaseAvailabilityId: String?
        public var imagesIds: [String]?
    }

    public struct Included: Sendable {
        let inAppPurchaseLocalization: [InAppPurchaseLocalization]?
        let inAppPurchasePricePoint: [InAppPurchasePricePoint]?
        let inAppPurchaseContent: InAppPurchaseContent?
        let inAppPurchaseAppStoreReviewScreenshot: ImageAsset?
        let promotedPurchase: PromotedPurchase?
        let inAppPurchasePriceSchedule: InAppPurchasePriceSchedule?
        let inAppPurchaseAvailability: Bool?
        let inAppPurchaseImage: [InAppPurchaseImage]?
    }
}
