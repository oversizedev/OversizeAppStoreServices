//
// Copyright © 2026 Alexander Romanov
// InAppPurchaseVersionStateTests.swift, created on 21.08.2026
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

struct InAppPurchaseVersionStateTests {
    @Test("InAppPurchaseVersion.State should have same number of cases as AppStoreAPI")
    func checkInAppPurchaseVersionStateCount() {
        #expect(OversizeAppStoreServices.InAppPurchaseVersion.State.allCases.count == AppStoreAPI.InAppPurchaseVersion.Attributes.State.allCases.count)
    }

    @Test("InAppPurchaseVersion.State should have the same cases as AppStoreAPI")
    func checkInAppPurchaseVersionStateCasesMatch() {
        let localCases = Set(OversizeAppStoreServices.InAppPurchaseVersion.State.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.InAppPurchaseVersion.Attributes.State.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated InAppPurchaseVersion.State cases do not match")
    }

    @Test("InAppPurchaseVersion.State should match raw values with AppStoreAPI")
    func checkInAppPurchaseVersionStateRawValues() {
        for state in OversizeAppStoreServices.InAppPurchaseVersion.State.allCases {
            let generatedState = AppStoreAPI.InAppPurchaseVersion.Attributes.State(rawValue: state.rawValue)
            #expect(generatedState != nil, "No matching case in AppStoreAPI for \(state.rawValue)")
        }
    }

    @Test("InAppPurchaseVersion.State should have correct display names")
    func checkInAppPurchaseVersionStateDisplayNames() {
        for state in OversizeAppStoreServices.InAppPurchaseVersion.State.allCases {
            #expect(!state.displayName.isEmpty, "Display name should not be empty for \(state)")
        }
    }
}
