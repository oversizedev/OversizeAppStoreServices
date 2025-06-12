//
// Copyright © 2024 Alexander Romanov
// AnalyticsService.swift, created on 25.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeAppStoreServices
import OversizeCore
import OversizeModels

public actor AnalyticsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppAnalyticsReportRequests(appId: String) async -> Result<[AnalyticsReportRequest], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).analyticsReportRequests.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppAnalyticsReportRequestsIncludeReports(appId: String) async -> Result<[AnalyticsReportRequest], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).analyticsReportRequests.get(
            include: [.reports],
        )
        do {
            let result = try await client.send(request)
            return .success(result.data.compactMap { .init(schema: $0, included: result.included) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAnalyticsReportRequestReport(analyticsReportRequestsId: String) async -> Result<[AnalyticsReport], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.analyticsReportRequests.id(analyticsReportRequestsId).reports.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAnalyticsReport(analyticsReportId: String) async -> Result<AnalyticsReport, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.analyticsReports.id(analyticsReportId).get()
        do {
            let data = try await client.send(request).data
            guard let analyticsReport: AnalyticsReport = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(analyticsReport)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    /*
     public func fetchAnalyticsReportInstances(analyticsReportId: String) async -> Result<AnalyticsReport, AppError> {
         guard let client else { return .failure(.network(type: .unauthorized)) }
         let request = Resources.v1.analyticsReports.id(
             analyticsReportId
         ).instances.get()
         do {
             let data = try await client.send(request).data
             guard let analyticsReport: AnalyticsReport = .init(schema: data) else {
                 return .failure(.network(type: .decode))
              }
             return .success(analyticsReport)
         } catch {
             return .failure(.network(type: .noResponse))
         }
     }
     */

    public func postAppAnalyticsReportRequests(appId: String) async -> Result<AnalyticsReportRequest, AppError> {
        guard let client else {
            return .failure(.network(type: .unauthorized))
        }

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
                return .failure(.network(type: .decode))
            }
            return .success(analyticsReportRequest)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
