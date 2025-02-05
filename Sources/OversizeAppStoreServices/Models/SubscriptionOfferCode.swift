//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferCode.swift, created on 05.02.2025
//  

import AppStoreAPI
import Foundation

public struct SubscriptionOfferCode: Identifiable, Sendable {
    public let id: String
    public let name: String?
    public let customerEligibilities: [SubscriptionCustomerEligibility]?
    public let offerEligibility: SubscriptionOfferEligibility?
    public let duration: SubscriptionOfferDuration?
    public let offerMode: SubscriptionOfferMode?
    public let numberOfPeriods: Int?
    public let totalNumberOfCodes: Int?
    public let isActive: Bool?
    
    public let relationships: Relationships?
    public let included: Included?
    
    public init?(schema: AppStoreAPI.SubscriptionOfferCode, included: [AppStoreAPI.SubscriptionOfferCodesResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes else { return nil }
        
        id = schema.id
        name = attributes.name
        customerEligibilities = attributes.customerEligibilities?.compactMap { .init(rawValue: $0.rawValue) }
        offerEligibility = .init(rawValue: attributes.offerEligibility?.rawValue ?? "")
        duration = .init(rawValue: attributes.duration?.rawValue ?? "")
        offerMode = .init(rawValue: attributes.offerMode?.rawValue ?? "")
        numberOfPeriods = attributes.numberOfPeriods
        totalNumberOfCodes = attributes.totalNumberOfCodes
        isActive = attributes.isActive
        
        relationships = .init(
            subscriptionId: schema.relationships?.subscription?.data?.id,
            oneTimeUseCodesIds: schema.relationships?.oneTimeUseCodes?.data?.compactMap { $0.id } ?? [],
            customCodesIds: schema.relationships?.customCodes?.data?.compactMap { $0.id } ?? [],
            pricesIds: schema.relationships?.prices?.data?.compactMap { $0.id } ?? []
        )
        
        var subscriptions: [AppStoreAPI.Subscription] = []
        var oneTimeUseCodes: [AppStoreAPI.SubscriptionOfferCodeOneTimeUseCode] = []
        var customCodes: [AppStoreAPI.SubscriptionOfferCodeCustomCode] = []
        var prices: [AppStoreAPI.SubscriptionOfferCodePrice] = []
        
        if let includedItems = included {
            for includedItem in includedItems {
                switch includedItem {
                case let .subscription(subscription):
                    if schema.relationships?.subscription?.data?.id == subscription.id {
                        subscriptions.append(subscription)
                    }
                case let .subscriptionOfferCodeOneTimeUseCode(oneTimeUseCode):
                    if schema.relationships?.oneTimeUseCodes?.data?.contains(where: { $0.id == oneTimeUseCode.id }) ?? false {
                        oneTimeUseCodes.append(oneTimeUseCode)
                    }
                case let .subscriptionOfferCodeCustomCode(customCode):
                    if schema.relationships?.customCodes?.data?.contains(where: { $0.id == customCode.id }) ?? false {
                        customCodes.append(customCode)
                    }
                case let .subscriptionOfferCodePrice(price):
                    if schema.relationships?.prices?.data?.contains(where: { $0.id == price.id }) ?? false {
                        prices.append(price)
                    }
                }
            }
            self.included = .init(
                subscriptions: subscriptions.compactMap { .init(schema: $0) },
                oneTimeUseCodes: oneTimeUseCodes.compactMap { .init(schema: $0) },
                customCodes: customCodes.compactMap { .init(schema: $0) },
                prices: prices.compactMap { .init(schema: $0) }
            )
        } else {
            self.included = nil
        }
    }
    
    public struct Relationships: Sendable {
        public let subscriptionId: String?
        public let oneTimeUseCodesIds: [String]
        public let customCodesIds: [String]
        public let pricesIds: [String]
    }
    
    public struct Included: Sendable {
        public let subscriptions: [Subscription]?
        public let oneTimeUseCodes: [SubscriptionOfferCodeOneTimeUseCode]?
        public let customCodes: [SubscriptionOfferCodeCustomCode]?
        public let prices: [SubscriptionOfferCodePrice]?
    }
}
