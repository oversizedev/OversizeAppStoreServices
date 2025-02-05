//
// Copyright © 2025 Aleksandr Romanov
// TypesTests.swift, created on 05.02.2025
//

import Testing
@testable import OversizeAppStoreServices
import AppStoreAPI

@Suite struct InAppPurchaseTypeTests {
    
    // MARK: - InAppPurchaseType Tests
    
    @Test("InAppPurchaseType should have same number of cases as AppStoreAPI")
    func checkInAppPurchaseTypeCount() throws {
        #expect(OversizeAppStoreServices.InAppPurchaseType.allCases.count == AppStoreAPI.InAppPurchaseType.allCases.count)
    }
    
    @Test("InAppPurchaseType should have the same cases as AppStoreAPI")
    func checkInAppPurchaseTypeCasesMatch() throws {
        let localCases = Set(OversizeAppStoreServices.InAppPurchaseType.allCases.map { $0.rawValue })
        let generatedCases = Set(AppStoreAPI.InAppPurchaseType.allCases.map { $0.rawValue })
        
        #expect(localCases == generatedCases, "Local and generated InAppPurchaseType cases do not match")
    }
    
    @Test("InAppPurchaseType values should match expected raw values and display names")
    func checkInAppPurchaseTypeValues() throws {
        for type in OversizeAppStoreServices.InAppPurchaseType.allCases {
            switch type {
            case .consumable:
                #expect(type.rawValue == "CONSUMABLE")
                #expect(type.displayName == "Consumable")
            case .nonConsumable:
                #expect(type.rawValue == "NON_CONSUMABLE")
                #expect(type.displayName == "Non-Consumable")
            case .nonRenewingSubscription:
                #expect(type.rawValue == "NON_RENEWING_SUBSCRIPTION")
                #expect(type.displayName == "Non-Renewing Subscription")
            }
        }
    }
    
    @Test("InAppPurchaseType should match raw values with AppStoreAPI")
    func checkInAppPurchaseTypeRawValues() throws {
        for type in OversizeAppStoreServices.InAppPurchaseType.allCases {
            let generatedType = AppStoreAPI.InAppPurchaseType(rawValue: type.rawValue)
            #expect(generatedType != nil, "No matching case in AppStoreAPI for \(type.rawValue)")
        }
    }

}
