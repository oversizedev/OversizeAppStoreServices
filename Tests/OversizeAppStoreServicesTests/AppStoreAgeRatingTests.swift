//
// Copyright © 2025 Alexander Romanov
// AppStoreAgeRatingTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct AppStoreAgeRatingTests {
    @Test("AppStoreAgeRating should have same number of cases as AppStoreAPI")
    func checkAppStoreAgeRatingCount() throws {
        #expect(OversizeAppStoreServices.AppStoreAgeRating.allCases.count == AppStoreAPI.AppStoreAgeRating.allCases.count)
    }

    @Test("AppStoreAgeRating should have the same cases as AppStoreAPI")
    func checkAppStoreAgeRatingCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.AppStoreAgeRating.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.AppStoreAgeRating.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated AppStoreAgeRating cases do not match")
    }

    @Test("AppStoreAgeRating should match raw values with AppStoreAPI")
    func checkAppStoreAgeRatingRawValues() throws {
        for rating in OversizeAppStoreServices.AppStoreAgeRating.allCases {
            let generatedRating = AppStoreAPI.AppStoreAgeRating(rawValue: rating.rawValue)
            #expect(generatedRating != nil, "No matching case in AppStoreAPI for \(rating.rawValue)")
        }
    }
}
