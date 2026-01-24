//
// Copyright © 2025 Alexander Romanov
// InAppPurchaseContent.swift, created on 17.01.2025
//

import AppStoreAPI
import Foundation

public struct InAppPurchaseContent: Identifiable, Sendable {
    public let id: String
    public let fileName: String?
    public let fileSize: Int?
    public let url: URL?
    public let lastModifiedDate: Date?
    public let relationships: Relationships

    public init?(schema: AppStoreAPI.InAppPurchaseContent) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        fileName = attributes.fileName
        fileSize = attributes.fileSize
        url = attributes.url
        lastModifiedDate = attributes.lastModifiedDate
        relationships = .init(inAppPurchaseV2Id: schema.relationships?.inAppPurchaseV2?.data?.id)
    }

    public struct Relationships: Sendable {
        public let inAppPurchaseV2Id: String?

        public init(inAppPurchaseV2Id: String?) {
            self.inAppPurchaseV2Id = inAppPurchaseV2Id
        }
    }
}
