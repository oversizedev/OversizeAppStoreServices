//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionSubmission.swift, created on 23.04.2026
//

import AppStoreAPI

public struct AppStoreVersionSubmission: Sendable, Identifiable {
    public let id: String
    public let appStoreVersionId: String?

    public init?(schema: AppStoreAPI.AppStoreVersionSubmission) {
        id = schema.id
        appStoreVersionId = schema.relationships?.appStoreVersion?.data?.id
    }
}
