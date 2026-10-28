//
// Copyright © 2026 Alexander Romanov
// AppStoreVersionExperimentTreatment.swift, created on 28.10.2026
//

import AppStoreAPI
import Foundation

public struct AppStoreVersionExperimentTreatment: Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let appIcon: ImageAsset?
    public let appIconName: String?
    public let promotedDate: Date?
    public let experimentId: String?
    public let localizationIds: [String]
    public let localizations: [AppStoreVersionExperimentTreatmentLocalization]

    public init(
        id: String,
        name: String? = nil,
        appIcon: ImageAsset? = nil,
        appIconName: String? = nil,
        promotedDate: Date? = nil,
        experimentId: String? = nil,
        localizationIds: [String] = [],
        localizations: [AppStoreVersionExperimentTreatmentLocalization] = [],
    ) {
        self.id = id
        self.name = name
        self.appIcon = appIcon
        self.appIconName = appIconName
        self.promotedDate = promotedDate
        self.experimentId = experimentId
        self.localizationIds = localizationIds
        self.localizations = localizations
    }

    public init(
        schema: AppStoreAPI.AppStoreVersionExperimentTreatment,
        included: [AppStoreAPI.AppStoreVersionExperimentTreatmentsResponse.IncludedItem]? = nil,
    ) {
        let localizationIds = schema.relationships?.appStoreVersionExperimentTreatmentLocalizations?.data?.map(\.id) ?? []
        let includedLocalizations: [String: AppStoreVersionExperimentTreatmentLocalization] = (included ?? []).reduce(into: [:]) { result, item in
            if case let .appStoreVersionExperimentTreatmentLocalization(localization) = item {
                result[localization.id] = AppStoreVersionExperimentTreatmentLocalization(schema: localization)
            }
        }
        self.init(
            id: schema.id,
            name: schema.attributes?.name,
            appIcon: schema.attributes?.appIcon.map(ImageAsset.init(schema:)),
            appIconName: schema.attributes?.appIconName,
            promotedDate: schema.attributes?.promotedDate,
            experimentId: schema.relationships?.appStoreVersionExperimentV2?.data?.id
                ?? schema.relationships?.appStoreVersionExperiment?.data?.id,
            localizationIds: localizationIds,
            localizations: localizationIds.compactMap { includedLocalizations[$0] },
        )
    }
}
