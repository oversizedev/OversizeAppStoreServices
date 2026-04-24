//
// Copyright © 2024 Alexander Romanov
// AlternativeDistributionPackage.swift, created on 23.04.2026
//

import AppStoreAPI

public struct AlternativeDistributionPackage: Sendable, Identifiable {
    public let id: String

    public init?(schema: AppStoreAPI.AlternativeDistributionPackage) {
        id = schema.id
    }
}
