//
// Copyright © 2024 Alexander Romanov
// PerfPowerMetricsService.swift, created on 16.12.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeAppStoreServices

public actor PerfPowerMetricsService {
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
    }

    public func fetchXcodeMetrics(appId: String) async -> Result<LocalXcodeMetrics, Error> {
        let request = Resources.v1.apps.id(appId).perfPowerMetrics.get()
        do {
            let data = try await client.send(request)
            print(data)
            let localXcodeMetrics: LocalXcodeMetrics = .init(dto: data)
            return .success(localXcodeMetrics)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchBuildMetrics(buildId: String) async -> Result<LocalXcodeMetrics, Error> {
        let request = Resources.v1.builds.id(buildId).perfPowerMetrics.get()
        do {
            let data = try await client.send(request)
            let localXcodeMetrics: LocalXcodeMetrics = .init(dto: data)
            return .success(localXcodeMetrics)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
