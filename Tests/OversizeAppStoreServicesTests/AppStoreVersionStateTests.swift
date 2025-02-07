//
// Copyright © 2025 Aleksandr Romanov
// AppStoreAgeRatingTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct AppStoreVersionStateTests {
    @Test("AppStoreVersionState should have same number of cases as AppStoreAPI")
    func checkAppStoreVersionStateCount() throws {
        #expect(OversizeAppStoreServices.AppStoreVersionState.allCases.count == AppStoreAPI.AppStoreVersionState.allCases.count)
    }

    @Test("AppStoreVersionState should have the same cases as AppStoreAPI")
    func checkAppStoreVersionStateCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.AppStoreVersionState.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.AppStoreVersionState.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated AppStoreVersionState cases do not match")
    }

    @Test("AppStoreVersionState should match raw values with AppStoreAPI")
    func checkAppStoreVersionStateRawValues() throws {
        for state in OversizeAppStoreServices.AppStoreVersionState.allCases {
            let generatedState = AppStoreAPI.AppStoreVersionState(rawValue: state.rawValue)
            #expect(generatedState != nil, "No matching case in AppStoreAPI for \(state.rawValue)")
        }
    }

    @Test("AppStoreVersionState should have correct display names")
    func checkAppStoreVersionStateDisplayNames() throws {
        for state in OversizeAppStoreServices.AppStoreVersionState.allCases {
            #expect(!state.displayName.isEmpty, "Display name should not be empty for \(state)")
        }
    }

    @Test("AppStoreVersionState should have valid status colors")
    func checkAppStoreVersionStateColors() throws {
        for state in OversizeAppStoreServices.AppStoreVersionState.allCases {
            #expect(state.statusColor != nil, "Status color should not be nil for \(state)")
        }
    }
}
