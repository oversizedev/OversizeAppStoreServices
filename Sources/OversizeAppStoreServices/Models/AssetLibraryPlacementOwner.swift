//
// Copyright © 2026 Alexander Romanov
// AssetLibraryPlacementOwner.swift, created on 28.10.2026
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public enum AssetLibraryPlacementOwner: Hashable, Sendable {
    case versionLocalization(String)
    case treatmentLocalization(String)

    public var id: String {
        switch self {
        case let .versionLocalization(id), let .treatmentLocalization(id):
            id
        }
    }

    var relationshipKey: String {
        switch self {
        case .versionLocalization: "appStoreVersionLocalization"
        case .treatmentLocalization: "appStoreVersionExperimentTreatmentLocalization"
        }
    }

    var resourceType: String {
        switch self {
        case .versionLocalization: "appStoreVersionLocalizations"
        case .treatmentLocalization: "appStoreVersionExperimentTreatmentLocalizations"
        }
    }

    var relationship: (key: String, value: AnyJSON) {
        (relationshipKey, .object(["data": .object(["type": .string(resourceType), "id": .string(id)])]))
    }
}
