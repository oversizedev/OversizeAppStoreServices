//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionCustomerEligibilityTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct SubscriptionCustomerEligibilityTests {
    @Test("SubscriptionCustomerEligibility should have same number of cases as AppStoreAPI")
    func checkSubscriptionCustomerEligibilityCount() throws {
        #expect(OversizeAppStoreServices.SubscriptionCustomerEligibility.allCases.count == AppStoreAPI.SubscriptionCustomerEligibility.allCases.count)
    }

    @Test("SubscriptionCustomerEligibility should have the same cases as AppStoreAPI")
    func checkSubscriptionCustomerEligibilityCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.SubscriptionCustomerEligibility.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.SubscriptionCustomerEligibility.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated SubscriptionCustomerEligibility cases do not match")
    }

    @Test("SubscriptionCustomerEligibility should match raw values with AppStoreAPI")
    func checkSubscriptionCustomerEligibilityRawValues() throws {
        for eligibility in OversizeAppStoreServices.SubscriptionCustomerEligibility.allCases {
            let generatedEligibility = AppStoreAPI.SubscriptionCustomerEligibility(rawValue: eligibility.rawValue)
            #expect(generatedEligibility != nil, "No matching case in AppStoreAPI for \(eligibility.rawValue)")
        }
    }
}
