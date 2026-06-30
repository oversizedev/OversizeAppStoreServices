//
// Copyright © 2024 Alexander Romanov
// AnalyticsService.swift, created on 25.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import Gzip
import OversizeAppStoreServices

public actor AnalyticsService {
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
    }

    public func fetchAppAnalyticsReportRequests(appId: String) async -> Result<[AnalyticsReportRequest], Error> {

        let request = Resources.v1.apps.id(appId).analyticsReportRequests.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(NetworkError.noResponse)
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
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchAnalyticsReportRequestReport(analyticsReportRequestsId: String) async -> Result<[AnalyticsReport], Error> {

        let request = Resources.v1.analyticsReportRequests.id(analyticsReportRequestsId).reports.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(NetworkError.noResponse)
        }
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
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchAnalyticsReportInstances(reportId: String) async -> Result<[AppStoreAPI.AnalyticsReportInstance], Error> {

        print("Fetching report instances for reportId: \(reportId)")
        let request = Resources.v1.analyticsReports.id(reportId).instances.get(
            filterGranularity: [.daily],
            limit: 200,
        )
        do {
            let response = try await client.send(request)
            var allInstances = response.data
            var nextURL: URL? = response.links.next
            while let next = nextURL {
                print("Fetching next page of report instances")
                let pageRequest = Request<AppStoreAPI.AnalyticsReportInstancesResponse>.get(next)
                let pageResponse = try await client.send(pageRequest)
                allInstances.append(contentsOf: pageResponse.data)
                nextURL = pageResponse.links.next
            }
            print("Fetched \(allInstances.count) report instances")
            return .success(allInstances)
        } catch {
            print("Failed to fetch report instances: \(error)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchAnalyticsReportSegments(instanceId: String) async -> Result<[AppStoreAPI.AnalyticsReportSegment], Error> {

        print("Fetching segments for instanceId: \(instanceId)")
        let request = Resources.v1.analyticsReportInstances.id(instanceId).segments.get(limit: 200)
        do {
            let response = try await client.send(request)
            var allSegments = response.data
            var nextURL: URL? = response.links.next
            while let next = nextURL {
                print("Fetching next page of segments")
                let pageRequest = Request<AppStoreAPI.AnalyticsReportSegmentsResponse>.get(next)
                let pageResponse = try await client.send(pageRequest)
                allSegments.append(contentsOf: pageResponse.data)
                nextURL = pageResponse.links.next
            }
            print("Fetched \(allSegments.count) segments")
            return .success(allSegments)
        } catch {
            print("Failed to fetch segments: \(error)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchSearchTermMetrics(appId: String) async -> Result<[SearchTermMetric], Error> {
        print("Fetching search term metrics for appId: \(appId)")

        let requestsResult = await fetchAppAnalyticsReportRequestsIncludeReports(appId: appId)
        guard case let .success(reportRequests) = requestsResult else {
            print("Failed to fetch analytics report requests")
            return .failure(NetworkError.noResponse)
        }

        let ongoingRequest = reportRequests.first { $0.accessType == .ongoing && $0.isStoppedDueToInactivity != true }

        let analyticsReportRequest: AnalyticsReportRequest
        if let existing = ongoingRequest {
            print("Using existing ONGOING report request: \(existing.id)")
            analyticsReportRequest = existing
        } else {
            print("No ONGOING report request found, creating new one")
            let createResult = await postAppAnalyticsReportRequests(appId: appId)
            guard case let .success(created) = createResult else {
                print("Failed to create analytics report request")
                return .failure(NetworkError.noResponse)
            }
            print("Created new report request: \(created.id). Data will be available next day.")
            analyticsReportRequest = created
        }

        let reportsResult = await fetchAnalyticsReportRequestReport(analyticsReportRequestsId: analyticsReportRequest.id)
        guard case let .success(reports) = reportsResult else {
            print("Failed to fetch reports for request: \(analyticsReportRequest.id)")
            return .failure(NetworkError.noResponse)
        }
        print("Found \(reports.count) reports, filtering for APP_STORE_ENGAGEMENT")

        let engagementReports = reports.filter { $0.category == .appStoreEngagement }
        print("Available engagement reports: \(engagementReports.map(\.name).joined(separator: ", "))")
        guard let searchReport = engagementReports.pickSearchTermReport() else {
            print("No APP_STORE_ENGAGEMENT report found")
            return .success([])
        }
        print("Using report: \"\(searchReport.name)\" (id: \(searchReport.id))")

        let instancesResult = await fetchAnalyticsReportInstances(reportId: searchReport.id)
        switch instancesResult {
        case let .failure(error):
            print("Failed to fetch instances: \(error)")
            return .failure(error)
        case let .success(instances) where instances.isEmpty:
            print("No report instances available yet — report data not ready")
            return .success([])
        case let .success(instances):
            let latestInstance = instances
                .compactMap { inst -> (AppStoreAPI.AnalyticsReportInstance, String)? in
                    guard let date = inst.attributes?.processingDate else { return nil }
                    return (inst, date)
                }
                .max(by: { $0.1 < $1.1 })
                .map(\.0) ?? instances[0]
            print("Selected latest instance: \(latestInstance.id), date: \(latestInstance.attributes?.processingDate ?? "unknown")")

            let segmentsResult = await fetchAnalyticsReportSegments(instanceId: latestInstance.id)
            switch segmentsResult {
            case let .failure(error):
                print("Failed to fetch segments: \(error)")
                return .failure(error)
            case let .success(segments) where segments.isEmpty:
                print("No segments available for instance \(latestInstance.id)")
                return .success([])
            case let .success(segments):
                let processingDate = latestInstance.attributes?.processingDate ?? ""
                print("Downloading \(segments.count) segment(s) for date: \(processingDate)")
                var accumulated: [String: SearchTermMetric] = [:]
                for (index, segment) in segments.enumerated() {
                    guard let segmentURL = segment.attributes?.url else {
                        print("Segment \(index) has no URL, skipping")
                        continue
                    }
                    print("Downloading segment \(index + 1)/\(segments.count) (\(segment.attributes?.sizeInBytes ?? 0) bytes)")
                    let result = await downloadAndParseSearchTerms(segmentURL: segmentURL, processingDate: processingDate)
                    switch result {
                    case let .success(metrics):
                        print("Parsed \(metrics.count) search terms from segment \(index + 1)")
                        for metric in metrics {
                            if let existing = accumulated[metric.searchTerm] {
                                accumulated[metric.searchTerm] = SearchTermMetric(
                                    searchTerm: metric.searchTerm,
                                    impressions: existing.impressions + metric.impressions,
                                    downloads: existing.downloads + metric.downloads,
                                    processingDate: processingDate,
                                )
                            } else {
                                accumulated[metric.searchTerm] = metric
                            }
                        }
                    case let .failure(error):
                        print("Failed to download/parse segment \(index + 1): \(error)")
                        return .failure(error)
                    }
                }
                print("Search term metrics loaded: \(accumulated.count) unique terms")
                return .success(Array(accumulated.values))
            }
        }
    }

    public func downloadAndParseSearchTerms(segmentURL: URL, processingDate: String) async -> Result<[SearchTermMetric], Error> {
        print("Downloading segment: \(segmentURL)")
        do {
            let (data, response) = try await URLSession.shared.data(from: segmentURL)
            if let http = response as? HTTPURLResponse, !(200 ..< 300).contains(http.statusCode) {
                print("Segment download failed with HTTP \(http.statusCode)")
                return .failure(NetworkError.noResponse)
            }
            let decompressed: Data
            if data.isGzipped {
                print("Decompressing gzip segment (\(data.count) bytes)")
                decompressed = try data.gunzipped()
            } else {
                decompressed = data
            }
            let metrics = SearchTermParser.parse(tsv: decompressed, processingDate: processingDate)
            print("Parsed \(metrics.count) search term rows from segment")
            return .success(metrics)
        } catch {
            print("Segment download/parse failed: \(error)")
            return .failure(NetworkError.decode)
        }
    }

    public func postAppAnalyticsReportRequests(appId: String) async -> Result<AnalyticsReportRequest, Error> {
        let requestAttributes: AnalyticsReportRequestCreateRequest.Data.Attributes = .init(
            accessType: .ongoing,
        )

        let requestRelationships: AnalyticsReportRequestCreateRequest.Data.Relationships = .init(
            app: .init(data: .init(
                type: .apps,
                id: appId,
            )),
        )

        let requestData: AnalyticsReportRequestCreateRequest.Data = .init(
            type: .analyticsReportRequests,
            attributes: requestAttributes,
            relationships: requestRelationships,
        )

        let request = Resources.v1.analyticsReportRequests.post(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let analyticsReportRequest: AnalyticsReportRequest = .init(schema: data) else {
                return .failure(NetworkError.decode)
            }
            return .success(analyticsReportRequest)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
