//
// Copyright © 2026 Alexander Romanov
// SubscriptionVersionStateTests.swift, created on 21.08.2026
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

struct SubscriptionVersionStateTests {
    @Test("SubscriptionVersion.State should have same number of cases as AppStoreAPI")
    func checkSubscriptionVersionStateCount() {
        #expect(OversizeAppStoreServices.SubscriptionVersion.State.allCases.count == AppStoreAPI.SubscriptionVersion.Attributes.State.allCases.count)
    }

    @Test("SubscriptionVersion.State should have the same cases as AppStoreAPI")
    func checkSubscriptionVersionStateCasesMatch() {
        let localCases = Set(OversizeAppStoreServices.SubscriptionVersion.State.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.SubscriptionVersion.Attributes.State.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated SubscriptionVersion.State cases do not match")
    }

    @Test("SubscriptionVersion.State should match raw values with AppStoreAPI")
    func checkSubscriptionVersionStateRawValues() {
        for state in OversizeAppStoreServices.SubscriptionVersion.State.allCases {
            let generatedState = AppStoreAPI.SubscriptionVersion.Attributes.State(rawValue: state.rawValue)
            #expect(generatedState != nil, "No matching case in AppStoreAPI for \(state.rawValue)")
        }
    }

    @Test("SubscriptionVersion.State should have correct display names")
    func checkSubscriptionVersionStateDisplayNames() {
        for state in OversizeAppStoreServices.SubscriptionVersion.State.allCases {
            #expect(!state.displayName.isEmpty, "Display name should not be empty for \(state)")
        }
    }
}
