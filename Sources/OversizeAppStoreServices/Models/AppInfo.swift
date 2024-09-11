//
// Copyright © 2024 Alexander Romanov
// AppInfo.swift, created on 23.07.2024
//

import AppStoreConnect
import OversizeCore

public struct AppInfo {
    public let id: String
    public let primaryCategoryId: String?
    public let secondaryCategoryId: String?
    public var primaryCategory: String {
        return primaryCategoryId?.capitalizingFirstLetter() ?? ""
    }

    public init?(schema: AppStoreConnect.AppInfo) {
        id = schema.id
        primaryCategoryId = schema.relationships?.primaryCategory?.data?.id
        secondaryCategoryId = schema.relationships?.secondaryCategory?.data?.id
    }
}
