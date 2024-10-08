//
// Copyright © 2024 Alexander Romanov
// Profile.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect

public struct Profile {
    public let name: String
    public let platform: BundleID.Platform
    public let content: String
    public let isActive: Bool

    init?(schema: AppStoreAPI.Profile) {
        guard let name = schema.attributes?.name,
              let content = schema.attributes?.profileContent,
              let state = schema.attributes?.profileState,
              let platform = schema.attributes?.platform
        else { return nil }

        self.name = name
        self.platform = BundleID.Platform(schema: platform)
        self.content = content
        isActive = state == .active
    }
}

extension Profile {
    static func from(_ response: AppStoreAPI.ProfilesResponse, include: (Profile) -> Bool) -> [Profile] {
        response.data.compactMap { Profile(schema: $0) }.filter { include($0) }
    }
}
