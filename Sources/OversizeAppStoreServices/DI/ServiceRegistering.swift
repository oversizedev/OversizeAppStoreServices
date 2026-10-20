//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

#if canImport(Darwin)
import FactoryKit

public extension Container {
    var appStoreConfiguration: Factory<Result<ASCAccountConfiguration, Error>> {
        self { .failure(ASCAuthenticationError.missingCredentials) }
    }

    var appsService: Factory<AppsServicesProtocol> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return AppsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var inAppPurchasesService: Factory<InAppPurchasesService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return InAppPurchasesService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var subscriptionsService: Factory<SubscriptionsService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return SubscriptionsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var certificateService: Factory<CertificateService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return CertificateService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var customerReviewService: Factory<CustomerReviewService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return CustomerReviewService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var usersService: Factory<UsersService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return UsersService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var buildsService: Factory<BuildsService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return BuildsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var versionsService: Factory<any VersionsServicesProtocol> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return VersionsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var appInfoService: Factory<AppInfoService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return AppInfoService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var appStoreReviewService: Factory<any AppStoreReviewServicesProtocol> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return AppStoreReviewService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var appCategoryService: Factory<AppCategoryService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return AppCategoryService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var reviewSubmissionsService: Factory<any ReviewSubmissionsServicesProtocol> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return ReviewSubmissionsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var appScreenshotsService: Factory<AppScreenshotsService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return AppScreenshotsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }
}
#endif
