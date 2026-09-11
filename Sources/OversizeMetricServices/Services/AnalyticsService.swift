//
// Copyright © 2024 Alexander Romanov
// AnalyticsService.swift, created on 25.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Gzip
import OversizeAppStoreServices
import OversizeCore

public actor AnalyticsService {
    private let client: AppStoreConnectClient
    private let territoryDownloadsCache: ASCValueCache
    private static let maxConcurrentDownloads = 4

    public init(authenticator: some AppStoreConnect.Authenticator, cacheAccountID: String? = nil) {
        let resolvedAccountID = ASCClientFactory.resolveCacheAccountID(for: authenticator, explicit: cacheAccountID)
        client = ASCClientFactory.makeClient(authenticator: authenticator, cacheAccountID: resolvedAccountID)
        territoryDownloadsCache = ASCValueCache(
            namespace: "territory-downloads",
            ttl: ASCCache.TTL.week,
            accountID: resolvedAccountID,
        )
    }

    // MARK: - Report Requests

    public func fetchAppAnalyticsReportRequests(appId: String) async -> Result<[AnalyticsReportRequest], Error> {
        let request = Resources.v1.apps.id(appId).analyticsReportRequests.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            Log.error("Fetch analytics report requests failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func fetchAppAnalyticsReportRequestsIncludeReports(appId: String) async -> Result<[AnalyticsReportRequest], Error> {
        let request = Resources.v1.apps.id(appId).analyticsReportRequests.get(
            include: [.reports],
        )
        do {
            let result = try await client.send(request)
            return .success(result.data.compactMap { .init(schema: $0, included: result.included) })
        } catch {
            Log.error("Fetch analytics report requests with reports failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func postAppAnalyticsReportRequests(appId: String) async -> Result<AnalyticsReportRequest, Error> {
        let requestData: AnalyticsReportRequestCreateRequest.Data = .init(
            type: .analyticsReportRequests,
            attributes: .init(accessType: .ongoing),
            relationships: .init(app: .init(data: .init(type: .apps, id: appId))),
        )
        let request = Resources.v1.analyticsReportRequests.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let analyticsReportRequest: AnalyticsReportRequest = .init(schema: data) else {
                return .failure(NetworkError.decode)
            }
            Log.info("Created ONGOING analytics report request: \(analyticsReportRequest.id)")
            return .success(analyticsReportRequest)
        } catch {
            Log.error("Create analytics report request failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func ensureOngoingReportRequest(appId: String) async -> Result<AnalyticsReportRequest, Error> {
        let requestsResult = await fetchAppAnalyticsReportRequests(appId: appId)
        switch requestsResult {
        case let .failure(error):
            return .failure(error)
        case let .success(requests):
            if let ongoing = requests.first(where: { $0.accessType == .ongoing && $0.isStoppedDueToInactivity != true }) {
                return .success(ongoing)
            }
            Log.debug("No active ONGOING report request, creating new one")
            return await postAppAnalyticsReportRequests(appId: appId)
        }
    }

    // MARK: - Reports

    public func fetchReports(
        requestId: String,
        category: AnalyticsReport.Category? = nil,
        name: String? = nil,
    ) async -> Result<[AnalyticsReport], Error> {
        let filterCategory = category.flatMap {
            Resources.V1.AnalyticsReportRequests.WithID.Reports.FilterCategory(rawValue: $0.rawValue)
        }
        let request = Resources.v1.analyticsReportRequests.id(requestId).reports.get(
            filterName: name.map { [$0] },
            filterCategory: filterCategory.map { [$0] },
            limit: 200,
        )
        do {
            let response = try await client.send(request)
            var allReports = response.data
            var nextURL: URL? = response.links.next
            while let next = nextURL {
                let pageRequest = Request<AppStoreAPI.AnalyticsReportsResponse>.get(next)
                let pageResponse = try await client.send(pageRequest)
                allReports.append(contentsOf: pageResponse.data)
                nextURL = pageResponse.links.next
            }
            return .success(allReports.compactMap { AnalyticsReport(schema: $0) })
        } catch {
            Log.error("Fetch analytics reports failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    public func fetchAnalyticsReportRequestReport(analyticsReportRequestsId: String) async -> Result<[AnalyticsReport], Error> {
        await fetchReports(requestId: analyticsReportRequestsId)
    }

    public func fetchAnalyticsReport(analyticsReportId: String) async -> Result<AnalyticsReport, Error> {
        let request = Resources.v1.analyticsReports.id(analyticsReportId).get()
        do {
            let data = try await client.send(request).data
            guard let analyticsReport: AnalyticsReport = .init(schema: data) else {
                return .failure(NetworkError.decode)
            }
            return .success(analyticsReport)
        } catch {
            Log.error("Fetch analytics report failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    // MARK: - Instances

    public func fetchReportInstances(
        reportId: String,
        granularity: AnalyticsReportInstance.Granularity? = .daily,
        processingDates: [String]? = nil,
    ) async -> Result<[AnalyticsReportInstance], Error> {
        let filterGranularity = granularity.flatMap {
            Resources.V1.AnalyticsReports.WithID.Instances.FilterGranularity(rawValue: $0.rawValue)
        }
        let request = Resources.v1.analyticsReports.id(reportId).instances.get(
            filterGranularity: filterGranularity.map { [$0] },
            filterProcessingDate: processingDates,
            limit: 200,
        )
        do {
            let response = try await client.send(request)
            var allInstances = response.data
            var nextURL: URL? = response.links.next
            while let next = nextURL {
                let pageRequest = Request<AppStoreAPI.AnalyticsReportInstancesResponse>.get(next)
                let pageResponse = try await client.send(pageRequest)
                allInstances.append(contentsOf: pageResponse.data)
                nextURL = pageResponse.links.next
            }
            return .success(allInstances.compactMap { AnalyticsReportInstance(schema: $0) })
        } catch {
            Log.error("Fetch report instances failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    // MARK: - Report Data

    public func fetchReportData(instance: AnalyticsReportInstance) async -> Result<AnalyticsReportData, Error> {
        do {
            return try await .success(downloadReportData(instance: instance))
        } catch {
            Log.error("Fetch report data failed for instance \(instance.id)", error: error)
            return .failure(error.asNetworkError)
        }
    }

    private func downloadReportData(instance: AnalyticsReportInstance) async throws -> AnalyticsReportData {
        let segmentURLs = try await fetchSegmentURLs(instanceId: instance.id)
        let emptyData = AnalyticsReportData(headers: [], rows: [], processingDate: instance.processingDate)
        guard !segmentURLs.isEmpty else { return emptyData }

        let processingDate = instance.processingDate
        let tables = try await withThrowingTaskGroup(of: AnalyticsReportData?.self) { group in
            var results: [AnalyticsReportData] = []
            var nextIndex = 0
            while nextIndex < segmentURLs.count, nextIndex < Self.maxConcurrentDownloads {
                let url = segmentURLs[nextIndex]
                group.addTask { try await Self.downloadTable(segmentURL: url, processingDate: processingDate) }
                nextIndex += 1
            }
            while let table = try await group.next() {
                if let table {
                    results.append(table)
                }
                if nextIndex < segmentURLs.count {
                    let url = segmentURLs[nextIndex]
                    group.addTask { try await Self.downloadTable(segmentURL: url, processingDate: processingDate) }
                    nextIndex += 1
                }
            }
            return results
        }

        guard var merged = tables.first else { return emptyData }
        for table in tables.dropFirst() {
            merged = merged.merged(with: table)
        }
        Log.info("Loaded report data for instance \(instance.id): \(merged.rows.count) rows")
        return merged
    }

    private func fetchSegmentURLs(instanceId: String) async throws -> [URL] {
        let request = Resources.v1.analyticsReportInstances.id(instanceId).segments.get(limit: 200)
        let response = try await client.send(request)
        var allSegments = response.data
        var nextURL: URL? = response.links.next
        while let next = nextURL {
            let pageRequest = Request<AppStoreAPI.AnalyticsReportSegmentsResponse>.get(next)
            let pageResponse = try await client.send(pageRequest)
            allSegments.append(contentsOf: pageResponse.data)
            nextURL = pageResponse.links.next
        }
        return allSegments.compactMap { $0.attributes?.url }
    }

    private static func downloadTable(segmentURL: URL, processingDate: String) async throws -> AnalyticsReportData? {
        let (data, response) = try await URLSession.shared.data(from: segmentURL)
        if let http = response as? HTTPURLResponse, !(200 ..< 300).contains(http.statusCode) {
            throw NetworkError.unexpectedStatusCode
        }
        let decompressed: Data = data.isGzipped ? try data.gunzipped() : data
        return AnalyticsTabularParser.parse(data: decompressed, processingDate: processingDate)
    }

    // MARK: - Dashboard Metrics

    public func fetchDailyMetricSeries(
        appId: String,
        metric: DashboardMetric,
        days: Int = 30,
    ) async -> Result<[AnalyticsMetricPoint], Error> {
        let requestResult = await ensureOngoingReportRequest(appId: appId)
        guard case let .success(reportRequest) = requestResult else {
            return .failure(requestResult.failureError ?? NetworkError.noResponse)
        }

        let reportsResult = await fetchReports(requestId: reportRequest.id, category: metric.category)
        guard case let .success(reports) = reportsResult else {
            return .failure(reportsResult.failureError ?? NetworkError.noResponse)
        }
        guard let report = reports.pickReport(matching: metric.reportNameCandidates) else {
            Log.warning("No report matched \(metric.reportNameCandidates) in category \(metric.category)")
            return .success([])
        }

        let instancesResult = await fetchReportInstances(reportId: report.id, granularity: .daily)
        guard case let .success(allInstances) = instancesResult else {
            return .failure(instancesResult.failureError ?? NetworkError.noResponse)
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let cutoff = AnalyticsReportInstance.dateFormatter.string(from: cutoffDate)
        let instances = allInstances
            .filter { $0.processingDate >= cutoff }
            .sorted { $0.processingDate < $1.processingDate }
        guard !instances.isEmpty else { return .success([]) }

        do {
            let tables = try await fetchTables(instances: instances)
            let points = Self.aggregate(tables: tables, metric: metric, cutoff: cutoff)
            return .success(points)
        } catch {
            Log.error("Fetch metric series failed for \(metric.rawValue)", error: error)
            return .failure(error.asNetworkError)
        }
    }

    // MARK: - Territory Downloads

    public func fetchTerritoryDownloads(
        appId: String,
        days: Int = 30,
        force: Bool = false,
    ) async -> Result<[TerritoryDownloads], Error> {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let cutoff = AnalyticsReportInstance.dateFormatter.string(from: cutoffDate)
        let cacheKey = "\(appId):\(days):\(cutoff)"
        if !force, let cached = territoryDownloadsCache.load([TerritoryDownloads].self, key: cacheKey) {
            return .success(cached)
        }
        let metric = DashboardMetric.downloads
        let requestResult = await ensureOngoingReportRequest(appId: appId)
        guard case let .success(reportRequest) = requestResult else {
            return .failure(requestResult.failureError ?? NetworkError.noResponse)
        }
        let reportsResult = await fetchReports(requestId: reportRequest.id, category: metric.category)
        guard case let .success(reports) = reportsResult else {
            return .failure(reportsResult.failureError ?? NetworkError.noResponse)
        }
        guard let report = reports.pickReport(matching: metric.reportNameCandidates) else {
            Log.warning("No downloads report available for territory aggregation")
            return .success([])
        }
        let instancesResult = await fetchReportInstances(reportId: report.id, granularity: .daily)
        guard case let .success(allInstances) = instancesResult else {
            return .failure(instancesResult.failureError ?? NetworkError.noResponse)
        }
        let instances = allInstances
            .filter { $0.processingDate >= cutoff }
            .sorted { $0.processingDate < $1.processingDate }
        guard !instances.isEmpty else { return .success([]) }
        do {
            let tables = try await fetchTables(instances: instances)
            let territories = TerritoryAggregation.aggregate(
                tables: tables,
                valueColumnCandidates: metric.valueColumnCandidates,
                cutoff: cutoff,
            )
            territoryDownloadsCache.save(territories, key: cacheKey)
            Log.info("Territory downloads aggregated for \(appId): \(territories.count) territories")
            return .success(territories)
        } catch {
            Log.error("Fetch territory downloads failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    private func fetchTables(instances: [AnalyticsReportInstance]) async throws -> [AnalyticsReportData] {
        try await withThrowingTaskGroup(of: AnalyticsReportData.self) { group in
            var results: [AnalyticsReportData] = []
            var nextIndex = 0
            while nextIndex < instances.count, nextIndex < Self.maxConcurrentDownloads {
                let instance = instances[nextIndex]
                group.addTask { [self] in
                    try await fetchReportData(instance: instance).get()
                }
                nextIndex += 1
            }
            while let table = try await group.next() {
                results.append(table)
                if nextIndex < instances.count {
                    let instance = instances[nextIndex]
                    group.addTask { [self] in
                        try await fetchReportData(instance: instance).get()
                    }
                    nextIndex += 1
                }
            }
            return results
        }
    }

    private static func aggregate(
        tables: [AnalyticsReportData],
        metric: DashboardMetric,
        cutoff: String,
    ) -> [AnalyticsMetricPoint] {
        var totals: [String: Double] = [:]
        for table in tables {
            guard let valueIndex = table.columnIndex(matching: metric.valueColumnCandidates) else { continue }
            let dateIndex = table.dateColumnIndex
            let filterIndex = metric.rowFilter.flatMap { table.columnIndex(matching: $0.columnCandidates) }
            if let rowFilter = metric.rowFilter, filterIndex == nil {
                Log.warning("Filter column \(rowFilter.columnCandidates) not found for \(metric.rawValue), skipping table")
                continue
            }
            for row in table.rows {
                if let rowFilter = metric.rowFilter, let filterIndex {
                    let filterValue = table.value(row: row, columnIndex: filterIndex) ?? ""
                    guard rowFilter.allowedValues.contains(where: { $0.caseInsensitiveCompare(filterValue) == .orderedSame }) else {
                        continue
                    }
                }
                guard let value = table.numericValue(row: row, columnIndex: valueIndex) else { continue }
                let dateString = dateIndex.flatMap { table.value(row: row, columnIndex: $0) } ?? table.processingDate
                guard dateString >= cutoff else { continue }
                totals[dateString, default: 0] += value
            }
        }
        return totals
            .compactMap { dateString, value -> AnalyticsMetricPoint? in
                guard let date = AnalyticsReportInstance.dateFormatter.date(from: dateString) else { return nil }
                return AnalyticsMetricPoint(date: date, value: value)
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Search Terms

    public func fetchSearchTermMetrics(appId: String) async -> Result<[SearchTermMetric], Error> {
        let requestResult = await ensureOngoingReportRequest(appId: appId)
        guard case let .success(reportRequest) = requestResult else {
            return .failure(requestResult.failureError ?? NetworkError.noResponse)
        }

        let reportsResult = await fetchReports(requestId: reportRequest.id, category: .appStoreEngagement)
        guard case let .success(reports) = reportsResult else {
            return .failure(reportsResult.failureError ?? NetworkError.noResponse)
        }
        guard let searchReport = reports.pickSearchTermReport() else {
            Log.warning("No APP_STORE_ENGAGEMENT report found")
            return .success([])
        }

        let instancesResult = await fetchReportInstances(reportId: searchReport.id, granularity: .daily)
        switch instancesResult {
        case let .failure(error):
            return .failure(error)
        case let .success(instances) where instances.isEmpty:
            Log.debug("No report instances available yet — report data not ready")
            return .success([])
        case let .success(instances):
            guard let latestInstance = instances.max(by: { $0.processingDate < $1.processingDate }) else {
                return .success([])
            }
            let dataResult = await fetchReportData(instance: latestInstance)
            switch dataResult {
            case let .failure(error):
                return .failure(error)
            case let .success(table):
                let metrics = SearchTermParser.metrics(from: table)
                var accumulated: [String: SearchTermMetric] = [:]
                for metric in metrics {
                    if let existing = accumulated[metric.searchTerm] {
                        accumulated[metric.searchTerm] = SearchTermMetric(
                            searchTerm: metric.searchTerm,
                            impressions: existing.impressions + metric.impressions,
                            downloads: existing.downloads + metric.downloads,
                            processingDate: latestInstance.processingDate,
                        )
                    } else {
                        accumulated[metric.searchTerm] = metric
                    }
                }
                Log.info("Search term metrics loaded: \(accumulated.count) unique terms")
                return .success(Array(accumulated.values))
            }
        }
    }
}
