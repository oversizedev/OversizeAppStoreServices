//
// Copyright © 2024 Alexander Romanov
// ReviewType.swift, created on 06.10.2024
//  

import Foundation

public enum ReviewType: String, CaseIterable, Codable, Sendable {
    case appStore = "APP_STORE"
    case notarization = "NOTARIZATION"
}
