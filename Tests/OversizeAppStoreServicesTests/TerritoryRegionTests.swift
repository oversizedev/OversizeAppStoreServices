//
// Copyright © 2025 Aleksandr Romanov
// TerritoryRegionTests.swift, created on 06.02.2025
//  

import Testing
@testable import OversizeAppStoreServices
import AppStoreAPI

@Suite struct TerritoryRegionTests {
    @Test("Should initialize with valid territory code")
    func testInitWithValidCode() throws {
        #expect(TerritoryRegion(territoryCode: .usa) == .unitedStatesAndCanada)
        #expect(TerritoryRegion(territoryCode: .fra) == .europe)
        #expect(TerritoryRegion(territoryCode: .ind) == .africaMiddleEastIndia)
        #expect(TerritoryRegion(territoryCode: .mex) == .latinAmericaCaribbean)
        #expect(TerritoryRegion(territoryCode: .jpn) == .asiaPacific)
    }
    
    @Test("Should initialize with valid country ID")
    func testInitWithValidCountryID() throws {
        #expect(TerritoryRegion(countryID: "USA") == .unitedStatesAndCanada)
        #expect(TerritoryRegion(countryID: "FRA") == .europe)
        #expect(TerritoryRegion(countryID: "IND") == .africaMiddleEastIndia)
        #expect(TerritoryRegion(countryID: "MEX") == .latinAmericaCaribbean)
        #expect(TerritoryRegion(countryID: "JPN") == .asiaPacific)
    }
    
    @Test("Should handle invalid country ID")
    func testInitWithInvalidCountryID() throws {
        #expect(TerritoryRegion(countryID: "INVALID") == .unknown)
        #expect(TerritoryRegion(countryID: "") == .unknown)
        #expect(TerritoryRegion(countryID: "123") == .unknown)
    }
    
    @Test("AllCases should contain all main regions")
    func testAllCases() throws {
        let expectedCount = 5 // Excluding .unknown
        #expect(TerritoryRegion.allCases.count == expectedCount)
        #expect(TerritoryRegion.allCases.contains(.unitedStatesAndCanada))
        #expect(TerritoryRegion.allCases.contains(.europe))
        #expect(TerritoryRegion.allCases.contains(.africaMiddleEastIndia))
        #expect(TerritoryRegion.allCases.contains(.latinAmericaCaribbean))
        #expect(TerritoryRegion.allCases.contains(.asiaPacific))
        #expect(!TerritoryRegion.allCases.contains(.unknown))
    }
    
    @Test("Should have correct raw values")
    func testRawValues() throws {
        #expect(TerritoryRegion.unitedStatesAndCanada.rawValue == "The United States and Canada")
        #expect(TerritoryRegion.europe.rawValue == "Europe")
        #expect(TerritoryRegion.africaMiddleEastIndia.rawValue == "Africa, Middle East, and India")
        #expect(TerritoryRegion.latinAmericaCaribbean.rawValue == "Latin America and the Caribbean")
        #expect(TerritoryRegion.asiaPacific.rawValue == "Asia Pacific")
        #expect(TerritoryRegion.unknown.rawValue == "Unknown Region")
    }
}
