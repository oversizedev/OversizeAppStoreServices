//
// Copyright © 2025 Alexander Romanov
// String.swift, created on 23.03.2025
//

import Foundation

public extension String {
    func toDate(formatOptions: ISO8601DateFormatter.Options = .withFullDate) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = formatOptions
        return formatter.date(from: self)
    }
}

public extension String? {
    var valueOrEmpty: String {
        guard let unwrapped = self else {
            return ""
        }
        return unwrapped
    }
}
