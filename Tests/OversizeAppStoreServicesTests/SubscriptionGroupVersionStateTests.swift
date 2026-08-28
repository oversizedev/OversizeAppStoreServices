//
// Copyright © 2026 Alexander Romanov
// SubscriptionGroupVersionStateTests.swift, created on 21.08.2026
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

struct SubscriptionGroupVersionStateTests {
    @Test("SubscriptionGroupVersion.State should have same number of cases as AppStoreAPI")
    func checkSubscriptionGroupVersionStateCount() {
        #expect(OversizeAppStoreServices.SubscriptionGroupVersion.State.allCases.count == AppStoreAPI.SubscriptionGroupVersion.Attributes.State.allCases.count)
    }

    @Test("SubscriptionGroupVersion.State should have the same cases as AppStoreAPI")
    func checkSubscriptionGroupVersionStateCasesMatch() {
        let localCases = Set(OversizeAppStoreServices.SubscriptionGroupVersion.State.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.SubscriptionGroupVersion.Attributes.State.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated SubscriptionGroupVersion.State cases do not match")
    }

    @Test("SubscriptionGroupVersion.State should match raw values with AppStoreAPI")
    func checkSubscriptionGroupVersionStateRawValues() {
        for state in OversizeAppStoreServices.SubscriptionGroupVersion.State.allCases {
            let generatedState = AppStoreAPI.SubscriptionGroupVersion.Attributes.State(rawValue: state.rawValue)
            #expect(generatedState != nil, "No matching case in AppStoreAPI for \(state.rawValue)")
        }
    }

    @Test("SubscriptionGroupVersion.State should have correct display names")
    func checkSubscriptionGroupVersionStateDisplayNames() {
        for state in OversizeAppStoreServices.SubscriptionGroupVersion.State.allCases {
            #expect(!state.displayName.isEmpty, "Display name should not be empty for \(state)")
        }
    }
}
