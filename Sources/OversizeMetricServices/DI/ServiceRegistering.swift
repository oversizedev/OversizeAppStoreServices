//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

#if canImport(Darwin)
import FactoryKit
import OversizeAppStoreServices

public extension Container {
    var analyticsService: Factory<AnalyticsService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return AnalyticsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var salesAndFinanceService: Factory<SalesAndFinanceService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return SalesAndFinanceService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }

    var perfPowerMetricsService: Factory<PerfPowerMetricsService> {
        self {
            let context = ASCServiceContext(configuration: self.appStoreConfiguration())
            return PerfPowerMetricsService(authenticator: context.authenticator, cacheAccountID: context.cacheAccountID)
        }
    }
}
#endif
