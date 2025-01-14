//
// Copyright © 2024 Alexander Romanov
// InAppPurchasesService.swift, created on 22.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Factory
import Foundation
import OversizeModels

public actor InAppPurchasesService {
    private let client: AppStoreConnectClient?
    @Injected(\.cacheService) private var cacheService: CacheService

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppInAppPurchases(appId: String, force: Bool = false) async -> Result<[InAppPurchaseV2], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppInAppPurchases\(appId)", force: force) {
            let request = Resources.v1.apps.id(appId).inAppPurchasesV2.get(include: [.images])
            return try await client.send(request).data

        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }
}
