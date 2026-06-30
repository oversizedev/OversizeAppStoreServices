//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

#if canImport(Darwin)
import FactoryKit

public extension Container {
    var appsService: Factory<AppsService> {
        self { AppsService(authenticator: EnvAuthenticator()) }
    }

    var inAppPurchasesService: Factory<InAppPurchasesService> {
        self { InAppPurchasesService(authenticator: EnvAuthenticator()) }
    }

    var subscriptionsService: Factory<SubscriptionsService> {
        self { SubscriptionsService(authenticator: EnvAuthenticator()) }
    }

    var certificateService: Factory<CertificateService> {
        self { CertificateService(authenticator: EnvAuthenticator()) }
    }

    var customerReviewService: Factory<CustomerReviewService> {
        self { CustomerReviewService(authenticator: EnvAuthenticator()) }
    }

    var usersService: Factory<UsersService> {
        self { UsersService(authenticator: EnvAuthenticator()) }
    }

    var buildsService: Factory<BuildsService> {
        self { BuildsService(authenticator: EnvAuthenticator()) }
    }

    var versionsService: Factory<VersionsService> {
        self { VersionsService(authenticator: EnvAuthenticator()) }
    }

    var appInfoService: Factory<AppInfoService> {
        self { AppInfoService(authenticator: EnvAuthenticator()) }
    }

    var appStoreReviewService: Factory<AppStoreReviewService> {
        self { AppStoreReviewService(authenticator: EnvAuthenticator()) }
    }

    var appCategoryService: Factory<AppCategoryService> {
        self { AppCategoryService(authenticator: EnvAuthenticator()) }
    }

    var reviewSubmissionsService: Factory<ReviewSubmissionsService> {
        self { ReviewSubmissionsService(authenticator: EnvAuthenticator()) }
    }

    var appScreenshotsService: Factory<AppScreenshotsService> {
        self { AppScreenshotsService(authenticator: EnvAuthenticator()) }
    }

    var cacheService: Factory<CacheService> {
        self { CacheService() }
    }
}
#endif
