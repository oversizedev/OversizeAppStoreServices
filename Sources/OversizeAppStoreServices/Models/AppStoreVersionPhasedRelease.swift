//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionPhasedRelease.swift, created on 23.04.2026
//

import AppStoreAPI
import Foundation

public struct AppStoreVersionPhasedRelease: Sendable, Identifiable {
    public let id: String
    public let phasedReleaseState: PhasedReleaseState?
    public let startDate: Date?
    public let totalPauseDuration: Int?
    public let currentDayNumber: Int?

    public init?(schema: AppStoreAPI.AppStoreVersionPhasedRelease) {
        id = schema.id
        phasedReleaseState = schema.attributes?.phasedReleaseState.flatMap {
            PhasedReleaseState(rawValue: $0.rawValue)
        }
        startDate = schema.attributes?.startDate
        totalPauseDuration = schema.attributes?.totalPauseDuration
        currentDayNumber = schema.attributes?.currentDayNumber
    }

    public enum PhasedReleaseState: String, CaseIterable, Codable, Sendable {
        case inactive = "INACTIVE"
        case active = "ACTIVE"
        case paused = "PAUSED"
        case complete = "COMPLETE"
    }
}
