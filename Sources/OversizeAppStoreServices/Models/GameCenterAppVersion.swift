//
// Copyright © 2024 Alexander Romanov
// GameCenterAppVersion.swift, created on 23.04.2026
//

import AppStoreAPI

public struct GameCenterAppVersion: Sendable, Identifiable {
    public let id: String
    public let isEnabled: Bool?

    public init?(schema: AppStoreAPI.GameCenterAppVersion) {
        id = schema.id
        isEnabled = schema.attributes?.isEnabled
    }
}
