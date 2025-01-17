//
// Copyright © 2025 Aleksandr Romanov
// UploadOperation.swift, created on 17.01.2025
//

import AppStoreAPI

public struct UploadOperation: Codable, Equatable, Sendable {
    public let method: String?
    public let url: String?
    public let length: Int?
    public let offset: Int?

    public init(schema: AppStoreAPI.UploadOperation) {
        method = schema.method
        url = schema.url
        length = schema.length
        offset = schema.offset
    }
}
