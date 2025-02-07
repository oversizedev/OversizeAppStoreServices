//
// Copyright © 2025 Alexander Romanov
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

        return await cacheService.fetchWithCache(key: "fetchSubscriptionPrices\(subscriptionId)\(filterTerritoryIds ?? [])", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).prices.get(
                filterTerritory: filterTerritoryIds,
                limit: 200,
                include: [.territory, .subscriptionPricePoint]
            )
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }

    // MARK: - Subscription Promotional Offers

    public func fetchSubscriptionPromotionalOffers(
        subscriptionId: String,
        force: Bool = false
    ) async -> Result<[SubscriptionPromotionalOffer], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscriptionPromotionalOffers\(subscriptionId)", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).promotionalOffers.get(
                include: [.prices, .subscription]
            )
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0 /* , included: data.included */ ) }
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

        let requestData = SubscriptionPromotionalOfferCreateRequest.Data(
            type: .subscriptionPromotionalOffers,
            attributes: .init(
                name: name,
                offerCode: offerCode,
                duration: .init(rawValue: duration.rawValue) ?? .oneMonth,
                offerMode: .init(rawValue: offerMode.rawValue) ?? .freeTrial,
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

    // MARK: - Subscription Localizations

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

    // MARK: - Subscription Availability

    public func fetchSubscriptionAvailability(
        subscriptionId: String,
        force: Bool = false
    ) async -> Result<SubscriptionAvailability, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchSubscriptionAvailability\(subscriptionId)", force: force) {
            let request = Resources.v1.subscriptions.id(subscriptionId).subscriptionAvailability.get(
                include: [.availableTerritories]
            )
            return try await client.send(request)
        }.flatMap {
            guard let availability = SubscriptionAvailability(schema: $0.data, included: $0.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(availability)
        }
    }

    // MARK: - Subscription Images

    public func uploadSubscriptionImage(
        subscriptionId: String,
        fileSize: Int,
        fileName: String,
        fileContent _: Data
    ) async -> Result<SubscriptionImage, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData = SubscriptionImageCreateRequest.Data(
            type: .subscriptionImages,
            attributes: .init(
                fileSize: fileSize,
                fileName: fileName
            ),
            relationships: .init(
                subscription: .init(
                    data: .init(type: .subscriptions, id: subscriptionId)
                )
            )
        )

        let request = Resources.v1.subscriptionImages.post(.init(data: requestData))
        do {
            let response = try await client.send(request)
            guard let image = SubscriptionImage(schema: response.data) else {
                return .failure(.network(type: .decode))
            }

            // Upload the actual image content
            if let uploadOperations = response.data.attributes?.uploadOperations {
                for operation in uploadOperations {
                    // Implement upload logic here
                    // You might need to create a separate upload method
                }
            }

            return .success(image)
        } catch {
            return handleRequestFailure(error: error)
        }
    }

    // MARK: - Review Screenshot

//    public func uploadReviewScreenshot(
//        subscriptionId: String,
//        fileSize: Int,
//        fileName: String,
//        fileContent: Data
//    ) async -> Result<ReviewScreenshot, AppError> {
//        guard let client else { return .failure(.network(type: .unauthorized)) }
//
//        let requestData = ReviewScreenshotCreateRequest.Data(
//            type: .reviewScreenshots,
//            attributes: .init(
//                fileSize: fileSize,
//                fileName: fileName
//            ),
//            relationships: .init(
//                subscription: .init(
//                    data: .init(type: .subscriptions, id: subscriptionId)
//                )
//            )
//        )
//
//        let request = Resources.v1.reviewScreenshots.post(.init(data: requestData))
//        do {
//            let response = try await client.send(request)
//            guard let screenshot = ReviewScreenshot(schema: response.data) else {
//                return .failure(.network(type: .decode))
//            }
//
//            // Upload the actual screenshot content
//            if let uploadOperations = response.data.attributes?.uploadOperations {
//                for operation in uploadOperations {
//                    // Implement upload logic here
//                    // You might need to create a separate upload method
//                }
//            }
//
//            return .success(screenshot)
//        } catch {
//            return handleRequestFailure(error: error)
//        }
//    }

    //    public func updateSubscriptionAvailability(
    //        subscriptionId: String,
    //        isAvailableInNewTerritories: Bool,
    //        availableTerritories: [Territory]
    //    ) async -> Result<SubscriptionAvailability, AppError> {
    //        guard let client else { return .failure(.network(type: .unauthorized)) }
    //
    //        let requestData = SubscriptionAvailabilityUpdateRequest.Data( // Cannot find 'SubscriptionAvailabilityUpdateRequest' in scope
    //            type: .subscriptionAvailabilities,
    //            attributes: .init(
    //                isAvailableInNewTerritories: isAvailableInNewTerritories
    //            ),
    //            relationships: .init(
    //                availableTerritories: .init(
    //                    data: availableTerritories.map {
    //                        .init(type: .territories, id: $0.id)
    //                    }
    //                )
    //            )
    //        )
    //
    //        let request = Resources.v1.subscriptions.id(subscriptionId).subscriptionAvailability.patch(.init(data: requestData)) // Value of type 'Resources.V1.Subscriptions.WithID.SubscriptionAvailability' has no member 'patch'
    //        do {
    //            let data = try await client.send(request).data
    //            guard let availability = SubscriptionAvailability(schema: data) else {
    //                return .failure(.network(type: .decode))
    //            }
    //            return .success(availability)
    //        } catch {
    //            return handleRequestFailure(error: error)
    //        }
    //    }
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
