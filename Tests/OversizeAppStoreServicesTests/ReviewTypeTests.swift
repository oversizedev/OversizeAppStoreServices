//
// Copyright © 2025 Aleksandr Romanov
// ReviewTypeTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct ReviewTypeTests {
    @Test("ReviewType should have same number of cases as AppStoreAPI")
    func checkReviewTypeCount() throws {
        #expect(OversizeAppStoreServices.ReviewType.allCases.count == AppStoreAPI.AppStoreVersion.Attributes.ReviewType.allCases.count)
    }

    @Test("ReviewType should have the same cases as AppStoreAPI")
    func checkReviewTypeCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.ReviewType.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.AppStoreVersion.Attributes.ReviewType.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated ReviewType cases do not match")
    }

    @Test("ReviewType should match raw values with AppStoreAPI")
    func checkReviewTypeRawValues() throws {
        for type in OversizeAppStoreServices.ReviewType.allCases {
            let generatedType = AppStoreAPI.AppStoreVersion.Attributes.ReviewType(rawValue: type.rawValue)
            #expect(generatedType != nil, "No matching case in AppStoreAPI for \(type.rawValue)")
        }
    }
}
