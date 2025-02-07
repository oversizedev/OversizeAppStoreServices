//
// Copyright © 2025 Aleksandr Romanov
// BundleIDPlatformTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct BundleIDPlatformTests {
    @Test("BundleIDPlatform should have same number of cases as AppStoreAPI")
    func checkBundleIDPlatformCount() throws {
        #expect(OversizeAppStoreServices.BundleIDPlatform.allCases.count == AppStoreAPI.BundleIDPlatform.allCases.count)
    }

    @Test("BundleIDPlatform should have the same cases as AppStoreAPI")
    func checkBundleIDPlatformCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.BundleIDPlatform.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.BundleIDPlatform.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated BundleIDPlatform cases do not match")
    }

    @Test("BundleIDPlatform should match raw values with AppStoreAPI")
    func checkBundleIDPlatformRawValues() throws {
        for platform in OversizeAppStoreServices.BundleIDPlatform.allCases {
            let generatedPlatform = AppStoreAPI.BundleIDPlatform(rawValue: platform.rawValue)
            #expect(generatedPlatform != nil, "No matching case in AppStoreAPI for \(platform.rawValue)")
        }
    }
}
