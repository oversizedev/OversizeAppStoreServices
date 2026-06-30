//
// Copyright © 2024 Alexander Romanov
// SalesReports.swift, created on 26.11.2024
//

import CodableCSV
import Foundation

public struct SalesReports: Sendable {
    public let reports: [Report]
    public let totalRows: Int?
    public let totalAmount: Double?
    public let totalUnits: Int?

    public struct Report: Sendable {
        public let startDate: String

        public init(
            startDate: String,
        ) {
            self.startDate = startDate
        }
    }

    init?(data: Data) {
        guard let csvString = String(data: data, encoding: .utf8) else { return nil }
        print("Row CSV data:")
        print(csvString)

        do {
            return nil
        } catch {
            return nil
        }
    }
}
