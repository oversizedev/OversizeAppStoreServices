//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

#if canImport(Darwin)
import AppStoreConnect
import FactoryKit

public extension Container {
    var appStoreConfiguration: Factory<Result<ASCAccountConfiguration, Error>> {
        self { .failure(ASCAuthenticationError.missingCredentials) }.cached
    }

    func ascService<Service>(
        key: StaticString = #function,
        _ make: @escaping @Sendable (any Authenticator, String?) -> Service,
    ) -> Factory<Service> {
        self(key: key) {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return make(context.authenticator, context.cacheAccountID)
        }
    }

    var appsService: Factory<AppsServicesProtocol> {
        ascService { AppsService(authenticator: $0, cacheAccountID: $1) }
    }

    var inAppPurchasesService: Factory<InAppPurchasesService> {
        ascService { InAppPurchasesService(authenticator: $0, cacheAccountID: $1) }
    }

    var subscriptionsService: Factory<SubscriptionsService> {
        ascService { SubscriptionsService(authenticator: $0, cacheAccountID: $1) }
    }

    var certificateService: Factory<CertificateService> {
        ascService { CertificateService(authenticator: $0, cacheAccountID: $1) }
    }

    var customerReviewService: Factory<CustomerReviewService> {
        ascService { CustomerReviewService(authenticator: $0, cacheAccountID: $1) }
    }

    var usersService: Factory<UsersService> {
        ascService { UsersService(authenticator: $0, cacheAccountID: $1) }
    }

    var buildsService: Factory<BuildsService> {
        ascService { BuildsService(authenticator: $0, cacheAccountID: $1) }
    }

    var versionsService: Factory<any VersionsServicesProtocol> {
        ascService { VersionsService(authenticator: $0, cacheAccountID: $1) }
    }

    var appInfoService: Factory<AppInfoService> {
        ascService { AppInfoService(authenticator: $0, cacheAccountID: $1) }
    }

    var appStoreReviewService: Factory<any AppStoreReviewServicesProtocol> {
        ascService { AppStoreReviewService(authenticator: $0, cacheAccountID: $1) }
    }

    var appCategoryService: Factory<AppCategoryService> {
        ascService { AppCategoryService(authenticator: $0, cacheAccountID: $1) }
    }

    var reviewSubmissionsService: Factory<any ReviewSubmissionsServicesProtocol> {
        ascService { ReviewSubmissionsService(authenticator: $0, cacheAccountID: $1) }
    }

    var appScreenshotsService: Factory<AppScreenshotsService> {
        ascService { AppScreenshotsService(authenticator: $0, cacheAccountID: $1) }
    }

    var appAssetLibraryService: Factory<any AppAssetLibraryServicesProtocol> {
        ascService { AppAssetLibraryService(authenticator: $0, cacheAccountID: $1) }
    }

    var appStoreVersionExperimentsService: Factory<any AppStoreVersionExperimentsServicesProtocol> {
        ascService { AppStoreVersionExperimentsService(authenticator: $0, cacheAccountID: $1) }
    }
}
#endif
