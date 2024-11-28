//
// Copyright © 2024 Alexander Romanov
// AnalyticsReport.swift, created on 25.11.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeCore

public struct AnalyticsReport: Identifiable, Hashable, Sendable {
    public let id: String
    public var name: String
    public var category: Category

    init?(schema: AppStoreAPI.AnalyticsReport) {
        guard let categoryRawValue = schema.attributes?.category?.rawValue,
              let category: Category = .init(rawValue: categoryRawValue),
              let name: String = schema.attributes?.name
        else { return nil }
        id = schema.id
        self.category = category
        self.name = name
    }

    public enum Category: String, CaseIterable, Codable, Sendable {
        case appUsage = "APP_USAGE"
        case appStoreEngagement = "APP_STORE_ENGAGEMENT"
        case commerce = "COMMERCE"
        case frameworkUsage = "FRAMEWORK_USAGE"
        case performance = "PERFORMANCE"
    }
}
