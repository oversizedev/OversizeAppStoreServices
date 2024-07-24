//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionLocalization.swift, created on 22.07.2024
//

import AppStoreConnect
import Foundation

public struct VersionLocalization {
    public let description: String?
    public let locale: String?
    public let keywords: String?
    public let marketingURL: URL?
    public let promotionalText: String?
    public let supportURL: URL?
    public let whatsNew: String?

    init?(schema: AppStoreConnect.AppStoreVersionLocalization) {
        self.description = schema.attributes?.description
        self.locale = schema.attributes?.locale
        self.keywords = schema.attributes?.keywords
        self.marketingURL = schema.attributes?.marketingURL
        self.promotionalText = schema.attributes?.promotionalText
        self.supportURL = schema.attributes?.supportURL
        self.whatsNew = schema.attributes?.whatsNew
    }
}

