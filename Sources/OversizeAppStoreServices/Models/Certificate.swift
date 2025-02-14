//
// Copyright © 2024 Alexander Romanov
// Certificate.swift, created on 23.07.2024
//

import AppStoreAPI

import Foundation

public struct Certificate: Sendable {
    public let id: String
    public let name: String
    public let platform: BundleIDPlatform
    public let type: CertificateType
    public let content: String
    public var expirationDate: Date

    init?(schema: AppStoreAPI.Certificate) {
        guard let name = schema.attributes?.name,
              let type = CertificateType(rawValue: schema.attributes?.certificateType?.rawValue ?? ""),
              let content = schema.attributes?.certificateContent,
              let platformRawValue = schema.attributes?.platform?.rawValue,
              let platform: BundleIDPlatform = .init(rawValue: platformRawValue),
              let expirationDate = schema.attributes?.expirationDate
        else { return nil }
        id = schema.id
        self.name = name
        self.platform = platform
        self.type = type
        self.content = content
        self.expirationDate = expirationDate
    }
}

extension Certificate {
    static func from(response: AppStoreAPI.CertificatesResponse, include: (Certificate) -> Bool) -> [Certificate] {
        response.data.compactMap { Certificate(schema: $0) }.filter { include($0) }
    }
}

private extension AppStoreAPI.CertificateType {
    init?(from certType: CertificateType) {
        guard let resolved = Self(rawValue: certType.rawValue) else { return nil }
        self = resolved
    }
}
