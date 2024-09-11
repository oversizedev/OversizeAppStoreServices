//
// Copyright © 2024 Alexander Romanov
// File.swift, created on 23.08.2024
//

import Foundation

public enum ContentRightsDeclaration: String, CaseIterable, Codable, Sendable {
    case doesNotUseThirdPartyContent = "DOES_NOT_USE_THIRD_PARTY_CONTENT"
    case usesThirdPartyContent = "USES_THIRD_PARTY_CONTENT"
}
