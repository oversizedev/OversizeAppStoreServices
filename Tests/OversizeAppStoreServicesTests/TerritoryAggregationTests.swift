//
// Copyright © 2026 Alexander Romanov
// TerritoryAggregationTests.swift, created on 11.09.2026
//

import Foundation
@testable import OversizeAppStoreServices
@testable import OversizeMetricServices
import Testing

struct TerritoryAggregationTests {
    private static let tsv = """
    Date\tApp Name\tTerritory\tDownload Type\tCounts
    2026-09-01\tQR Coder\tUnited States\tFirst-time download\t120
    2026-09-01\tQR Coder\tUnited Kingdom\tFirst-time download\t30
    2026-09-02\tQR Coder\tUnited States\tRedownload\t40
    2026-09-02\tQR Coder\tBRA\tFirst-time download\t25
    2026-08-01\tQR Coder\tGermany\tFirst-time download\t999
    2026-09-02\tQR Coder\tNarnia\tFirst-time download\t7
    2026-09-02\tQR Coder\tUS\tRedownload\t10
    """

    private func table() throws -> AnalyticsReportData {
        try #require(AnalyticsTabularParser.parse(data: Data(Self.tsv.utf8), processingDate: "2026-09-03"))
    }

    @Test("Downloads are summed per territory and mapped to storefront codes")
    func aggregatesByTerritory() throws {
        let result = try TerritoryAggregation.aggregate(tables: [table()], cutoff: "2026-08-15")
        #expect(result.map(\.territoryLabel) == ["United States", "United Kingdom", "Brazil", "Narnia"])
        #expect(result.first?.downloads == 170)
        #expect(Set(result.map(\.id)).count == result.count)
        #expect(result.first?.territory == .usa)
        #expect(result.first?.storefrontCode == "us")
        #expect(result[1].storefrontCode == "gb")
        #expect(result[2].territory == .bra)
        #expect(result[3].territory == nil)
        #expect(result[3].storefrontCode == nil)
    }

    @Test("Rows before the cutoff are ignored")
    func cutoffFiltersOldRows() throws {
        let result = try TerritoryAggregation.aggregate(tables: [table()], cutoff: "2026-08-15")
        #expect(!result.contains { $0.territoryLabel == "Germany" })
        let unfiltered = try TerritoryAggregation.aggregate(tables: [table()])
        #expect(unfiltered.first?.territoryLabel == "Germany")
    }

    @Test("Territory labels resolve from names, aliases, alpha-2 and alpha-3 codes")
    func resolvesLabels() {
        #expect(TerritoryCode.resolve(label: "United States") == .usa)
        #expect(TerritoryCode.resolve(label: "united states of america") == .usa)
        #expect(TerritoryCode.resolve(label: "GB") == .gbr)
        #expect(TerritoryCode.resolve(label: "kor") == .kor)
        #expect(TerritoryCode.resolve(label: "South Korea") == .kor)
        #expect(TerritoryCode.resolve(label: "") == nil)
        #expect(TerritoryCode.resolve(label: "Atlantis") == nil)
    }

    @Test("Alpha-2 codes come from ICU region canonicalization")
    func alpha2Codes() {
        #expect(TerritoryCode.usa.alpha2Code == "US")
        #expect(TerritoryCode.gbr.alpha2Code == "GB")
        #expect(TerritoryCode.kor.alpha2Code == "KR")
        #expect(TerritoryCode.twn.alpha2Code == "TW")
        #expect(TerritoryCode.xks.alpha2Code == "XK")
    }
}
