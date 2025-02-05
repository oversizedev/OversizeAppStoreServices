//
// Copyright © 2024 Alexander Romanov
// Profile.swift, created on 23.07.2024
//

import AppStoreAPI

public struct Profile: Sendable {
    public let name: String
    public let platform: BundleIDPlatform
    public let content: String
    public let isActive: Bool

    init?(schema: AppStoreAPI.Profile) {
        guard let name = schema.attributes?.name,
              let content = schema.attributes?.profileContent,
              let state = schema.attributes?.profileState,
              let platformRawValue = schema.attributes?.platform?.rawValue,
              let platform: BundleIDPlatform = .init(rawValue: platformRawValue)
        else { return nil }

        self.name = name
        self.platform = platform
        self.content = content
        isActive = state == .active
    }
}

extension Profile {
    static func from(_ response: AppStoreAPI.ProfilesResponse, include: (Profile) -> Bool) -> [Profile] {
        response.data.compactMap { Profile(schema: $0) }.filter { include($0) }
    }
}
