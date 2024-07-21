//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

import Factory
import Foundation

public extension Container {
    var appStoreConnectService: Factory<AppStoreConnectServices> {
        self { AppStoreConnectServices() }
    }
}
