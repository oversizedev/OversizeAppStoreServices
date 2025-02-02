//
// Copyright © 2024 Alexander Romanov
// AnalyticsReportRequest.swift, created on 25.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public struct AnalyticsReportRequest: Identifiable, Sendable {
    public let id: String
    public var accessType: AccessType?
    public var isStoppedDueToInactivity: Bool?

    public let included: Included?

    init?(schema: AppStoreAPI.AnalyticsReportRequest, included: [AppStoreAPI.AnalyticsReport]? = nil) {
        guard let accessTypeRawValue = schema.attributes?.accessType?.rawValue,
              let accessType: AccessType = .init(rawValue: accessTypeRawValue) else { return nil }
        id = schema.id
        self.accessType = accessType
        isStoppedDueToInactivity = schema.attributes?.isStoppedDueToInactivity

        if let analyticsReport = included?.filter { $0.id == schema.relationships?.reports?.data?.first?.id } {
            self.included = .init(analyticsReports: analyticsReport.compactMap { .init(schema: $0) })
        } else {
            self.included = nil
        }
    }

    public enum AccessType: String, CaseIterable, Codable, Sendable {
        case oneTimeSnapshot = "ONE_TIME_SNAPSHOT"
        case ongoing = "ONGOING"
    }

    public struct Included: Sendable {
        public let analyticsReports: [AnalyticsReport]?
    }
}
