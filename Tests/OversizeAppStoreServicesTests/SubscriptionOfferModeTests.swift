//
// Copyright © 2025 Aleksandr Romanov
// SubscriptionOfferModeTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct SubscriptionOfferModeTests {
    @Test("SubscriptionOfferMode should have same number of cases as AppStoreAPI")
    func checkSubscriptionOfferModeCount() throws {
        #expect(OversizeAppStoreServices.SubscriptionOfferMode.allCases.count == AppStoreAPI.SubscriptionOfferMode.allCases.count)
    }

    @Test("SubscriptionOfferMode should have the same cases as AppStoreAPI")
    func checkSubscriptionOfferModeCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.SubscriptionOfferMode.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.SubscriptionOfferMode.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated SubscriptionOfferMode cases do not match")
    }

    @Test("SubscriptionOfferMode should match raw values with AppStoreAPI")
    func checkSubscriptionOfferModeRawValues() throws {
        for mode in OversizeAppStoreServices.SubscriptionOfferMode.allCases {
            let generatedMode = AppStoreAPI.SubscriptionOfferMode(rawValue: mode.rawValue)
            #expect(generatedMode != nil, "No matching case in AppStoreAPI for \(mode.rawValue)")
        }
    }
}
