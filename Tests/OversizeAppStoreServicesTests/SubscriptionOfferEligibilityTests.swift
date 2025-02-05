//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferEligibilityTests.swift, created on 06.02.2025
//  

import Testing
@testable import OversizeAppStoreServices
import AppStoreAPI

@Suite struct SubscriptionOfferEligibilityTests {
    @Test("SubscriptionOfferEligibility should have same number of cases as AppStoreAPI")
    func checkSubscriptionOfferEligibilityCount() throws {
        #expect(OversizeAppStoreServices.SubscriptionOfferEligibility.allCases.count == AppStoreAPI.SubscriptionOfferEligibility.allCases.count)
    }
    
    @Test("SubscriptionOfferEligibility should have the same cases as AppStoreAPI")
    func checkSubscriptionOfferEligibilityCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.SubscriptionOfferEligibility.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.SubscriptionOfferEligibility.allCases.map { $0.rawValue })
        
        #expect(localCases == generatedCases, "Local and generated SubscriptionOfferEligibility cases do not match")
    }
    
    @Test("SubscriptionOfferEligibility should match raw values with AppStoreAPI")
    func checkSubscriptionOfferEligibilityRawValues() throws {
        for eligibility in OversizeAppStoreServices.SubscriptionOfferEligibility.allCases {
            let generatedEligibility = AppStoreAPI.SubscriptionOfferEligibility(rawValue: eligibility.rawValue)
            #expect(generatedEligibility != nil, "No matching case in AppStoreAPI for \(eligibility.rawValue)")
        }
    }
}

