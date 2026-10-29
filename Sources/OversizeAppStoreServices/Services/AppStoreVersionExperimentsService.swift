//
// Copyright © 2026 Alexander Romanov
// AppStoreVersionExperimentsService.swift, created on 28.10.2026
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public actor AppStoreVersionExperimentsService {
    private let client: AppStoreConnectClient

    private static let treatmentsLimit = 50
    private static let localizationsLimit = 50

    public init(authenticator: some AppStoreConnect.Authenticator, cacheAccountID: String? = nil) {
        client = ASCClientFactory.makeClient(authenticator: authenticator, cacheAccountID: cacheAccountID)
    }

    // MARK: - Experiments

    public func fetchExperiments(
        appId: String,
        states: [AppStoreVersionExperimentV2.State]? = nil,
        force: Bool = false,
    ) async -> Result<[AppStoreVersionExperimentV2], Error> {
        let filterState = states?.compactMap {
            Resources.V1.Apps.WithID.AppStoreVersionExperimentsV2.FilterState(rawValue: $0.rawValue)
        }
        return await ASCCache.cached(force: force) {
            let request = Resources.v1.apps.id(appId).appStoreVersionExperimentsV2.get(
                filterState: filterState,
                limit: 200,
                include: [.appStoreVersionExperimentTreatments, .latestControlVersion],
                limitAppStoreVersionExperimentTreatments: Self.treatmentsLimit,
            )
            return try await client.send(request)
        }.map { response in
            response.data.map { AppStoreVersionExperimentV2(schema: $0, included: response.included) }
        }
    }

    public func fetchExperiment(id: String, force: Bool = false) async -> Result<AppStoreVersionExperimentV2, Error> {
        await ASCCache.cached(force: force) {
            let request = Resources.v2.appStoreVersionExperiments.id(id).get(
                include: [.appStoreVersionExperimentTreatments, .latestControlVersion],
                limitAppStoreVersionExperimentTreatments: Self.treatmentsLimit,
            )
            return try await client.send(request)
        }.map { response in
            AppStoreVersionExperimentV2(schema: response.data, included: response.included)
        }
    }

    public func postExperiment(
        appId: String,
        name: String,
        platform: Platform,
        trafficProportion: Int,
    ) async -> Result<AppStoreVersionExperimentV2, Error> {
        guard let schemaPlatform = AppStoreAPI.Platform(rawValue: platform.rawValue) else {
            return .failure(NetworkError.apiError(title: "Unsupported platform", detail: platform.rawValue))
        }
        let request = Resources.v2.appStoreVersionExperiments.post(
            .init(
                data: .init(
                    attributes: .init(name: name, platform: schemaPlatform, trafficProportion: trafficProportion),
                    relationships: .init(app: .init(data: .init(id: appId))),
                ),
            ),
        )
        return await send(request).map { AppStoreVersionExperimentV2(schema: $0.data, included: $0.included) }
    }

    public func patchExperiment(
        id: String,
        name: String? = nil,
        trafficProportion: Int? = nil,
        isStarted: Bool? = nil,
    ) async -> Result<AppStoreVersionExperimentV2, Error> {
        let request = Resources.v2.appStoreVersionExperiments.id(id).patch(
            .init(
                data: .init(
                    id: id,
                    attributes: .init(name: name, trafficProportion: trafficProportion, isStarted: isStarted),
                ),
            ),
        )
        return await send(request).map { AppStoreVersionExperimentV2(schema: $0.data, included: $0.included) }
    }

    public func deleteExperiment(id: String) async -> Result<Void, Error> {
        await send(Resources.v2.appStoreVersionExperiments.id(id).delete)
    }

    // MARK: - Treatments

    public func fetchTreatments(experimentId: String, force: Bool = false) async -> Result<[AppStoreVersionExperimentTreatment], Error> {
        await ASCCache.cached(force: force) {
            let request = Resources.v2.appStoreVersionExperiments.id(experimentId).appStoreVersionExperimentTreatments.get(
                limit: Self.treatmentsLimit,
                include: [.appStoreVersionExperimentTreatmentLocalizations],
                limitAppStoreVersionExperimentTreatmentLocalizations: Self.localizationsLimit,
            )
            return try await client.send(request)
        }.map { response in
            response.data.map { AppStoreVersionExperimentTreatment(schema: $0, included: response.included) }
        }
    }

    public func postTreatment(
        experimentId: String,
        name: String,
        appIconName: String? = nil,
    ) async -> Result<AppStoreVersionExperimentTreatment, Error> {
        let request = Resources.v1.appStoreVersionExperimentTreatments.post(
            .init(
                data: .init(
                    attributes: .init(name: name, appIconName: appIconName),
                    relationships: .init(appStoreVersionExperimentV2: .init(data: .init(id: experimentId))),
                ),
            ),
        )
        return await send(request).map { AppStoreVersionExperimentTreatment(schema: $0.data) }
    }

    public func patchTreatment(
        id: String,
        name: String? = nil,
        appIconName: String? = nil,
    ) async -> Result<AppStoreVersionExperimentTreatment, Error> {
        let request = Resources.v1.appStoreVersionExperimentTreatments.id(id).patch(
            .init(data: .init(id: id, attributes: .init(name: name, appIconName: appIconName))),
        )
        return await send(request).map { AppStoreVersionExperimentTreatment(schema: $0.data) }
    }

    public func deleteTreatment(id: String) async -> Result<Void, Error> {
        await send(Resources.v1.appStoreVersionExperimentTreatments.id(id).delete)
    }

    // MARK: - Treatment localizations

    public func fetchTreatmentLocalizations(
        treatmentId: String,
        force: Bool = false,
    ) async -> Result<[AppStoreVersionExperimentTreatmentLocalization], Error> {
        await ASCCache.cached(force: force) {
            let request = Resources.v1.appStoreVersionExperimentTreatments.id(treatmentId).appStoreVersionExperimentTreatmentLocalizations.get(
                limit: Self.localizationsLimit,
            )
            return try await client.send(request.tolerantPlacements).value
        }.map { response in
            response.data.map(AppStoreVersionExperimentTreatmentLocalization.init(schema:))
        }
    }

    public func postTreatmentLocalization(
        treatmentId: String,
        locale: AppStoreLanguage,
        placementIds: [String] = [],
    ) async -> Result<AppStoreVersionExperimentTreatmentLocalization, Error> {
        let placements: AppStoreVersionExperimentTreatmentLocalizationCreateRequest.Data.Relationships.Placements? = placementIds.isEmpty
            ? nil
            : .init(data: placementIds.map { .init(id: $0) })
        let request = Resources.v1.appStoreVersionExperimentTreatmentLocalizations.post(
            .init(
                data: .init(
                    attributes: .init(locale: locale.rawValue),
                    relationships: .init(
                        appStoreVersionExperimentTreatment: .init(data: .init(id: treatmentId)),
                        placements: placements,
                    ),
                ),
            ),
        )
        return await send(request.tolerantPlacements).map { AppStoreVersionExperimentTreatmentLocalization(schema: $0.value.data) }
    }

    public func deleteTreatmentLocalization(id: String) async -> Result<Void, Error> {
        await send(Resources.v1.appStoreVersionExperimentTreatmentLocalizations.id(id).delete)
    }
}

private extension AppStoreVersionExperimentsService {
    func send<Response: Decodable & Sendable>(_ request: Request<Response>) async -> Result<Response, Error> {
        do {
            return try await .success(client.send(request))
        } catch {
            Log.error("Experiments request \(request.id ?? request.path) failed", error: error)
            return .failure(error.asNetworkError)
        }
    }

    func send(_ request: Request<Void>) async -> Result<Void, Error> {
        do {
            try await client.send(request)
            return .success(())
        } catch {
            Log.error("Experiments request \(request.id ?? request.path) failed", error: error)
            return .failure(error.asNetworkError)
        }
    }
}
