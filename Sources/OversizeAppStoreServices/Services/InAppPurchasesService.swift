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

    public func fetchAppInAppPurchase(inAppPurchaseId: String, force: Bool = false) async -> Result<InAppPurchaseV2, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppInAppPurchase\(inAppPurchaseId)", force: force) {
            let request = Resources.v2.inAppPurchases.id(inAppPurchaseId).get()
            return try await client.send(request)
        }.flatMap {
            guard let build: InAppPurchaseV2 = .init(schema: $0.data) else {
                return .failure(.network(type: .decode))
            }
            return .success(build)
        }
    }

    public func fetchAppInAppPurchaseIncludAll(inAppPurchaseId: String, force: Bool = false) async -> Result<InAppPurchaseV2, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppInAppPurchaseIncludAll\(inAppPurchaseId)", force: force) {
            let request = Resources.v2.inAppPurchases.id(inAppPurchaseId).get(include: [
                .appStoreReviewScreenshot,
                .content,
                .iapPriceSchedule,
                .images,
                .inAppPurchaseAvailability,
                .inAppPurchaseLocalizations,
                .pricePoints,
                .promotedPurchase,
            ])
            return try await client.send(request)
        }.flatMap {
            guard let inAppPurchaseV2: InAppPurchaseV2 = .init(schema: $0.data, included: $0.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(inAppPurchaseV2)
        }
    }

    public func fetchAppInAppPurchaseIncludAllWithoutAvailability(inAppPurchaseId: String, force: Bool = false) async -> Result<InAppPurchaseV2, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppInAppPurchaseIncludAllWithoutAvailability\(inAppPurchaseId)", force: force) {
            let request = Resources.v2.inAppPurchases.id(inAppPurchaseId).get(include: [
                .appStoreReviewScreenshot,
                .content,
                .iapPriceSchedule,
                .images,
                .inAppPurchaseLocalizations,
                .pricePoints,
                .promotedPurchase,
            ])
            return try await client.send(request)
        }.flatMap {
            guard let inAppPurchaseV2: InAppPurchaseV2 = .init(schema: $0.data, included: $0.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(inAppPurchaseV2)
        }
    }

    public func fetchTerritories(force: Bool = false) async -> Result<[Territory], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchTerritories", force: force) {
            let request = Resources.v1.territories.get(limit: 200)
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchPricePoints(
        inAppPurchaseId: String,
        filterTerritory: [Territory]? = nil,
        force: Bool = false
    ) async -> Result<[InAppPurchasePricePoint], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        var filterTerritorIds: [String]? = nil
        if let filterTerritory { filterTerritorIds = filterTerritory.compactMap { $0.id } }

        return await cacheService.fetchWithCache(key: "fetchTerritories\(inAppPurchaseId)\(filterTerritorIds ?? [])", force: force) {
            let request = Resources.v2.inAppPurchases.id(inAppPurchaseId).pricePoints.get(filterTerritory: filterTerritorIds, limit: 200)
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchInAppPurchaseAvailabilityIncludedAvailableTerritories(
        inAppPurchaseId: String,
        force: Bool = false
    ) async -> Result<InAppPurchaseAvailability, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchInAppPurchaseAvailabilityIncludedAvailableTerritories\(inAppPurchaseId)", force: force) {
            let request = Resources.v2.inAppPurchases.id(inAppPurchaseId).inAppPurchaseAvailability.get(
                include: [.availableTerritories],
                limitAvailableTerritories: 50
            )
            return try await client.send(request)
        }.flatMap {
            guard let inAppPurchaseAvailability: InAppPurchaseAvailability = .init(schema: $0.data, included: $0.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(inAppPurchaseAvailability)
        }
    }

    public func fetchInAppPurchaseAvailability(
        inAppPurchaseId: String,
        force: Bool = false
    ) async -> Result<InAppPurchaseAvailability, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchInAppPurchaseAvailability\(inAppPurchaseId)", force: force) {
            let request = Resources.v2.inAppPurchases.id(inAppPurchaseId).inAppPurchaseAvailability.get()
            return try await client.send(request)
        }.flatMap {
            guard let inAppPurchaseAvailability: InAppPurchaseAvailability = .init(schema: $0.data) else {
                return .failure(.network(type: .decode))
            }
            return .success(inAppPurchaseAvailability)
        }
    }

    public func fetchInAppPurchaseAvailabilitiesAvailableTerritories(
        inAppPurchaseAvailabilityId: String,
        force: Bool = false
    ) async -> Result<[Territory], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchInAppPurchaseAvailabilityIncludedAvailableTerritories\(inAppPurchaseAvailabilityId)", force: force) {
            let request = Resources.v1.inAppPurchaseAvailabilities.id(inAppPurchaseAvailabilityId).availableTerritories.get(limit: 200)
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchAppPriceScheduleBaseTerritory(
        appPriceSchedulesId: String,
        force: Bool = false
    ) async -> Result<Territory, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppPriceScheduleBaseTerritory\(appPriceSchedulesId)", force: force) {
            let request = Resources.v1.appPriceSchedules.id(appPriceSchedulesId).baseTerritory.get()
            return try await client.send(request)
        }.flatMap {
            guard let territory: Territory = .init(schema: $0.data) else {
                return .failure(.network(type: .decode))
            }
            return .success(territory)
        }
    }

    public func fetchInAppPurchasePriceSchedulesBaseTerritory(
        inAppPurchaseId: String,
        force: Bool = false
    ) async -> Result<Territory, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchInAppPurchasePriceSchedulesBaseTerritory\(inAppPurchaseId)", force: force) {
            let request = Resources.v1.inAppPurchasePriceSchedules.id(inAppPurchaseId).baseTerritory.get()
            return try await client.send(request)
        }.flatMap {
            guard let territory: Territory = .init(schema: $0.data) else {
                return .failure(.network(type: .decode))
            }
            return .success(territory)
        }
    }

    public func fetchInAppPurchasePriceSchedule(
        inAppPurchasePriceSchedulesId: String,
        force: Bool = false
    ) async -> Result<InAppPurchasePriceSchedule, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchInAppPurchasePriceSchedule\(inAppPurchasePriceSchedulesId)", force: force) {
            let request = Resources.v1.inAppPurchasePriceSchedules.id(inAppPurchasePriceSchedulesId).get(include: [.automaticPrices, .manualPrices, .baseTerritory])
            return try await client.send(request)
        }.flatMap {
            guard let territory: InAppPurchasePriceSchedule = .init(schema: $0.data, included: $0.included) else {
                return .failure(.network(type: .decode))
            }
            return .success(territory)
        }
    }

    public func fetchInAppPurchasePriceScheduleAutomaticPrices(
        inAppPurchasePriceSchedulesId: String,
        force: Bool = false
    ) async -> Result<[InAppPurchasePrice], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchInAppPurchasePriceScheduleAutomaticPrices\(inAppPurchasePriceSchedulesId)", force: force) {
            let request = Resources.v1.inAppPurchasePriceSchedules.id(inAppPurchasePriceSchedulesId).automaticPrices.get(limit: 200, include: [.inAppPurchasePricePoint, .territory])
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }

    public func fetchInAppPurchasePriceScheduleManualPrices(
        inAppPurchasePriceSchedulesId: String,
        force: Bool = false
    ) async -> Result<[InAppPurchasePrice], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchInAppPurchasePriceScheduleManualPrices\(inAppPurchasePriceSchedulesId)", force: force) {
            let request = Resources.v1.inAppPurchasePriceSchedules.id(inAppPurchasePriceSchedulesId).manualPrices.get(limit: 200, include: [.inAppPurchasePricePoint, .territory])
            return try await client.send(request)
        }.map { data in
            data.data.compactMap { .init(schema: $0, included: data.included) }
        }
    }

    public func postInAppPurchase(
        appId: String,
        name: String,
        productID: String,
        inAppPurchaseType: InAppPurchaseType
    ) async -> Result<InAppPurchaseV2, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        guard let inAppPurchaseType: AppStoreAPI.InAppPurchaseType = .init(rawValue: inAppPurchaseType.rawValue) else { return .failure(.network(type: .unauthorized)) }

        let requestData: InAppPurchaseV2CreateRequest.Data = .init(
            type: .inAppPurchases,
            attributes: .init(
                name: name,
                productID: productID,
                inAppPurchaseType: inAppPurchaseType
            ),
            relationships: .init(
                app: .init(
                    data: .init(
                        type: .apps,
                        id: appId
                    )
                )
            )
        )
        let request = Resources.v2.inAppPurchases.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let app = InAppPurchaseV2(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func postInAppPurchaseLocalization(
        inAppPurchaseV2Id: String,
        name: String,
        description: String?,
        locale: AppStoreLanguage
    ) async -> Result<InAppPurchaseLocalization, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData: InAppPurchaseLocalizationCreateRequest.Data = .init(
            type: .inAppPurchaseLocalizations,
            attributes: .init(
                name: name,
                locale: locale.rawValue,
                description: description
            ),
            relationships: .init(inAppPurchaseV2: .init(data: .init(
                type: .inAppPurchases,
                id: inAppPurchaseV2Id
            )))
        )
        let request = Resources.v1.inAppPurchaseLocalizations.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let app = InAppPurchaseLocalization(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func postInAppPurchaseAvailabilities(
        inAppPurchaseV2Id: String,
        isAvailableInNewTerritories: Bool,
        availableTerritories: [Territory]
    ) async -> Result<InAppPurchaseAvailability, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData: InAppPurchaseAvailabilityCreateRequest.Data = .init(
            type: .inAppPurchaseAvailabilities,
            attributes: .init(
                isAvailableInNewTerritories: isAvailableInNewTerritories
            ),
            relationships: .init(
                inAppPurchase: .init(data: .init(type: .inAppPurchases, id: inAppPurchaseV2Id)),
                availableTerritories: .init(
                    data: availableTerritories.compactMap { .init(
                        type: .territories,
                        id: $0.id
                    ) }
                )
            )
        )

        let request = Resources.v1.inAppPurchaseAvailabilities.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let inAppPurchaseAvailability = InAppPurchaseAvailability(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(inAppPurchaseAvailability)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    public func postInAppPurchaseLocalization(
        inAppPurchaseV2Id: String,
        territories: [Territory],
        isAvailableInNewTerritories: Bool
    ) async -> Result<InAppPurchaseAvailability, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestData: InAppPurchaseAvailabilityCreateRequest.Data = .init(
            type: .inAppPurchaseAvailabilities,
            attributes: .init(isAvailableInNewTerritories: isAvailableInNewTerritories),
            relationships: .init(
                inAppPurchase: .init(
                    data: .init(
                        type: .inAppPurchases,
                        id: inAppPurchaseV2Id
                    )
                ),
                availableTerritories: .init(data: territories.compactMap {
                    .init(type: .territories, id: $0.id)
                })
            )
        )
        let request = Resources.v1.inAppPurchaseAvailabilities.post(.init(data: requestData))
        do {
            let data = try await client.send(request).data
            guard let app = InAppPurchaseAvailability(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(app)
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }
}

extension InAppPurchasesService {
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
