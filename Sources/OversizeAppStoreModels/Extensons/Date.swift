//
// Copyright © 2025 Alexander Romanov
// Date.swift, created on 23.03.2025
//

import Foundation

extension Date: @retroactive RawRepresentable {
    public var rawValue: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }

    public init?(rawValue: String) {
        let formatter = ISO8601DateFormatter()
        self = formatter.date(from: rawValue) ?? Date()
    }
}
