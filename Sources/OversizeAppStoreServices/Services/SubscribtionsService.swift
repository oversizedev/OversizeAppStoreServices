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

    public func fetchSubscription(subscriptionId: String, force: Bool = false) async -> Result<Subscription, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscription\(subscriptionId)", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).get()
            return try await client.send(request)
        }.flatMap {
            guard let build: Subscription = .init(schema: $0.data) else {
                return .failure(.network(type: .decode))
            }
            return .success(build)
        }
    }

    public func fetchSubscriptionIncludedAll(subscriptionId: String, force: Bool = false) async -> Result<Subscription, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscriptionIncludedAll\(subscriptionId)", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).get(
                include: [
                    .subscriptionLocalizations,
                    .appStoreReviewScreenshot,
                    .group,
                    .introductoryOffers,
                    .promotionalOffers,
                    .offerCodes,
                    .prices,
                    .promotedPurchase,
                    .winBackOffers,
                    .images,
                ]
            )
            return try await client.send(request)
        }.flatMap {
            guard let build: Subscription = .init(schema: $0.data) else {
                return .failure(.network(type: .decode))
            }
            return .success(build)
        }
    }

    public func postSubscriptionGroup(appId: String, referenceName: String) async -> Result<SubscriptionGroup, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let requestData: SubscriptionGroupCreateRequest.Data = .init(
            type: .subscriptionGroups,
            attributes: .init(referenceName: referenceName),
            relationships: .init(
                app: .init(
                    data: .init(
                        type: .apps,
                        id: appId
                    )
                )
            )
        )
        let request = Resources.v1.subscriptionGroups.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let app = SubscriptionGroup(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func postSubscription(
        subscriptionGroupId: String,
        name: String,
        productID: String,
        isFamilySharable: Bool? = nil,
        subscriptionPeriod: SubscriptionPeriod? = nil,
        reviewNote: String? = nil,
        groupLevel: Int? = nil
    ) async -> Result<Subscription, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        var subscriptionPeriodRequest: SubscriptionCreateRequest.Data.Attributes.SubscriptionPeriod? {
            if let subscriptionPeriod {
                .init(rawValue: subscriptionPeriod.rawValue)
            } else {
                nil
            }
        }

        let requestAttributes: SubscriptionCreateRequest.Data.Attributes = .init(
            name: name,
            productID: productID,
            isFamilySharable: isFamilySharable,
            subscriptionPeriod: subscriptionPeriodRequest,
            reviewNote: reviewNote,
            groupLevel: groupLevel
        )

        let requestData: SubscriptionCreateRequest.Data = .init(
            type: .subscriptions,
            attributes: requestAttributes,
            relationships: .init(
                group: .init(
                    data: .init(
                        type: .subscriptionGroups,
                        id: subscriptionGroupId
                    )
                )
            )
        )
        let request = Resources.v1.subscriptions.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let app = Subscription(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func patchSubscription(
        subscriptionsId: String,
        name: String,
        productID _: String,
        isFamilySharable: Bool? = nil,
        subscriptionPeriod: SubscriptionPeriod? = nil,
        reviewNote: String? = nil,
        groupLevel: Int? = nil
    ) async -> Result<Subscription, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        var subscriptionPeriodRequest: SubscriptionUpdateRequest.Data.Attributes.SubscriptionPeriod? {
            if let subscriptionPeriod {
                .init(rawValue: subscriptionPeriod.rawValue)
            } else {
                nil
            }
        }

        let requestAttributes: SubscriptionUpdateRequest.Data.Attributes = .init(
            name: name,
            isFamilySharable: isFamilySharable,
            subscriptionPeriod: subscriptionPeriodRequest,
            reviewNote: reviewNote,
            groupLevel: groupLevel
        )

        let requestData: SubscriptionUpdateRequest.Data = .init(
            type: .subscriptions,
            id: subscriptionsId,
            attributes: requestAttributes
        )

        let request = Resources.v1.subscriptions.id(subscriptionsId).patch(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let app = Subscription(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }
}

extension SubscribtionsService {
    func handleRequestFailure<T>(error: Error, replaces: [String: String] = [:]) -> Result<T, AppError> {
        if let responseError = error as? ResponseError {
            switch responseError {
            case let .requestFailure(errorResponse, _, _):
                if let errors = errorResponse?.errors, let firstError = errors.first {
                    var title = firstError.title
                    var detail = firstError.detail

                    for (placeholder, replacement) in replaces {
                        title = title.replacingOccurrences(of: placeholder, with: replacement)
                        detail = detail.replacingOccurrences(of: placeholder, with: replacement)
                    }

                    return .failure(AppError.network(type: .apiError(title, detail)))
                }
                return .failure(AppError.network(type: .unknown))
            default:
                return .failure(AppError.network(type: .unknown))
            }
        }
        return .failure(AppError.network(type: .unknown))
    }
}
