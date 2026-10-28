//
// Copyright © 2026 Alexander Romanov
// AppStoreVersionExperimentTreatmentLocalization.swift, created on 28.10.2026
//

import AppStoreAPI
import Foundation

public struct AppStoreVersionExperimentTreatmentLocalization: Sendable, Identifiable {
    public let id: String
    public let locale: AppStoreLanguage?
    public let treatmentId: String?
    public let placementIds: [String]

    public var placementOwner: AssetLibraryPlacementOwner {
        .treatmentLocalization(id)
    }

    public init(
        id: String,
        locale: AppStoreLanguage? = nil,
        treatmentId: String? = nil,
        placementIds: [String] = [],
    ) {
        self.id = id
        self.locale = locale
        self.treatmentId = treatmentId
        self.placementIds = placementIds
    }

    public init(schema: AppStoreAPI.AppStoreVersionExperimentTreatmentLocalization) {
        self.init(
            id: schema.id,
            locale: schema.attributes?.locale.flatMap(AppStoreLanguage.init(rawValue:)),
            treatmentId: schema.relationships?.appStoreVersionExperimentTreatment?.data?.id,
            placementIds: schema.relationships?.placements?.data?.map(\.id) ?? [],
        )
    }
}
