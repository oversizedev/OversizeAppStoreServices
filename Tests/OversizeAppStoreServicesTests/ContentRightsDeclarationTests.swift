//
// Copyright © 2025 Alexander Romanov
// ContentRightsDeclarationTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct ContentRightsDeclarationTests {
    @Test("ContentRightsDeclaration should have same number of cases as AppStoreAPI")
    func checkContentRightsDeclarationCount() throws {
        #expect(OversizeAppStoreServices.ContentRightsDeclaration.allCases.count == AppStoreAPI.App.Attributes.ContentRightsDeclaration.allCases.count)
    }

    @Test("ContentRightsDeclaration should have the same cases as AppStoreAPI")
    func checkContentRightsDeclarationCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.ContentRightsDeclaration.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.App.Attributes.ContentRightsDeclaration.allCases.map { $0.rawValue })

        #expect(localCases == generatedCases, "Local and generated ContentRightsDeclaration cases do not match")
    }

    @Test("ContentRightsDeclaration should match raw values with AppStoreAPI")
    func checkContentRightsDeclarationRawValues() throws {
        for declaration in OversizeAppStoreServices.ContentRightsDeclaration.allCases {
            let generatedDeclaration = AppStoreAPI.App.Attributes.ContentRightsDeclaration(rawValue: declaration.rawValue)
            #expect(generatedDeclaration != nil, "No matching case in AppStoreAPI for \(declaration.rawValue)")
        }
    }
}
