//
// Copyright © 2025 Alexander Romanov
// AppMediaStateError.swift, created on 01.12.2025
//

import AppStoreAPI
import Foundation

public struct AppMediaStateError: Codable, Equatable, Sendable {
    public let code: String?
    public let description: String?

    public init(code: String? = nil, description: String? = nil) {
        self.code = code
        self.description = description
    }

    public init(schema: AppStoreAPI.AppMediaStateError) {
        code = schema.code
        description = schema.description
    }
}
