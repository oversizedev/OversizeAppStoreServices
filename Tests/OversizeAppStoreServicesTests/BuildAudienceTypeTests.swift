//
// Copyright © 2025 Aleksandr Romanov
// BuildAudienceTypeTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct BuildAudienceTypeTests {
    @Test("BuildAudienceType should have same number of cases as AppStoreAPI")
    func checkBuildAudienceTypeCount() throws {
        #expect(OversizeAppStoreServices.BuildAudienceType.allCases.count == AppStoreAPI.BuildAudienceType.allCases.count)
    }

    @Test("BuildAudienceType should have the same cases as AppStoreAPI")
    func checkBuildAudienceTypeCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.BuildAudienceType.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.BuildAudienceType.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated BuildAudienceType cases do not match")
    }

    @Test("BuildAudienceType should match raw values with AppStoreAPI")
    func checkBuildAudienceTypeRawValues() throws {
        for type in OversizeAppStoreServices.BuildAudienceType.allCases {
            let generatedType = AppStoreAPI.BuildAudienceType(rawValue: type.rawValue)
            #expect(generatedType != nil, "No matching case in AppStoreAPI for \(type.rawValue)")
        }
    }
}
