//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionPeriodTests.swift, created on 06.02.2025
//  

import Testing
@testable import OversizeAppStoreServices
import AppStoreAPI

@Suite struct SubscriptionPeriodTests {
    @Test("SubscriptionPeriod should have same number of cases as AppStoreAPI")
    func checkSubscriptionPeriodCount() throws {
        #expect(OversizeAppStoreServices.SubscriptionPeriod.allCases.count == AppStoreAPI.Subscription.Attributes.SubscriptionPeriod.allCases.count)
    }
    
    @Test("SubscriptionPeriod should have the same cases as AppStoreAPI")
    func checkSubscriptionPeriodCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.SubscriptionPeriod.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.Subscription.Attributes.SubscriptionPeriod.allCases.map { $0.rawValue })
        
        #expect(localCases == generatedCases, "Local and generated SubscriptionPeriod cases do not match")
    }
    
    @Test("SubscriptionPeriod should match raw values with AppStoreAPI")
    func checkSubscriptionPeriodRawValues() throws {
        for period in OversizeAppStoreServices.SubscriptionPeriod.allCases {
            let generatedPeriod = AppStoreAPI.Subscription.Attributes.SubscriptionPeriod(rawValue: period.rawValue)
            #expect(generatedPeriod != nil, "No matching case in AppStoreAPI for \(period.rawValue)")
        }
    }
}
