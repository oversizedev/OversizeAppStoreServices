//
// Copyright © 2025 Aleksandr Romanov
// TerritoryTests.swift, created on 06.02.2025
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

@Suite struct TerritoryTests {
    @Test("Should initialize correctly from valid schema")
    func testInitWithValidSchema() throws {
        let schema = AppStoreAPI.Territory(
            id: "USA",
            attributes: .init(currency: "USD")
        )

        let territory = Territory(schema: schema)

        #expect(territory != nil)
        #expect(territory?.id == "USA")
        #expect(territory?.currency.identifier == "USD")
        #expect(territory?.code == .usa)
        #expect(territory?.region == .unitedStatesAndCanada)
    }

    @Test("Should return nil for invalid schema")
    func testInitWithInvalidSchema() throws {
        let invalidSchema = AppStoreAPI.Territory(
            id: "INVALID",
            attributes: nil
        )

        let territory = Territory(schema: invalidSchema)
        #expect(territory == nil)
    }

    @Test("Should have correct display name")
    func testDisplayName() throws {
        let schema = AppStoreAPI.Territory(
            id: "USA",
            attributes: .init(currency: "USD")
        )

        let territory = Territory(schema: schema)
        #expect(territory?.displayName == TerritoryCode.usa.displayName)
    }

    @Test("Should have correct display flag")
    func testDisplayFlag() throws {
        let schema = AppStoreAPI.Territory(
            id: "USA",
            attributes: .init(currency: "USD")
        )

        let territory = Territory(schema: schema)
        #expect(territory?.displayFlag == TerritoryCode.usa.flagEmoji)
    }

    @Test("Should handle different currencies correctly")
    func testCurrencyHandling() throws {
        let territories = [
            ("USA", "USD"),
            ("GBR", "GBP"),
            ("DEU", "EUR"),
            ("JPN", "JPY"),
        ]

        for (id, currency) in territories {
            let schema = AppStoreAPI.Territory(
                id: id,
                attributes: .init(currency: currency)
            )

            let territory = Territory(schema: schema)
            #expect(territory?.currency.identifier == currency)
        }
    }

    @Test("Should initialize schema with unhandled region as .unknown")
    func testInitWithSchemaUnhandledRegion() throws {
        // TerritoryCode.bgd ("BGD" - Bangladesh) is not handled in TerritoryRegion initializer,
        // so the region should be .unknown.
        let schema = AppStoreAPI.Territory(
            id: "BGD",
            attributes: .init(currency: "BDT")
        )

        let territory = Territory(schema: schema)
        #expect(territory != nil)
        #expect(territory?.region == .unknown)
    }
}
