//
// Copyright © 2024 Alexander Romanov
// PerfPowerMetricsService.swift, created on 16.12.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeAppStoreServices
import OversizeModels

public actor PerfPowerMetricsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchXcodeMetrics(appId: String) async -> Result<LocalXcodeMetrics, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).perfPowerMetrics.get()
        do {
            let data = try await client.send(request)
            print(data)
            let localXcodeMetrics: LocalXcodeMetrics = .init(dto: data)

            return .success(localXcodeMetrics)

        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchBuildMetrics(buildId: String) async -> Result<LocalXcodeMetrics, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.builds.id(buildId).perfPowerMetrics.get()

        do {
            let data = try await client.send(request)
            let localXcodeMetrics: LocalXcodeMetrics = .init(dto: data)
            return .success(localXcodeMetrics)

        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
