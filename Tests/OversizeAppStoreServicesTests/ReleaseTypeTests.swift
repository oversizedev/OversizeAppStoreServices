//
// Copyright © 2025 Aleksandr Romanov
// ReleaseTypeTests.swift, created on 06.02.2025
//  

import Testing
@testable import OversizeAppStoreServices
import AppStoreAPI

@Suite struct ReleaseTypeTests {
    @Test("ReleaseType should have same number of cases as AppStoreAPI")
    func checkReleaseTypeCount() throws {
        #expect(OversizeAppStoreServices.ReleaseType.allCases.count == AppStoreAPI.AppStoreVersion.Attributes.ReleaseType.allCases.count)
    }
    
    @Test("ReleaseType should have the same cases as AppStoreAPI")
    func checkReleaseTypeCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.ReleaseType.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.AppStoreVersion.Attributes.ReleaseType.allCases.map { $0.rawValue })
        
        #expect(localCases == generatedCases, "Local and generated ReleaseType cases do not match")
    }
    
    @Test("ReleaseType should match raw values with AppStoreAPI")
    func checkReleaseTypeRawValues() throws {
        for type in OversizeAppStoreServices.ReleaseType.allCases {
            let generatedType = AppStoreAPI.AppStoreVersion.Attributes.ReleaseType(rawValue: type.rawValue)
            #expect(generatedType != nil, "No matching case in AppStoreAPI for \(type.rawValue)")
        }
    }
    
    @Test("ReleaseType should have valid display names")
    func checkReleaseTypeDisplayNames() throws {
        for type in OversizeAppStoreServices.ReleaseType.allCases {
            #expect(!type.displayName.isEmpty, "Display name should not be empty for \(type)")
        }
    }
}

