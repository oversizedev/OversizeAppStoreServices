//
// Copyright © 2024 Alexander Romanov
// AppInfoLocalization.swift, created on 23.07.2024
//

import AppStoreConnect

public struct AppInfoLocalization {
    public let locale: String?
    public let name: String?
    public let subtitle: String?
    public let privacyPolicyURL: String?
    public let privacyChoicesURL: String?
    public let privacyPolicyText: String?

    init?(schema: AppStoreConnect.AppInfoLocalization) {
        self.locale = schema.attributes?.locale
        self.name = schema.attributes?.name
        self.subtitle = schema.attributes?.subtitle
        self.privacyPolicyURL = schema.attributes?.privacyPolicyURL
        self.privacyChoicesURL = schema.attributes?.privacyChoicesURL
        self.privacyPolicyText = schema.attributes?.privacyPolicyText
    }
}
