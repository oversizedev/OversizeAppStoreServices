//
// Copyright © 2025 Aleksandr Romanov
// PlatformTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct PlatformTests {
    @Test("Platform should have same number of cases as AppStoreAPI")
    func checkPlatformCount() throws {
        #expect(OversizeAppStoreServices.Platform.allCases.count == AppStoreAPI.Platform.allCases.count)
    }

    @Test("Platform should have the same cases as AppStoreAPI")
    func checkPlatformCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.Platform.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.Platform.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated Platform cases do not match")
    }

    @Test("Platform should match raw values with AppStoreAPI")
    func checkPlatformRawValues() throws {
        for platform in OversizeAppStoreServices.Platform.allCases {
            let generatedPlatform = AppStoreAPI.Platform(rawValue: platform.rawValue)
            #expect(generatedPlatform != nil, "No matching case in AppStoreAPI for \(platform.rawValue)")
        }
    }

    @Test("Platform should have valid display names")
    func checkPlatformDisplayNames() throws {
        for platform in OversizeAppStoreServices.Platform.allCases {
            #expect(!platform.displayName.isEmpty, "Display name should not be empty for \(platform)")
        }
    }

    @Test("Platform should have valid icons")
    func checkPlatformIcons() throws {
        for platform in OversizeAppStoreServices.Platform.allCases {
            #expect(platform.icon != nil, "Icon should not be nil for \(platform)")
        }
    }
}
