//
// Copyright © 2024 Alexander Romanov
// AppClipDefaultExperience.swift, created on 23.04.2026
//

import AppStoreAPI

public struct AppClipDefaultExperience: Sendable, Identifiable {
    public let id: String
    public let action: AppClipAction?

    public init?(schema: AppStoreAPI.AppClipDefaultExperience) {
        id = schema.id
        action = schema.attributes?.action.flatMap { AppClipAction(rawValue: $0.rawValue) }
    }

    public enum AppClipAction: String, CaseIterable, Codable, Sendable {
        case open = "OPEN"
        case view = "VIEW"
        case play = "PLAY"
    }
}
