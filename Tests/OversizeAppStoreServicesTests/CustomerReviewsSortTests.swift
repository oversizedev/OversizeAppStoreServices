//
// Copyright © 2025 Aleksandr Romanov
// CustomerReviewsSortTests.swift, created on 06.02.2025
//  

import Testing
@testable import OversizeAppStoreServices
import AppStoreAPI

@Suite struct CustomerReviewsSortTests {
    @Test("CustomerReviewsSort should have same number of cases as AppStoreAPI")
    func checkCustomerReviewsSortCount() throws {
        #expect(OversizeAppStoreServices.CustomerReviewsSort.allCases.count == AppStoreAPI.Resources.V1.Apps.WithID.CustomerReviews.Sort.allCases.count)
    }
    
    @Test("CustomerReviewsSort should have the same cases as AppStoreAPI")
    func checkCustomerReviewsSortCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.CustomerReviewsSort.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.Resources.V1.Apps.WithID.CustomerReviews.Sort.allCases.map { $0.rawValue })
        
        #expect(localCases == generatedCases, "Local and generated CustomerReviewsSort cases do not match")
    }
    
    @Test("CustomerReviewsSort should match raw values with AppStoreAPI")
    func checkCustomerReviewsSortRawValues() throws {
        for sort in OversizeAppStoreServices.CustomerReviewsSort.allCases {
            let generatedSort = AppStoreAPI.Resources.V1.Apps.WithID.CustomerReviews.Sort(rawValue: sort.rawValue)
            #expect(generatedSort != nil, "No matching case in AppStoreAPI for \(sort.rawValue)")
        }
    }
    
    @Test("CustomerReviewsSort should have valid display names")
    func checkCustomerReviewsSortDisplayNames() throws {
        for sort in OversizeAppStoreServices.CustomerReviewsSort.allCases {
            #expect(!sort.displayName.isEmpty, "Display name should not be empty for \(sort)")
        }
    }
}


