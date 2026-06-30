//
// Copyright © 2025 Alexander Romanov
// Bool.swift, created on 11.11.2025
//

// Kept internal so consumers (e.g. the kit) resolve the identical OversizeCore helper
// without ambiguity, while the models keep it available on non-Apple platforms.
extension Optional where Wrapped == Bool {
    var valueOrFalse: Bool {
        guard let unwrapped = self else {
            return false
        }
        return unwrapped
    }
}
