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
        locale = schema.attributes?.locale
        name = schema.attributes?.name
        subtitle = schema.attributes?.subtitle
        privacyPolicyURL = schema.attributes?.privacyPolicyURL
        privacyChoicesURL = schema.attributes?.privacyChoicesURL
        privacyPolicyText = schema.attributes?.privacyPolicyText
    }
}
