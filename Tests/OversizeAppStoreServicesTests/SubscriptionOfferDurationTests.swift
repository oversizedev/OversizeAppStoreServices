//
// Copyright © 2025 Alexander Romanov
// SubscriptionOfferDurationTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct SubscriptionOfferDurationTests {
    @Test("SubscriptionOfferDuration should have same number of cases as AppStoreAPI")
    func checkSubscriptionOfferDurationCount() throws {
        #expect(OversizeAppStoreServices.SubscriptionOfferDuration.allCases.count == AppStoreAPI.SubscriptionOfferDuration.allCases.count)
    }

    @Test("SubscriptionOfferDuration should have the same cases as AppStoreAPI")
    func checkSubscriptionOfferDurationCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.SubscriptionOfferDuration.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.SubscriptionOfferDuration.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated SubscriptionOfferDuration cases do not match")
    }

    @Test("SubscriptionOfferDuration should match raw values with AppStoreAPI")
    func checkSubscriptionOfferDurationRawValues() throws {
        for duration in OversizeAppStoreServices.SubscriptionOfferDuration.allCases {
            let generatedDuration = AppStoreAPI.SubscriptionOfferDuration(rawValue: duration.rawValue)
            #expect(generatedDuration != nil, "No matching case in AppStoreAPI for \(duration.rawValue)")
        }
    }
}
