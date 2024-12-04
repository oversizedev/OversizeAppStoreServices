//
// Copyright © 2024 Alexander Romanov
// InstallReport.swift, created on 28.11.2024
//

import Foundation

public struct InstallReport: Decodable, Sendable, Hashable {
    public let developer: String?
    public let appID: String?
    public let appName: String?
    public let installsAboveThreshold: Int?
    public let firstAnnualInstalls: Int?

    enum CodingKeys: String, CodingKey {
        case developer = "Developer"
        case appID = "App ID"
        case appName = "App Name"
        case installsAboveThreshold = "Installs Above Threshold"
        case firstAnnualInstalls = "First Annual Installs"
    }
}

public struct SalesSummaryReport: Decodable, Sendable, Hashable {
    public let provider: String
    public let providerCountry: String
    public let sku: String
    public let developer: String
    public let title: String
    public let version: String
    public let productTypeIdentifier: String
    public let units: Int
    public let developerProceeds: Double
    public let beginDate: String
    public let endDate: String
    public let customerCurrency: String
    public let countryCode: String
    public let currencyOfProceeds: String
    public let appleIdentifier: String
    public let customerPrice: Double
    public let promoCode: String?
    public let parentIdentifier: String?
    public let subscription: String?
    public let period: String?
    public let category: String
    public let cmb: String?
    public let device: String
    public let supportedPlatforms: String
    public let proceedsReason: String?
    public let preservedPricing: String?
    public let client: String?
    public let orderType: String?

    enum CodingKeys: String, CodingKey {
        case provider = "Provider"
        case providerCountry = "Provider Country"
        case sku = "SKU"
        case developer = "Developer"
        case title = "Title"
        case version = "Version"
        case productTypeIdentifier = "Product Type Identifier"
        case units = "Units"
        case developerProceeds = "Developer Proceeds"
        case beginDate = "Begin Date"
        case endDate = "End Date"
        case customerCurrency = "Customer Currency"
        case countryCode = "Country Code"
        case currencyOfProceeds = "Currency of Proceeds"
        case appleIdentifier = "Apple Identifier"
        case customerPrice = "Customer Price"
        case promoCode = "Promo Code"
        case parentIdentifier = "Parent Identifier"
        case subscription = "Subscription"
        case period = "Period"
        case category = "Category"
        case cmb = "CMB"
        case device = "Device"
        case supportedPlatforms = "Supported Platforms"
        case proceedsReason = "Proceeds Reason"
        case preservedPricing = "Preserved Pricing"
        case client = "Client"
        case orderType = "Order Type"
    }
}
