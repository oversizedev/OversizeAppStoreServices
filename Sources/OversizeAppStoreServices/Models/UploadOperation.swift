//
// Copyright © 2025 Alexander Romanov
// UploadOperation.swift, created on 17.01.2025
//

import AppStoreAPI

public struct UploadOperation: Codable, Equatable, Sendable {
    public let method: String?
    public let url: String?
    public let length: Int?
    public let offset: Int?
    public let requestHeaders: [RequestHeader]

    public struct RequestHeader: Codable, Equatable, Sendable {
        public let name: String?
        public let value: String?

        public init(name: String?, value: String?) {
            self.name = name
            self.value = value
        }
    }

    public init(schema: AppStoreAPI.UploadOperation) {
        method = schema.method
        url = schema.url
        length = schema.length
        offset = schema.offset
        requestHeaders = schema.requestHeaders?.map { RequestHeader(name: $0.name, value: $0.value) } ?? []
    }
}
