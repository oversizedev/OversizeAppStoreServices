//
// Copyright © 2025 Aleksandr Romanov
// WinBackOffer.swift, created on 05.02.2025
//  

import AppStoreAPI
import OversizeCore

public struct WinBackOffer: Sendable, Identifiable {
    public let id: String
    public let referenceName: String?
    public let offerID: String?
    public let duration: SubscriptionOfferDuration?
    public let offerMode: SubscriptionOfferMode?
    public let periodCount: Int?
    public let customerEligibilityPaidSubscriptionDurationInMonths: Int?
    public let customerEligibilityTimeSinceLastSubscribedInMonths: IntegerRange?
    public let customerEligibilityWaitBetweenOffersInMonths: Int?
    public let startDate: String?
    public let endDate: String?
    public let priority: Priority?
    public let promotionIntent: PromotionIntent?
    
    public let relationships: Relationships?
    public let included: Included?
    
    public init?(schema: AppStoreAPI.WinBackOffer, included: [AppStoreAPI.WinBackOfferPrice]? = nil) {
        guard let attributes = schema.attributes else { return nil }
        
        id = schema.id
        referenceName = attributes.referenceName
        offerID = attributes.offerID
        duration = .init(rawValue: attributes.duration?.rawValue ?? "")
        offerMode = .init(rawValue: attributes.offerMode?.rawValue ?? "")
        periodCount = attributes.periodCount
        customerEligibilityPaidSubscriptionDurationInMonths = attributes.customerEligibilityPaidSubscriptionDurationInMonths
        customerEligibilityTimeSinceLastSubscribedInMonths = attributes.customerEligibilityTimeSinceLastSubscribedInMonths.map { .init(schema: $0) }
        customerEligibilityWaitBetweenOffersInMonths = attributes.customerEligibilityWaitBetweenOffersInMonths
        startDate = attributes.startDate
        endDate = attributes.endDate
        priority = .init(rawValue: attributes.priority?.rawValue ?? "")
        promotionIntent = .init(rawValue: attributes.promotionIntent?.rawValue ?? "")
        
        relationships = Relationships(
            pricesIds: schema.relationships?.prices?.data?.map { $0.id }
        )
        
        if let included {
            self.included = .init(
                winBackOfferPrices: included.compactMap { .init(schema: $0) }
            )
        } else {
            self.included = nil
        }
    }
    
    public enum Priority: String, CaseIterable, Codable, Sendable {
        case high = "HIGH"
        case normal = "NORMAL"
    }
    
    public enum PromotionIntent: String, CaseIterable, Codable, Sendable {
        case notPromoted = "NOT_PROMOTED"
        case useAutoGeneratedAssets = "USE_AUTO_GENERATED_ASSETS"
    }
    
    public struct Relationships: Sendable {
        public var pricesIds: [String]?
        
        public init(pricesIds: [String]? = nil) {
            self.pricesIds = pricesIds
        }
    }
    
    public struct Included: Sendable {
        public let winBackOfferPrices: [WinBackOfferPrice]?
        
        public init(winBackOfferPrices: [WinBackOfferPrice]? = nil) {
            self.winBackOfferPrices = winBackOfferPrices
        }
    }
}
