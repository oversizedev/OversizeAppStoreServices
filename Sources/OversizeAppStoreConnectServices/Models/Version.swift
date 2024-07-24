//
// Copyright © 2024 Alexander Romanov
// File.swift, created on 23.07.2024
//  

import AppStoreConnect

public struct Version {
    public let version: String
    let appStoreState: String
    let id: String
    init?(schema: AppStoreConnect.AppStoreVersion) {
        guard let state = schema.attributes?.appStoreState,
              let version = schema.attributes?.versionString else { return nil }
        self.appStoreState = state.rawValue
        self.version = version
        self.id = schema.id
    }
}

