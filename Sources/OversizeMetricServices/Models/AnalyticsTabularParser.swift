//
// Copyright © 2026 Alexander Romanov
// AnalyticsTabularParser.swift, created on 11.07.2026
//

import Foundation

public enum AnalyticsTabularParser {
    public static func parse(data: Data, processingDate: String) -> AnalyticsReportData? {
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard let headerLine = lines.first else { return nil }

        let delimiter = detectDelimiter(firstLine: headerLine)
        let headers = split(line: headerLine, delimiter: delimiter).map { normalize(field: $0) }
        guard !headers.isEmpty else { return nil }

        let rows: [[String]] = lines.dropFirst().compactMap { line in
            let columns = split(line: line, delimiter: delimiter).map { normalize(field: $0) }
            guard columns.contains(where: { !$0.isEmpty }) else { return nil }
            return columns
        }

        return AnalyticsReportData(
            headers: headers,
            rows: rows,
            processingDate: processingDate,
        )
    }

    static func normalize(field: String) -> String {
        field.trimmingCharacters(in: .init(charactersIn: " \""))
    }

    static func detectDelimiter(firstLine: String) -> Character {
        let tabCount = firstLine.count(where: { $0 == "\t" })
        let commaCount = firstLine.count(where: { $0 == "," })
        return tabCount >= commaCount ? "\t" : ","
    }

    static func split(line: String, delimiter: Character) -> [String] {
        if delimiter == "," {
            return splitCSV(line: line)
        }
        return line.components(separatedBy: "\t")
    }

    static func splitCSV(line: String) -> [String] {
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
}
