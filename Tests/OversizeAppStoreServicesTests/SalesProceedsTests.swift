//
// Copyright © 2026 Alexander Romanov
// SalesProceedsTests.swift, created on 22.10.2026
//

@testable import OversizeMetricServices
import Testing

struct SalesProceedsTests {
    @Test("App proceeds include its in-app purchases and subscriptions")
    func appProceedsIncludePurchases() {
        let reports = [
            report(sku: "app-sku", appleIdentifier: "100", parentIdentifier: nil, units: 3, proceeds: 0),
            report(sku: "pro-yearly", appleIdentifier: "200", parentIdentifier: "app-sku", units: 2, proceeds: 10),
            report(sku: "tips", appleIdentifier: "201", parentIdentifier: "app-sku", units: 1, proceeds: 1.5, currency: "EUR"),
            report(sku: "other-app", appleIdentifier: "300", parentIdentifier: nil, units: 1, proceeds: 4),
            report(sku: "other-pro", appleIdentifier: "400", parentIdentifier: "other-app", units: 1, proceeds: 7),
        ]

        #expect(SalesAndFinanceService.proceedsByCurrency(reports, appAppleId: "100") == ["USD": 20, "EUR": 1.5])
        #expect(SalesAndFinanceService.proceedsByCurrency(reports, appAppleId: nil) == ["USD": 31, "EUR": 1.5])
    }

    private func report(
        sku: String,
        appleIdentifier: String,
        parentIdentifier: String?,
        units: Int,
        proceeds: Double,
        currency: String = "USD",
    ) -> SalesSummaryReport {
        SalesSummaryReport(
            provider: "APPLE", providerCountry: "US", sku: sku, developer: "Developer", title: sku,
            version: "1.0", productTypeIdentifier: "1F", units: units, developerProceeds: proceeds,
            beginDate: "10/20/2026", endDate: "10/20/2026", customerCurrency: currency, countryCode: "US",
            currencyOfProceeds: currency, appleIdentifier: appleIdentifier, customerPrice: proceeds,
            promoCode: nil, parentIdentifier: parentIdentifier, subscription: nil, period: nil, category: "Utilities",
            cmb: nil, device: "iPhone", supportedPlatforms: "iOS", proceedsReason: nil, preservedPricing: nil,
            client: nil, orderType: nil,
        )
    }
}
