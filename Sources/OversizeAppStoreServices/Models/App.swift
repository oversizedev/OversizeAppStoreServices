//
// Copyright © 2024 Alexander Romanov
// App.swift, created on 21.07.2024
//

import AppStoreConnect

public struct App: Identifiable {
    public let id: String
    public let name: String
    public let bundleID: String
    public let sku: String
    public let primaryLocale: String
    public let contentRightsDeclaration: ContentRightsDeclaration?

    init?(schema: AppStoreConnect.App) {
        guard let bundleID = schema.attributes?.bundleID,
              let name = schema.attributes?.name,
              let sku = schema.attributes?.sku,
              let primaryLocale = schema.attributes?.primaryLocale
        else { return nil }
        id = schema.id
        self.name = name
        self.bundleID = bundleID
        self.sku = sku
        self.primaryLocale = primaryLocale
        switch schema.attributes?.contentRightsDeclaration {
        case .doesNotUseThirdPartyContent:
            contentRightsDeclaration = .notUseThirdPartyContent
        case .usesThirdPartyContent:
            contentRightsDeclaration = .usesThirdPartyContent
        case .none:
            contentRightsDeclaration = .none
        }
    }
}
