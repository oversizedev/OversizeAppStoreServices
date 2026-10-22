//
// Copyright © 2026 Alexander Romanov
// TerritoryDownloads.swift, created on 11.09.2026
//

import Foundation
import OversizeAppStoreServices

public struct TerritoryDownloads: Sendable, Codable, Equatable, Identifiable {
    public let territoryLabel: String
    public let territory: TerritoryCode?
    public let downloads: Double

    public init(territoryLabel: String, territory: TerritoryCode?, downloads: Double) {
        self.territoryLabel = territoryLabel
        self.territory = territory
        self.downloads = downloads
    }

    public var id: String {
        territory?.rawValue ?? territoryLabel
    }

    public var storefrontCode: String? {
        territory?.alpha2Code?.lowercased()
    }
}

public enum TerritoryAggregation {
    public static let territoryColumnCandidates = ["Territory", "Storefront", "Country", "Country or Region"]

    public static func aggregate(
        tables: [AnalyticsReportData],
        valueColumnCandidates: [String] = DashboardMetric.downloads.valueColumnCandidates,
        cutoff: String? = nil,
    ) -> [TerritoryDownloads] {
        var totals: [String: Double] = [:]
        var labels: [String: String] = [:]
        var codes: [String: TerritoryCode] = [:]
        for table in tables {
            guard let valueIndex = table.columnIndex(matching: valueColumnCandidates),
                  let territoryIndex = table.columnIndex(matching: territoryColumnCandidates)
            else { continue }
            let dateIndex = table.dateColumnIndex
            for row in table.rows {
                guard let value = table.numericValue(row: row, columnIndex: valueIndex) else { continue }
                if let cutoff {
                    let dateString = dateIndex.flatMap { table.value(row: row, columnIndex: $0) } ?? table.processingDate
                    guard dateString >= cutoff else { continue }
                }
                let label = table.value(row: row, columnIndex: territoryIndex)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !label.isEmpty else { continue }
                let territory = TerritoryCode.resolve(label: label)
                let key = territory?.rawValue ?? label.lowercased()
                totals[key, default: 0] += value
                if labels[key] == nil {
                    labels[key] = territory?.displayName ?? label
                    codes[key] = territory
                }
            }
        }
        return totals
            .map { key, downloads in
                TerritoryDownloads(territoryLabel: labels[key] ?? key, territory: codes[key], downloads: downloads)
            }
            .sorted { lhs, rhs in
                if lhs.downloads != rhs.downloads {
                    return lhs.downloads > rhs.downloads
                }
                return lhs.territoryLabel < rhs.territoryLabel
            }
    }
}

public extension TerritoryCode {
    static func resolve(label: String) -> TerritoryCode? {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let upper = trimmed.uppercased()
        if let direct = TerritoryCode(rawValue: upper) {
            return direct
        }
        if upper.count == 2, let byAlpha2 = alpha2Index[upper] {
            return byAlpha2
        }
        return displayNameIndex[trimmed.lowercased()]
    }

    private static let displayNameIndex: [String: TerritoryCode] = {
        var index: [String: TerritoryCode] = [:]
        for code in TerritoryCode.allCases {
            index[code.displayName.lowercased()] = code
        }
        for (alias, code) in displayNameAliases {
            index[alias] = code
        }
        return index
    }()

    private static let displayNameAliases: [String: TerritoryCode] = [
        "united states of america": .usa,
        "usa": .usa,
        "uk": .gbr,
        "great britain": .gbr,
        "russia": .rus,
        "south korea": .kor,
        "korea, republic of": .kor,
        "republic of korea": .kor,
        "vietnam": .vnm,
        "viet nam": .vnm,
        "czechia": .cze,
        "türkiye": .tur,
        "turkiye": .tur,
        "hong kong sar": .hkg,
        "macao": .mac,
        "taiwan": .twn,
    ]

    private static let alpha2Index: [String: TerritoryCode] = {
        var index: [String: TerritoryCode] = [:]
        for code in TerritoryCode.allCases {
            if let alpha2 = code.alpha2Code {
                index[alpha2] = code
            }
        }
        return index
    }()
}
