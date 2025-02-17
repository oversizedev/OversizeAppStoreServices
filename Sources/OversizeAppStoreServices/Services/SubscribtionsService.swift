//
// Copyright © 2025 Alexander Romanov
// subscriptionsService.swift, created on 12.01.2025
//

import AppStoreAPI
import AppStoreConnect
import Factory
import Foundation
import OversizeModels

public actor SubscriptionsService {
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
            guard let build: Subscription = .init(schema: $0.data, included: $0.included) else {
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

    public func fetchSubscriptionPricePointsEqualizations(
        subscriptionPricePointId: String,
        force: Bool = false
    ) async -> Result<[SubscriptionPricePoint], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscriptionPricePointsEqualizations\(subscriptionPricePointId)", force: force) {
            let request = Resources.v1.subscriptionPricePoints.id(subscriptionPricePointId).equalizations.get(limit: 200, include: [.territory])
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }

    public func fetchSubscriptionPricePoints(
        subscriptionId: String,
        filterTerritory: [Territory]? = nil,
        force: Bool = false
    ) async -> Result<[SubscriptionPricePoint], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        var filterTerritorIds: [String]? = nil
        if let filterTerritory {
            filterTerritorIds = filterTerritory.compactMap { $0.id }
        }

        return await cacheService.fetchWithCache(key: "fetchSubscriptionPricePoints\(subscriptionId)\(filterTerritorIds?.joined(separator: "-"))", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).pricePoints.get(filterTerritory: filterTerritorIds, limit: 2000, include: [.territory])
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }

    public func postSubscriptionAvailabilities(
        subscriptionId: String,
        isAvailableInNewTerritories: Bool,
        availableTerritories: [Territory]
    ) async -> Result<SubscriptionAvailability, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData = SubscriptionAvailabilityCreateRequest.Data(
            type: .subscriptionAvailabilities,
            attributes: .init(
                isAvailableInNewTerritories: isAvailableInNewTerritories
            ),
            relationships: .init(
                subscription: .init(data: .init(type: .subscriptions, id: subscriptionId)),
                availableTerritories: .init(
                    data: availableTerritories.compactMap { .init(
                        type: .territories,
                        id: $0.id
                    ) }
                )
            )
        )

        let request = Resources.v1.subscriptionAvailabilities.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let subscriptionAvailability = SubscriptionAvailability(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(subscriptionAvailability)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func fetchSubscriptionIntroductoryOffers(
        subscriptionId: String,
        filterTerritory: [Territory]? = nil,
        force: Bool = false
    ) async -> Result<[SubscriptionIntroductoryOffer], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        var filterTerritoryIds: [String]? = nil
        if let filterTerritory {
            filterTerritoryIds = filterTerritory.compactMap { $0.id }
        }

        return await cacheService.fetchWithCache(key: "fetchSubscriptionIntroductoryOffers\(subscriptionId)\(filterTerritoryIds?.joined(separator: "-"))", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).introductoryOffers.get(
                filterTerritory: filterTerritoryIds,
                limit: 200,
                include: [
                    .subscription,
                    .subscriptionPricePoint,
                    .territory,
                ]
            )

            return try await client.send(request)
        }.map { SubscriptionIntroductoryOffer.from(response: $0) }
    }

    public func fetchSubscriptionAvailability(
        subscriptionId: String,
        force: Bool = false
    ) async -> Result<SubscriptionAvailability, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscriptionAvailability\(subscriptionId)", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).subscriptionAvailability.get(
                limitAvailableTerritories: 50
            )
            return try await client.send(request)
        }.flatMap {
            guard let availability = SubscriptionAvailability(schema: $0.data, included: $0.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(availability)
        }
    }

    public func fetchSubscriptionPrices(
        subscriptionId: String,
        filterTerritory: [Territory]? = nil,
        force: Bool = false
    ) async -> Result<[SubscriptionPrice], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        var filterTerritoryIds: [String]? = nil
        if let filterTerritory {
            filterTerritoryIds = filterTerritory.compactMap { $0.id }
        }

        return await cacheService.fetchWithCache(key: "fetchSubscriptionPrices\(subscriptionId)\(filterTerritoryIds?.joined(separator: "-"))", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).prices.get(
                filterTerritory: filterTerritoryIds,
                limit: 200,
                include: [
                    .territory,
                    .subscriptionPricePoint,
                ]
            )
            return try await client.send(request)
        }.map { SubscriptionPrice.from(response: $0) }
    }

    public func patchSubscription(
        subscriptionsId: String,
        name: String? = nil,
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

    public func fetchSubscriptionAvailabilitiesAvailableTerritories(
        subscriptionAvailabilitiyId: String,
        force: Bool = false
    ) async -> Result<[Territory], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscriptionAvailabilitiesAvailableTerritories\(subscriptionAvailabilitiyId)", force: force) {
            let request = Resources.v1.subscriptionAvailabilities.id(subscriptionAvailabilitiyId).availableTerritories.get(limit: 200)
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchSubscriptionPromotionalOfferPrices(
        subscriptionPromotionalOfferId: String,
        force: Bool = false
    ) async -> Result<[SubscriptionPromotionalOfferPrice], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscriptionPromotionalOfferPrices\(subscriptionPromotionalOfferId)", force: force) {
            let request = Resources.v1.subscriptionPromotionalOffers.id(subscriptionPromotionalOfferId).prices.get()
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }

    public func createPromotionalOffer(
        subscriptionId: String,
        name: String,
        offerCode: String,
        duration: SubscriptionOfferDuration,
        offerMode: SubscriptionOfferMode,
        numberOfPeriods: Int,
        subscriptionPromotionalOfferPriceId: String
    ) async -> Result<SubscriptionPromotionalOffer, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        guard let duration: AppStoreAPI.SubscriptionOfferDuration = .init(rawValue: duration.rawValue),
              let offerMode: AppStoreAPI.SubscriptionOfferMode = .init(rawValue: offerMode.rawValue) else { return .failure(.network(type: .invalidURL)) }

        let requestData = SubscriptionPromotionalOfferCreateRequest.Data(
            type: .subscriptionPromotionalOffers,
            attributes: .init(
                name: name,
                offerCode: offerCode,
                duration: duration,
                offerMode: offerMode,
                numberOfPeriods: numberOfPeriods
            ),
            relationships: .init(
                subscription: .init(
                    data: .init(type: .subscriptions, id: subscriptionId)
                ), prices: .init(data: [.init(type: .subscriptionPromotionalOfferPrices, id: subscriptionPromotionalOfferPriceId)])
            )
        )

        let request = Resources.v1.subscriptionPromotionalOffers.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let offer = SubscriptionPromotionalOffer(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(offer)
        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func createSubscriptionLocalization(
        subscriptionId: String,
        name: String,
        description: String?,
        locale: AppStoreLanguage
    ) async -> Result<SubscriptionLocalization, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData = SubscriptionLocalizationCreateRequest.Data(
            type: .subscriptionLocalizations,
            attributes: .init(
                name: name,
                locale: locale.rawValue,
                description: description
            ),
            relationships: .init(
                subscription: .init(
                    data: .init(type: .subscriptions, id: subscriptionId)
                )
            )
        )

        let request = Resources.v1.subscriptionLocalizations.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let localization = SubscriptionLocalization(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(localization)
        } catch {
            return handleRequestFailure(error: error)
        }
    }

    public func patchSubscriptionPrice(
        subscriptionsId: String,
        pricePountId: String,
        prices: [SubscriptionPricePoint]
    ) async -> Result<Subscription, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let relationships = SubscriptionUpdateRequest.Data.Relationships(
            prices: .init(data: prices.map { .init(type: .subscriptionPrices, id: $0.id) })
        )

        let requestData = SubscriptionUpdateRequest.Data(
            type: .subscriptions,
            id: subscriptionsId,
            relationships: relationships
        )

        let includedItems: [SubscriptionUpdateRequest.IncludedItem] = prices.map { price in
            let pricePointData = SubscriptionPriceInlineCreate.Relationships.SubscriptionPricePoint.Data(
                type: .subscriptionPricePoints,
                id: pricePountId
            )

            let relationship = SubscriptionPriceInlineCreate.Relationships(
                subscriptionPricePoint: .init(data: pricePointData)
            )

            return .subscriptionPriceInlineCreate(
                SubscriptionPriceInlineCreate(
                    type: .subscriptionPrices,
                    id: price.id,
                    relationships: relationship
                )
            )
        }

        let request = Resources.v1.subscriptions.id(subscriptionsId).patch(
            .init(data: requestData, included: includedItems)
        )

        do {
            let data = try await client.send(request).data
            guard let subscription = Subscription(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(subscription)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func patchSubscriptionIntroductoryOffers(
        subscriptionsId: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        duration: SubscriptionOfferDuration,
        offerMode: SubscriptionOfferMode,
        numberOfPeriods: Int,
        territories: [Territory]
    ) async -> Result<Subscription, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        guard let duration: AppStoreAPI.SubscriptionOfferDuration = .init(rawValue: duration.rawValue),
              let offerMode: AppStoreAPI.SubscriptionOfferMode = .init(rawValue: offerMode.rawValue)
        else {
            return .failure(.network(type: .invalidURL))
        }

        let includedItems: [SubscriptionUpdateRequest.IncludedItem] = territories.enumerated().map { index, territory in
            let temporaryId = "newIntroOffer-\(index)"

            let attributes = SubscriptionIntroductoryOfferInlineCreate.Attributes(
                startDate: startDate?.toString(),
                endDate: endDate?.toString(),
                duration: duration,
                offerMode: offerMode,
                numberOfPeriods: numberOfPeriods
            )

            let relationship = SubscriptionIntroductoryOfferInlineCreate.Relationships(
                territory: .init(
                    data: .init(
                        type: .territories,
                        id: territory.id
                    )
                )
            )

            return .subscriptionIntroductoryOfferInlineCreate(
                .init(
                    id: temporaryId,
                    attributes: attributes,
                    relationships: relationship
                )
            )
        }

        let introductoryOffersData = includedItems.compactMap { item -> SubscriptionUpdateRequest.Data.Relationships.IntroductoryOffers.Datum? in
            guard case let .subscriptionIntroductoryOfferInlineCreate(offer) = item else { return nil }
            return .init(
                type: .subscriptionIntroductoryOffers,
                id: offer.id ?? ""
            )
        }

        let relationships = SubscriptionUpdateRequest.Data.Relationships(
            introductoryOffers: .init(data: introductoryOffersData)
        )

        let requestData = SubscriptionUpdateRequest.Data(
            type: .subscriptions,
            id: subscriptionsId,
            relationships: relationships
        )

        let request = Resources.v1.subscriptions.id(subscriptionsId).patch(
            .init(data: requestData, included: includedItems)
        )

        do {
            let data = try await client.send(request).data
            guard let subscription = Subscription(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(subscription)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func deleteSubscription(subscriptionsId: String) async -> Result<Bool, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.subscriptions.id(subscriptionsId).delete
        do {
            let _ = try await client.send(request)
            return .success(true)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}

extension SubscriptionsService {
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
