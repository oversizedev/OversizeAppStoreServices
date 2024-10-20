//
// Copyright © 2024 Alexander Romanov
// AppInfoLocalization.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public struct AppInfoLocalization: Sendable {
    public let id: String
    public let locale: AppStoreLanguage?
    public let name: String?
    public let subtitle: String?
    public let privacyPolicyURL: URL?
    public let privacyChoicesURL: URL?
    public let privacyPolicyText: String?

    public init?(schema: AppStoreAPI.AppInfoLocalization) {
        guard let localeRawValue = schema.attributes?.locale,
              let locale: AppStoreLanguage = .init(rawValue: localeRawValue)
        else { return nil }
        self.locale = locale
        id = schema.id
        name = schema.attributes?.name
        subtitle = schema.attributes?.subtitle
        privacyPolicyURL = URL(string: schema.attributes?.privacyPolicyURL ?? "")
        privacyChoicesURL = URL(string: schema.attributes?.privacyPolicyURL ?? "")
        privacyPolicyText = schema.attributes?.privacyPolicyText
    }
}
