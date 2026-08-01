//
// Copyright © 2024 Alexander Romanov
// SalesAndFinanceService.swift, created on 25.11.2024
//

import AppStoreAPI
import AppStoreConnect
import CodableCSV
import Foundation
import Gzip
import OversizeAppStoreServices
import OversizeCore

public actor SalesAndFinanceService {
    private let client: AppStoreConnectClient
    private let dailySalesCache: ASCValueCache
    private static let maxConcurrentDownloads = 4

    public init(authenticator: some AppStoreConnect.Authenticator, cacheAccountID: String? = nil) {
        let resolvedAccountID = ASCClientFactory.resolveCacheAccountID(for: authenticator, explicit: cacheAccountID)
        client = ASCClientFactory.makeClient(authenticator: authenticator, cacheAccountID: resolvedAccountID)
        dailySalesCache = ASCValueCache(
            namespace: "daily-sales",
            ttl: ASCCache.TTL.month,
            accountID: resolvedAccountID,
        )
    }

    public func fetchSalesURL(vendorNumber: String) async -> Result<URL, Error> {
        let request = Resources.v1.salesReports.get(
            filterVendorNumber: [vendorNumber],
            filterReportType: [
                .sales,
                .preOrder,
                .newsstand,
                .subscription,
                .subscriptionEvent,
                .subscriber,
                .subscriptionOfferCodeRedemption,
                .installs,
                .firstAnnual,
            ],
            filterReportSubType: [
                .summary,
                .detailed,
                .summaryInstallType,
                .summaryTerritory,
                .summaryChannel,
            ],
            filterFrequency: [.monthly],
        )
        do {
            let data = try await client.download(request)
            return .success(data)
        } catch {
            Log.error("Fetch sales URL failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func fetchMonthlyInstalls(vendorNumber: String, reportDate: String) async -> Result<[InstallReport], Error> {
        let request = Resources.v1.salesReports.get(
            filterVendorNumber: [vendorNumber],
            filterReportType: [.installs],
            filterReportSubType: [.summary],
            filterFrequency: [.monthly],
            filterReportDate: [reportDate],
        )
        do {
            let fileURL = try await client.download(request)
            let fileData = try Data(contentsOf: fileURL)
            let decompressedData = try decompressGzip(data: fileData)

            guard let csvString = String(data: decompressedData, encoding: .utf8) else {
                return .failure(NetworkError.decode)
            }

            let cleanedCSVString: String = {
                let lines = csvString.components(separatedBy: .newlines)
                return lines
                    .filter { line in
                        !line.starts(with: "Metric: First Annual Installs") &&
                            !line.starts(with: "Developer: Alexander Romanov") &&
                            !line.starts(with: "Region: European Union") &&
                            !line.starts(with: "Reporting Period:") &&
                            !line.starts(with: "Assumed Agreement Date:") &&
                            !line.starts(with: "Fees will not be charged against installs in this report.") &&
                            line != "The name of the developer.\tThe ID of the app that was installed.\tThe name of the app that was installed.\tThe number of first annual installs above one million.\tThe total number of first annual installs."
                    }
                    .dropFirst()
                    .joined(separator: "\n")
            }()

            guard let cleanedData = cleanedCSVString.data(using: .utf8) else {
                return .failure(NetworkError.decode)
            }

            let decoder = CSVDecoder {
                $0.headerStrategy = .firstLine
                $0.delimiters.field = "\t"
            }
            let reports = try decoder.decode([InstallReport].self, from: cleanedData)
            return .success(reports)
        } catch {
            Log.error("Fetch monthly installs failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func fetchDailySales(vendorNumber: String, reportDate: String) async -> Result<[SalesSummaryReport], Error> {
        let request = Resources.v1.salesReports.get(
            filterVendorNumber: [vendorNumber],
            filterReportType: [.sales],
            filterReportSubType: [.summary],
            filterFrequency: [.daily],
            filterReportDate: [reportDate],
            filterVersion: ["1_0"],
        )
        do {
            let fileURL = try await client.download(request)
            let fileData = try Data(contentsOf: fileURL)
            let decompressedData = try decompressGzip(data: fileData)
            let decoder = CSVDecoder {
                $0.headerStrategy = .firstLine
                $0.delimiters.field = "\t"
            }
            let reports = try decoder.decode([SalesSummaryReport].self, from: decompressedData)
            return .success(reports)
        } catch {
            Log.error("Fetch daily sales failed for \(reportDate)", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func fetchDailyProceedsSeries(
        vendorNumber: String,
        appAppleId: String? = nil,
        days: Int = 30,
        force: Bool = false,
    ) async -> Result<[AnalyticsMetricPoint], Error> {
        let dates = Self.recentReportDates(days: days)
        guard !dates.isEmpty else { return .success([]) }

        let outcomes = await withTaskGroup(of: DailyProceedsOutcome.self) { group in
            var results: [DailyProceedsOutcome] = []
            var nextIndex = 0
            while nextIndex < dates.count, nextIndex < Self.maxConcurrentDownloads {
                let date = dates[nextIndex]
                group.addTask { [self] in
                    await dailyProceeds(vendorNumber: vendorNumber, appAppleId: appAppleId, reportDate: date, force: force)
                }
                nextIndex += 1
            }
            while let outcome = await group.next() {
                results.append(outcome)
                if nextIndex < dates.count {
                    let date = dates[nextIndex]
                    group.addTask { [self] in
                        await dailyProceeds(vendorNumber: vendorNumber, appAppleId: appAppleId, reportDate: date, force: force)
                    }
                    nextIndex += 1
                }
            }
            return results
        }

        var dayTotals: [(date: Date, totals: [String: Double])] = []
        var firstFailure: Error?
        for outcome in outcomes {
            switch outcome {
            case let .day(date, totals):
                dayTotals.append((date, totals))
            case .missing:
                continue
            case let .failure(error):
                if firstFailure == nil {
                    firstFailure = error
                }
            }
        }
        if let firstFailure {
            return .failure(firstFailure)
        }

        var currencyVolumes: [String: Double] = [:]
        for day in dayTotals {
            for (currency, total) in day.totals {
                currencyVolumes[currency, default: 0] += abs(total)
            }
        }
        guard let dominantCurrency = currencyVolumes.max(by: { $0.value < $1.value })?.key else {
            return .success([])
        }

        let points = dayTotals
            .map { AnalyticsMetricPoint(date: $0.date, value: $0.totals[dominantCurrency] ?? 0) }
            .sorted { $0.date < $1.date }
        return .success(points)
    }

    private enum DailyProceedsOutcome {
        case day(Date, [String: Double])
        case missing
        case failure(Error)
    }

    private func dailyProceeds(
        vendorNumber: String,
        appAppleId: String?,
        reportDate: String,
        force: Bool,
    ) async -> DailyProceedsOutcome {
        guard let date = AnalyticsReportInstance.dateFormatter.date(from: reportDate) else { return .missing }
        let cacheKey = "daily-proceeds-by-currency-\(vendorNumber)-\(appAppleId ?? "all")-\(reportDate)"

        if !force, let cached = dailySalesCache.load([String: Double].self, key: cacheKey) {
            return .day(date, cached)
        }

        let salesResult = await fetchDailySales(vendorNumber: vendorNumber, reportDate: reportDate)
        switch salesResult {
        case let .success(reports):
            var totals: [String: Double] = [:]
            for report in reports {
                if let appAppleId, report.appleIdentifier != appAppleId {
                    continue
                }
                totals[report.currencyOfProceeds, default: 0] += report.developerProceeds * Double(report.units)
            }
            dailySalesCache.save(totals, key: cacheKey)
            return .day(date, totals)
        case let .failure(error):
            if Self.isMissingReportError(error.asNetworkError) {
                return .missing
            }
            return .failure(error)
        }
    }

    private static func isMissingReportError(_ error: NetworkError) -> Bool {
        guard case let .apiError(title, detail) = error else { return false }
        let text = "\(title) \(detail ?? "")".lowercased()
        return text.contains("no sales")
            || text.contains("none were found")
            || text.contains("no data")
            || text.contains("not available")
    }

    private static func recentReportDates(days: Int) -> [String] {
        let calendar = Calendar.current
        guard let latestDate = calendar.date(byAdding: .day, value: -1, to: Date()) else { return [] }
        return (0 ..< max(days, 0)).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: latestDate) else { return nil }
            return AnalyticsReportInstance.dateFormatter.string(from: date)
        }
    }

    public func fetchFinanceReportsURL(vendorNumbers: [String], regionCodes: [String], reportDates: [String]) async -> Result<URL, Error> {
        let request = Resources.v1.financeReports.get(
            filterVendorNumber: vendorNumbers,
            filterReportType: [.financial, .financeDetail],
            filterRegionCode: regionCodes,
            filterReportDate: reportDates,
        )
        do {
            let data = try await client.download(request)
            return .success(data)
        } catch {
            Log.error("Fetch finance reports URL failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func fetchFinanceReports(vendorNumbers: [String], regionCodes: [String], reportDates: [String]) async -> Result<FinanceReports, Error> {
        let request = Resources.v1.financeReports.get(
            filterVendorNumber: vendorNumbers,
            filterReportType: [.financial, .financeDetail],
            filterRegionCode: regionCodes,
            filterReportDate: reportDates,
        )

        do {
            let fileURL = try await client.download(request)
            let fileData = try Data(contentsOf: fileURL)
            let decompressedData = try decompressGzip(data: fileData)
            let reports = FinanceReports(data: decompressedData)
            guard let reports else { return .failure(NetworkError.decode) }
            return .success(reports)
        } catch {
            Log.error("Fetch finance reports failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    private func decompressGzip(data: Data) throws -> Data {
        guard data.isGzipped else {
            throw NetworkError.decode
        }
        return try data.gunzipped()
    }
}
