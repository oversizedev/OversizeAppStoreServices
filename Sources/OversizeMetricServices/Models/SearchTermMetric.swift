//
// Copyright © 2024 Alexander Romanov
// SearchTermMetric.swift, created on 06.06.2025
//

import Foundation

public struct SearchTermMetric: Identifiable, Hashable, Sendable {
    public let searchTerm: String
    public let impressions: Int
    public let downloads: Int
    public let processingDate: String

    public var id: String {
        searchTerm
    }

    public var conversionRate: Double {
        guard impressions > 0 else { return 0 }
        return Double(downloads) / Double(impressions)
    }

    public init(searchTerm: String, impressions: Int, downloads: Int, processingDate: String) {
        self.searchTerm = searchTerm
        self.impressions = impressions
        self.downloads = downloads
        self.processingDate = processingDate
    }
}

public enum SearchTermParser {
    private static let searchTermKeys = ["searchTerm", "Search Term", "search_term", "keyword"]
    private static let impressionsKeys = ["impressions", "Impressions", "Search Impressions"]
    private static let installCountKeys = ["installCount", "Downloads", "Install Count", "installs"]

    public static func parse(tsv: Data, processingDate: String) -> [SearchTermMetric] {
        guard let table = AnalyticsTabularParser.parse(data: tsv, processingDate: processingDate) else { return [] }
        return metrics(from: table)
    }

    public static func metrics(from table: AnalyticsReportData) -> [SearchTermMetric] {
        guard let termIndex = table.columnIndex(matching: searchTermKeys) else { return [] }

        let processingDate = table.processingDate
        let impressionsIndex = table.columnIndex(matching: impressionsKeys)
        let installCountIndex = table.columnIndex(matching: installCountKeys)

        return table.rows.compactMap { row in
            guard let term = table.value(row: row, columnIndex: termIndex), !term.isEmpty else { return nil }
            let impressions = impressionsIndex.flatMap { table.numericValue(row: row, columnIndex: $0) } ?? 0
            let installs = installCountIndex.flatMap { table.numericValue(row: row, columnIndex: $0) } ?? 0
            return SearchTermMetric(
                searchTerm: term,
                impressions: Int(impressions),
                downloads: Int(installs),
                processingDate: processingDate,
            )
        }
    }
}
