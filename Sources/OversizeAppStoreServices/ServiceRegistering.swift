//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

import Factory

public extension Container {
    var keychainService: Factory<KeychainService> {
        self { KeychainService() }
    }

    var appsService: Factory<AppsService> {
        self { AppsService() }
    }

    var inAppPurchasesService: Factory<InAppPurchasesService> {
        self { InAppPurchasesService() }
    }

    var certificateService: Factory<CertificateService> {
        self { CertificateService() }
    }

    var reviewService: Factory<ReviewService> {
        self { ReviewService() }
    }

    var usersService: Factory<UsersService> {
        self { UsersService() }
    }
}
