//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

#if canImport(Darwin)
import FactoryKit
import OversizeAppStoreServices

public extension Container {
    var analyticsService: Factory<AnalyticsService> {
        self { AnalyticsService(authenticator: EnvAuthenticator()) }
    }

    var salesAndFinanceService: Factory<SalesAndFinanceService> {
        self { SalesAndFinanceService(authenticator: EnvAuthenticator()) }
    }

    var perfPowerMetricsService: Factory<PerfPowerMetricsService> {
        self { PerfPowerMetricsService(authenticator: EnvAuthenticator()) }
    }
}
#endif
