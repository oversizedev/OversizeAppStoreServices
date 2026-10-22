//
// Copyright © 2026 Alexander Romanov
// AnalyticsReportInstance.swift, created on 11.07.2026
//

import AppStoreAPI
import Foundation
import OversizeCore

public struct AnalyticsReportInstance: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public let granularity: Granularity
    public let processingDate: String

    public enum Granularity: String, CaseIterable, Codable, Sendable, Identifiable {
        case daily = "DAILY"
        case weekly = "WEEKLY"
        case monthly = "MONTHLY"

        public var id: String {
            rawValue
        }

        public var title: String {
            rawValue.lowercased().capitalizingFirstLetter()
        }
    }

    public init(id: String, granularity: Granularity, processingDate: String) {
        self.id = id
        self.granularity = granularity
        self.processingDate = processingDate
    }

    init?(schema: AppStoreAPI.AnalyticsReportInstance) {
        guard let granularityRawValue = schema.attributes?.granularity?.rawValue,
              let granularity = Granularity(rawValue: granularityRawValue),
              let processingDate = schema.attributes?.processingDate
        else { return nil }
        id = schema.id
        self.granularity = granularity
        self.processingDate = processingDate
    }

    public var date: Date? {
        Self.dateFormatter.date(from: processingDate)
    }

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}
