//
// Copyright © 2024 Alexander Romanov
// PrereleaseVersion.swift, created on 29.10.2024
//

import AppStoreAPI

import OversizeCore

public struct PrereleaseVersion: Sendable {
    public let id: String
    public let version: String
    public let platform: Platform

    public var included: Included?

    public init?(schema: AppStoreAPI.PrereleaseVersion, builds: [AppStoreAPI.Build]) {
        guard let platformRawValue = schema.attributes?.platform?.rawValue,
              let platform = Platform(rawValue: platformRawValue)
        else { return nil }
        self.platform = platform
        id = schema.id
        version = schema.attributes?.version ?? ""

        included = .init(
            builds: builds.compactMap { .init(schema: $0) }
        )
    }

    public struct Included: Sendable {
        public let builds: [Build]
    }
}
