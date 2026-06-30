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
        guard let text = String(data: tsv, encoding: .utf8) else { return [] }
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] }

        let delimiter = detectDelimiter(firstLine: lines[0])
        let headers = split(line: lines[0], delimiter: delimiter)
        let termIdx = firstIndex(in: headers, matching: searchTermKeys)
        let impressionsIdx = firstIndex(in: headers, matching: impressionsKeys)
        let installCountIdx = firstIndex(in: headers, matching: installCountKeys)

        guard let termIdx else { return [] }

        return lines.dropFirst().compactMap { line in
            let cols = split(line: line, delimiter: delimiter)
            guard cols.count > termIdx else { return nil }
            let term = cols[termIdx].trimmingCharacters(in: .init(charactersIn: " \""))
            guard !term.isEmpty else { return nil }
            let impressions = impressionsIdx.flatMap { idx -> Int? in
                guard cols.count > idx else { return nil }
                return Int(cols[idx].trimmingCharacters(in: .whitespaces))
            } ?? 0
            let installs = installCountIdx.flatMap { idx -> Int? in
                guard cols.count > idx else { return nil }
                return Int(cols[idx].trimmingCharacters(in: .whitespaces))
            } ?? 0
            return SearchTermMetric(
                searchTerm: term,
                impressions: impressions,
                downloads: installs,
                processingDate: processingDate,
            )
        }
    }

    private static func detectDelimiter(firstLine: String) -> Character {
        let tabCount = firstLine.count(where: { $0 == "\t" })
        let commaCount = firstLine.count(where: { $0 == "," })
        return tabCount >= commaCount ? "\t" : ","
    }

    private static func split(line: String, delimiter: Character) -> [String] {
        if delimiter == "," {
            return splitCSV(line: line)
        }
        return line.components(separatedBy: "\t")
    }

    private static func splitCSV(line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var index = line.startIndex
        while index < line.endIndex {
            let char = line[index]
            if inQuotes {
                if char == "\"" {
                    let next = line.index(after: index)
                    if next < line.endIndex, line[next] == "\"" {
                        current.append("\"")
                        index = next
                    } else {
                        inQuotes = false
                    }
                } else {
                    current.append(char)
                }
            } else {
                switch char {
                case "\"": inQuotes = true
                case ",":
                    fields.append(current)
                    current = ""
                default:
                    current.append(char)
                }
            }
            index = line.index(after: index)
        }
        fields.append(current)
        return fields
    }

    private static func firstIndex(in headers: [String], matching candidates: [String]) -> Int? {
        for candidate in candidates {
            if let idx = headers.firstIndex(where: {
                $0.trimmingCharacters(in: .init(charactersIn: " \"")).lowercased() == candidate.lowercased()
            }) {
                return idx
            }
        }
        return nil
    }
}
