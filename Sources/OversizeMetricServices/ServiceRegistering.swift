//
// Copyright © 2024 Alexander Romanov
// ServiceRegistering.swift, created on 13.07.2024
//

import Factory

public extension Container {
    var analyticsService: Factory<AnalyticsService> {
        self { AnalyticsService() }
    }

    var salesAndFinanceService: Factory<SalesAndFinanceService> {
        self { SalesAndFinanceService() }
    }

    var perfPowerMetricsService: Factory<PerfPowerMetricsService> {
        self { PerfPowerMetricsService() }
    }
}
