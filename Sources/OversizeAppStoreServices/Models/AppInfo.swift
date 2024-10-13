//
// Copyright © 2024 Alexander Romanov
// AppInfo.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeCore

public struct AppInfo: Sendable {
    public let id: String
    public let primaryCategoryId: String?
    public let secondaryCategoryId: String?
    public var primaryCategory: String {
        return primaryCategoryId?.capitalizingFirstLetter() ?? ""
    }

    public init?(schema: AppStoreAPI.AppInfo) {
        id = schema.id
        primaryCategoryId = schema.relationships?.primaryCategory?.data?.id
        secondaryCategoryId = schema.relationships?.secondaryCategory?.data?.id
    }
}
