//
// Copyright © 2025 Aleksandr Romanov
// SubscribtionsService.swift, created on 12.01.2025
//

import AppStoreAPI
import AppStoreConnect
import Factory
import Foundation
import OversizeModels

public actor SubscribtionsService {
    private let client: AppStoreConnectClient?
    @Injected(\.cacheService) private var cacheService: CacheService

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppSubscriptionGroups(appId: String, force: Bool = false) async -> Result<[SubscriptionGroup], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppSubscriptionGroups\(appId)", force: force) {
            let request = Resources.v1.apps.id(appId).subscriptionGroups.get()
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchAppSubscriptionGroupsIncludedSubscriptionsAndLocalizations(appId: String, force: Bool = false) async -> Result<[SubscriptionGroup], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppSubscriptionGroupsIncludedSubscriptionsAndLocalizations\(appId)", force: force) {
            let request = Resources.v1.apps.id(appId).subscriptionGroups.get(
                include: [
                    .subscriptions,
                    .subscriptionGroupLocalizations,
                ]
            )
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }
}
