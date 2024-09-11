//
// Copyright © 2024 Alexander Romanov
// ProcessingState.swift, created on 28.08.2024
//

import Foundation

public enum ProcessingState: String, CaseIterable, Codable {
    case processing = "PROCESSING"
    case failed = "FAILED"
    case invalid = "INVALID"
    case valid = "VALID"
}
