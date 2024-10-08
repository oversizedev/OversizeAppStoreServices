//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionLocalization.swift, created on 22.07.2024
//

import AppStoreAPI
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

    init?(schema: AppStoreAPI.AppStoreVersionLocalization) {
        description = schema.attributes?.description
        locale = schema.attributes?.locale
        keywords = schema.attributes?.keywords
        marketingURL = schema.attributes?.marketingURL
        promotionalText = schema.attributes?.promotionalText
        supportURL = schema.attributes?.supportURL
        whatsNew = schema.attributes?.whatsNew
    }
}
