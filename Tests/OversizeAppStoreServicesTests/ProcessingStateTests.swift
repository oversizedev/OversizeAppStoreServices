//
// Copyright © 2025 Aleksandr Romanov
// ProcessingStateTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct ProcessingStateTests {
    @Test("ProcessingState should have same number of cases as AppStoreAPI")
    func checkProcessingStateCount() throws {
        #expect(OversizeAppStoreServices.ProcessingState.allCases.count == AppStoreAPI.Build.Attributes.ProcessingState.allCases.count)
    }

    @Test("ProcessingState should have the same cases as AppStoreAPI")
    func checkProcessingStateCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.ProcessingState.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.Build.Attributes.ProcessingState.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated ProcessingState cases do not match")
    }

    @Test("ProcessingState should match raw values with AppStoreAPI")
    func checkProcessingStateRawValues() throws {
        for state in OversizeAppStoreServices.ProcessingState.allCases {
            let generatedState = AppStoreAPI.Build.Attributes.ProcessingState(rawValue: state.rawValue)
            #expect(generatedState != nil, "No matching case in AppStoreAPI for \(state.rawValue)")
        }
    }

    @Test("ProcessingState should have valid display names")
    func checkProcessingStateDisplayNames() throws {
        for state in OversizeAppStoreServices.ProcessingState.allCases {
            #expect(!state.displayName.isEmpty, "Display name should not be empty for \(state)")
        }
    }
}
