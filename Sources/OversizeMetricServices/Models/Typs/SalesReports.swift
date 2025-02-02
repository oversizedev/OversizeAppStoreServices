//
// Copyright © 2024 Alexander Romanov
// SalesReports.swift, created on 26.11.2024
//

import CodableCSV
import Foundation
import OversizeCore

public struct SalesReports: Sendable {
    public let reports: [Report]
    public let totalRows: Int?
    public let totalAmount: Double?
    public let totalUnits: Int?

    public struct Report: Sendable {
        public let startDate: String

        public init(
            startDate: String
        ) {
            self.startDate = startDate
        }
    }

    init?(data: Data) {
        guard let csvString = String(data: data, encoding: .utf8) else { return nil }
        logNotice("Row CSV data:")
        print(csvString)

        do {
            return nil

//            let reader = try CSVReader(input: csvString) {
//                $0.headerStrategy = .firstLine
//                $0.delimiters.field = "\t"
//                $0.presample = true
//            }
//
//            reports = reader.compactMap {
//                 .init(
//                     startDate: $0.element(0).valueOrEmpty,
//                 )
//             }
//
//            // Assign the extracted total values
//            self.totalRows = totalRows
//            self.totalAmount = totalAmount
//            self.totalUnits = totalUnits

        } catch {
            return nil
        }
    }
}
