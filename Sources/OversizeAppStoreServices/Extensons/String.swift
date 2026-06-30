//
// Copyright © 2025 Alexander Romanov
// String.swift, created on 23.03.2025
//

import Foundation

// Kept internal so consumers (e.g. the kit) resolve the identical OversizeCore helpers
// without ambiguity, while the models keep them available on non-Apple platforms.
extension String {
    func toDate(formatOptions: ISO8601DateFormatter.Options = .withFullDate) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = formatOptions
        return formatter.date(from: self)
    }
}

extension Optional where Wrapped == String {
    var valueOrEmpty: String {
        guard let unwrapped = self else {
            return ""
        }
        return unwrapped
    }
}
