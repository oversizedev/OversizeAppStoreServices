//
// Copyright © 2026 Alexander Romanov
// AppStoreConnectCredentials.swift, created on 08.07.2026
//

#if canImport(Darwin)
import Foundation
import OversizeServices

public struct AppStoreConnectCredentials: Codable, Sendable, Equatable {
    public let issuerID: String
    public let keyID: String
    public let privateKey: String
    public let vendorNumber: String?

    public init(issuerID: String, keyID: String, privateKey: String, vendorNumber: String? = nil) {
        self.issuerID = issuerID
        self.keyID = keyID
        self.privateKey = privateKey
        self.vendorNumber = vendorNumber
    }
}
#endif
