//
// Copyright © 2024 Alexander Romanov
// AnalyticsService_2.swift, created on 25.11.2024
//

import AppStoreAPI
import AppStoreConnect
import CodableCSV
import Foundation
import Gzip
import OversizeAppStoreServices
import OversizeCore

public actor SalesAndFinanceService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchSalesURL(vendorNumber: String) async -> Result<URL, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }
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
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchMonthlyInstalls(vendorNumber: String, reportDate: String) async -> Result<[InstallReport], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        let request = Resources.v1.salesReports.get(
            filterVendorNumber: [vendorNumber],
            filterReportType: [.installs],
            filterReportSubType: [.summary],
            filterFrequency: [.monthly],
            filterReportDate: [reportDate], // Format "2024-11"
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
            logError("FetchSalesReports", error: error)
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchSales(vendorNumber: String) async -> Result<[SalesSummaryReport], Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

        let request = Resources.v1.salesReports.get(
            filterVendorNumber: [vendorNumber],
            filterReportType: [.sales],
            filterReportSubType: [.summary],
            filterFrequency: [.daily],
            filterReportDate: ["2024-10-10"],
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
            logError("FetchSalesReports", error: error)
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchFinanceReportsURL(vendorNumbers: [String], regionCodes: [String], reportDates: [String]) async -> Result<URL, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }
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
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchFinanceReports(vendorNumbers: [String], regionCodes: [String], reportDates: [String]) async -> Result<FinanceReports, Error> {
        guard let client else { return .failure(NetworkError.unauthorized) }

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
        } catch let error as NetworkError {
            logError("FetchFinanceReports", error: error)
            return .failure(error)
        } catch {
            logError("FetchFinanceReports", error: error)
            return .failure(NetworkError.noResponse)
        }
    }

    private func decompressGzip(data: Data) throws -> Data {
        guard data.isGzipped else {
            logError("Gzip decompression failed")
            throw NetworkError.decode
        }
        return try data.gunzipped()
    }
}
