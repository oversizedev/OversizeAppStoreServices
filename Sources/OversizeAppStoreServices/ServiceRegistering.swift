//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

import FactoryKit

public extension Container {
    var appsService: Factory<AppsService> {
        self { AppsService() }
    }

    var inAppPurchasesService: Factory<InAppPurchasesService> {
        self { InAppPurchasesService() }
    }

    var subscriptionsService: Factory<SubscriptionsService> {
        self { SubscriptionsService() }
    }

    var certificateService: Factory<CertificateService> {
        self { CertificateService() }
    }

    var customerReviewService: Factory<CustomerReviewService> {
        self { CustomerReviewService() }
    }

    var usersService: Factory<UsersService> {
        self { UsersService() }
    }

    var buildsService: Factory<BuildsService> {
        self { BuildsService() }
    }

    var versionsService: Factory<VersionsService> {
        self { VersionsService() }
    }

    var appInfoService: Factory<AppInfoService> {
        self { AppInfoService() }
    }

    var appStoreReviewService: Factory<AppStoreReviewService> {
        self { AppStoreReviewService() }
    }

    var appCategoryService: Factory<AppCategoryService> {
        self { AppCategoryService() }
    }

    var appStoreVersionSubmissionsService: Factory<AppStoreVersionSubmissionsService> {
        self { AppStoreVersionSubmissionsService() }
    }

    var cacheService: Factory<CacheService> {
        self { CacheService() }
    }
}
