//
// Copyright © 2026 Alexander Romanov
// AppStoreVersionExperimentsServicesProtocol.swift, created on 28.10.2026
//

import AppStoreAPI
import Foundation

public protocol AppStoreVersionExperimentsServicesProtocol: Sendable {
    func fetchExperiments(
        appId: String,
        states: [AppStoreVersionExperimentV2.State]?,
        force: Bool,
    ) async -> Result<[AppStoreVersionExperimentV2], Error>
    func fetchExperiment(id: String, force: Bool) async -> Result<AppStoreVersionExperimentV2, Error>
    func postExperiment(
        appId: String,
        name: String,
        platform: Platform,
        trafficProportion: Int,
    ) async -> Result<AppStoreVersionExperimentV2, Error>
    func patchExperiment(
        id: String,
        name: String?,
        trafficProportion: Int?,
        isStarted: Bool?,
    ) async -> Result<AppStoreVersionExperimentV2, Error>
    func deleteExperiment(id: String) async -> Result<Void, Error>

    func fetchTreatments(experimentId: String, force: Bool) async -> Result<[AppStoreVersionExperimentTreatment], Error>
    func postTreatment(experimentId: String, name: String, appIconName: String?) async -> Result<AppStoreVersionExperimentTreatment, Error>
    func patchTreatment(id: String, name: String?, appIconName: String?) async -> Result<AppStoreVersionExperimentTreatment, Error>
    func deleteTreatment(id: String) async -> Result<Void, Error>

    func fetchTreatmentLocalizations(treatmentId: String, force: Bool) async -> Result<[AppStoreVersionExperimentTreatmentLocalization], Error>
    func postTreatmentLocalization(
        treatmentId: String,
        locale: AppStoreLanguage,
        placementIds: [String],
    ) async -> Result<AppStoreVersionExperimentTreatmentLocalization, Error>
    func deleteTreatmentLocalization(id: String) async -> Result<Void, Error>
}

// MARK: - Default-argument convenience

public extension AppStoreVersionExperimentsServicesProtocol {
    func fetchExperiments(appId: String, force: Bool = false) async -> Result<[AppStoreVersionExperimentV2], Error> {
        await fetchExperiments(appId: appId, states: nil, force: force)
    }

    func fetchExperiment(id: String) async -> Result<AppStoreVersionExperimentV2, Error> {
        await fetchExperiment(id: id, force: false)
    }

    func startExperiment(id: String) async -> Result<AppStoreVersionExperimentV2, Error> {
        await patchExperiment(id: id, name: nil, trafficProportion: nil, isStarted: true)
    }

    func stopExperiment(id: String) async -> Result<AppStoreVersionExperimentV2, Error> {
        await patchExperiment(id: id, name: nil, trafficProportion: nil, isStarted: false)
    }

    func fetchTreatments(experimentId: String) async -> Result<[AppStoreVersionExperimentTreatment], Error> {
        await fetchTreatments(experimentId: experimentId, force: false)
    }

    func postTreatment(experimentId: String, name: String) async -> Result<AppStoreVersionExperimentTreatment, Error> {
        await postTreatment(experimentId: experimentId, name: name, appIconName: nil)
    }

    func fetchTreatmentLocalizations(treatmentId: String) async -> Result<[AppStoreVersionExperimentTreatmentLocalization], Error> {
        await fetchTreatmentLocalizations(treatmentId: treatmentId, force: false)
    }

    func postTreatmentLocalization(treatmentId: String, locale: AppStoreLanguage) async -> Result<AppStoreVersionExperimentTreatmentLocalization, Error> {
        await postTreatmentLocalization(treatmentId: treatmentId, locale: locale, placementIds: [])
    }
}

extension AppStoreVersionExperimentsService: AppStoreVersionExperimentsServicesProtocol {}
