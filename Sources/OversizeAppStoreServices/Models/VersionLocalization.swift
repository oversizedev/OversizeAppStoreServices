//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionLocalization.swift, created on 22.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public struct VersionLocalization: Identifiable, Hashable, Sendable {
    public let locale: AppStoreLanguage
    public let description: String?
    public let keywords: String?
    public let marketingURL: URL?
    public let promotionalText: String?
    public let supportURL: URL?
    public let whatsNew: String?

    init?(schema: AppStoreAPI.AppStoreVersionLocalization) {
        guard let localeRawValue = schema.attributes?.locale,
              let locale: AppStoreLanguage = .init(rawValue: localeRawValue) else { return nil }

        self.locale = locale
        description = schema.attributes?.description
        keywords = schema.attributes?.keywords
        marketingURL = schema.attributes?.marketingURL
        promotionalText = schema.attributes?.promotionalText
        supportURL = schema.attributes?.supportURL
        whatsNew = schema.attributes?.whatsNew
    }

    public var id: String {
        return locale.rawValue
    }
}
