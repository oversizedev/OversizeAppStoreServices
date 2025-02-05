//
// Copyright © 2025 Aleksandr Romanov
// IntegerRange.swift, created on 05.02.2025
//  

import Foundation
import AppStoreAPI
import OversizeCore

public struct IntegerRange: Sendable {
    public let minimum: Int?
    public let maximum: Int?
    
    public init(schema: AppStoreAPI.IntegerRange) {
        minimum = schema.minimum
        maximum = schema.maximum
    }
    
    public init(
        minimum: Int? = nil,
        maximum: Int? = nil
    ) {
        self.minimum = minimum
        self.maximum = maximum
    }
}

// MARK: - CustomStringConvertible

extension IntegerRange: CustomStringConvertible {
    public var description: String {
        switch (minimum, maximum) {
        case let (min?, max?):
            return "\(min)-\(max)"
        case let (min?, nil):
            return "≥\(min)"
        case let (nil, max?):
            return "≤\(max)"
        case (nil, nil):
            return "undefined"
        }
    }
}

// MARK: - Equatable

extension IntegerRange: Equatable {
    public static func == (lhs: IntegerRange, rhs: IntegerRange) -> Bool {
        lhs.minimum == rhs.minimum && lhs.maximum == rhs.maximum
    }
}
