//
// Copyright © 2025 Alexander Romanov
// Bool.swift, created on 11.11.2025
//

public extension Bool? {
    var valueOrFalse: Bool {
        guard let unwrapped = self else {
            return false
        }
        return unwrapped
    }
}
