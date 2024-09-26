//
// Copyright © 2024 Alexander Romanov
// Version.swift, created on 23.07.2024
//

import AppStoreConnect

public struct Version {
    public let id: String
    public let version: String
    public let appStoreState: String
    init?(schema: AppStoreConnect.AppStoreVersion) {
        guard let state = schema.attributes?.appStoreState,
              let version = schema.attributes?.versionString else { return nil }
        appStoreState = state.rawValue
        self.version = version
        id = schema.id
    }
}
