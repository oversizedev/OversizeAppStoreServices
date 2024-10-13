//
// Copyright © 2024 Alexander Romanov
// App.swift, created on 21.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public struct App: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let bundleID: String
    public let sku: String
    public let primaryLocale: AppStoreLanguage
    public let contentRightsDeclaration: ContentRightsDeclaration?
    public let isOrEverWasMadeForKids: Bool?
    public let subscriptionStatusURL: URL?
    public let subscriptionStatusURLVersion: SubscriptionStatusURLVersion?
    public let subscriptionStatusURLForSandbox: URL?
    public let subscriptionStatusURLVersionForSandbox: SubscriptionStatusURLVersion?

    public init?(schema: AppStoreAPI.App) {
        guard let bundleID = schema.attributes?.bundleID,
              let name = schema.attributes?.name,
              let sku = schema.attributes?.sku,
              let primaryLocaleRawValue = schema.attributes?.primaryLocale,
              let primaryLocale: AppStoreLanguage = .init(rawValue: primaryLocaleRawValue)
        else { return nil }
        id = schema.id
        self.name = name
        self.bundleID = bundleID
        self.sku = sku
        self.primaryLocale = primaryLocale
        if let contentRightsDeclaration = schema.attributes?.contentRightsDeclaration?.rawValue {
            self.contentRightsDeclaration = .init(rawValue: contentRightsDeclaration)
        } else {
            contentRightsDeclaration = .none
        }
        isOrEverWasMadeForKids = schema.attributes?.isOrEverWasMadeForKids
        subscriptionStatusURL = schema.attributes?.subscriptionStatusURL
        subscriptionStatusURLForSandbox = schema.attributes?.subscriptionStatusURLForSandbox
        if let subscriptionStatusURLVersion = schema.attributes?.subscriptionStatusURLVersion?.rawValue {
            self.subscriptionStatusURLVersion = .init(rawValue: subscriptionStatusURLVersion)
        } else {
            subscriptionStatusURLVersion = .none
        }
        if let subscriptionStatusURLVersionForSandbox = schema.attributes?.subscriptionStatusURLVersionForSandbox?.rawValue {
            self.subscriptionStatusURLVersionForSandbox = .init(rawValue: subscriptionStatusURLVersionForSandbox)
        } else {
            subscriptionStatusURLVersionForSandbox = .none
        }
    }
}
