//
// Copyright © 2024 Alexander Romanov
// App.swift, created on 21.07.2024
//  

import AppStoreConnect

public struct App {
    public let id: String
    public let name: String
    public let bundleID: String

    init?(schema: AppStoreConnect.App) {
        guard let bundleID = schema.attributes?.bundleID,
              let name = schema.attributes?.name
        else { return nil }
        id = schema.id
        self.name = name
        self.bundleID = bundleID
    }
}
