//
// Copyright © 2026 Alexander Romanov
// AnalyticsReportData.swift, created on 11.07.2026
//

import Foundation

public struct AnalyticsReportData: Sendable, Codable, Equatable {
    public let headers: [String]
    public let rows: [[String]]
    public let processingDate: String

    public init(headers: [String], rows: [[String]], processingDate: String) {
        self.headers = headers
        self.rows = rows
        self.processingDate = processingDate
    }

    public var isEmpty: Bool {
        rows.isEmpty
    }

    public func columnIndex(matching candidates: [String]) -> Int? {
        for candidate in candidates {
            if let index = headers.firstIndex(where: { $0.caseInsensitiveCompare(candidate) == .orderedSame }) {
                return index
            }
        }
        for candidate in candidates {
            if let index = headers.firstIndex(where: { $0.localizedCaseInsensitiveContains(candidate) }) {
                return index
            }
        }
        return nil
    }

    public var dateColumnIndex: Int? {
        columnIndex(matching: ["Date", "Event Date", "Processing Date"])
    }

    public var numericColumnIndexes: [Int] {
        let sample = rows.prefix(50)
        guard !sample.isEmpty else { return [] }
        return headers.indices.filter { columnIndex in
            var hasValue = false
            for row in sample where row.count > columnIndex {
                let value = row[columnIndex]
                guard !value.isEmpty else { continue }
                guard Double(value.replacingOccurrences(of: ",", with: "")) != nil else { return false }
                hasValue = true
            }
            return hasValue
        }
    }

    public func value(row: [String], columnIndex: Int) -> String? {
        guard row.count > columnIndex else { return nil }
        return row[columnIndex]
    }

    public func numericValue(row: [String], columnIndex: Int) -> Double? {
        guard let raw = value(row: row, columnIndex: columnIndex) else { return nil }
        return Double(raw.replacingOccurrences(of: ",", with: ""))
    }

    public func merged(with other: AnalyticsReportData) -> AnalyticsReportData {
        guard headers == other.headers else { return self }
        return AnalyticsReportData(
            headers: headers,
            rows: rows + other.rows,
            processingDate: max(processingDate, other.processingDate),
        )
    }
}
