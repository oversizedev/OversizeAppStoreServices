//
// Copyright © 2026 Alexander Romanov
// AnalyticsMetricPoint.swift, created on 11.07.2026
//

import Foundation

public struct AnalyticsMetricPoint: Sendable, Codable, Equatable, Identifiable {
    public let date: Date
    public let value: Double

    public var id: Date {
        date
    }

    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

public enum DashboardMetric: String, CaseIterable, Sendable, Identifiable {
    case downloads
    case impressions
    case sessions

    public var id: String {
        rawValue
    }

    public var title: String {
        switch self {
        case .downloads: "Downloads"
        case .impressions: "Impressions"
        case .sessions: "Sessions"
        }
    }

    public var category: AnalyticsReport.Category {
        switch self {
        case .downloads: .commerce
        case .impressions: .appStoreEngagement
        case .sessions: .appUsage
        }
    }

    public var reportNameCandidates: [String] {
        switch self {
        case .downloads: ["App Store Downloads", "App Downloads"]
        case .impressions: ["App Store Discovery and Engagement", "App Store Engagement"]
        case .sessions: ["App Sessions"]
        }
    }

    public var valueColumnCandidates: [String] {
        switch self {
        case .downloads: ["Counts", "Total Downloads", "Downloads"]
        case .impressions: ["Counts", "Impressions"]
        case .sessions: ["Sessions", "Counts"]
        }
    }

    public var rowFilter: RowFilter? {
        switch self {
        case .impressions:
            RowFilter(
                columnCandidates: ["Event", "Event Type"],
                allowedValues: ["Impression", "Impressions"],
            )
        default:
            nil
        }
    }

    public struct RowFilter: Sendable {
        public let columnCandidates: [String]
        public let allowedValues: [String]
    }
}

public extension [AnalyticsReport] {
    func pickReport(matching candidates: [String]) -> AnalyticsReport? {
        let matched = filter { report in
            candidates.contains { report.name.localizedCaseInsensitiveContains($0) }
        }
        guard !matched.isEmpty else { return nil }
        return matched.first { $0.name.localizedCaseInsensitiveContains("standard") } ?? matched.first
    }
}
