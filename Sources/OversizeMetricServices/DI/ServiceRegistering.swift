//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

#if canImport(Darwin)
import FactoryKit
import OversizeAppStoreServices

public extension Container {
    var analyticsService: Factory<AnalyticsService> {
        ascService { AnalyticsService(authenticator: $0, cacheAccountID: $1) }
    }

    var salesAndFinanceService: Factory<SalesAndFinanceService> {
        ascService { SalesAndFinanceService(authenticator: $0, cacheAccountID: $1) }
    }

    var perfPowerMetricsService: Factory<PerfPowerMetricsService> {
        ascService { PerfPowerMetricsService(authenticator: $0, cacheAccountID: $1) }
    }
}
#endif
