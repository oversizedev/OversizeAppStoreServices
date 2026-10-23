//
// Copyright © 2026 Alexander Romanov
// BuildDeviceFamilies.swift, created on 23.10.2026
//

import Foundation

public struct BuildDeviceFamilies: Sendable, Equatable {
    public let supportsiPhone: Bool
    public let supportsiPad: Bool
    public let deviceProtocols: [String]

    public init(deviceProtocols: [String]) {
        let lowercased = deviceProtocols.map { $0.lowercased() }
        self.deviceProtocols = deviceProtocols
        supportsiPhone = lowercased.contains { $0.contains("iphone") || $0.contains("ipod") }
        supportsiPad = lowercased.contains { $0.contains("ipad") }
    }

    public init(supportsiPhone: Bool, supportsiPad: Bool) {
        self.supportsiPhone = supportsiPhone
        self.supportsiPad = supportsiPad
        deviceProtocols = []
    }

    public var isRecognized: Bool {
        supportsiPhone || supportsiPad
    }
}
