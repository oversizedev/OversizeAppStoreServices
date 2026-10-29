//
// Copyright © 2026 Alexander Romanov
// BuildIconAsset.swift, created on 29.10.2026
//

import AppStoreAPI
import Foundation

public struct BuildIconAsset: Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String?
    public let iconType: BuildIconType?
    public let isMasked: Bool
    public let image: ImageAsset?

    public init(
        id: String,
        name: String?,
        iconType: BuildIconType?,
        isMasked: Bool = false,
        image: ImageAsset? = nil,
    ) {
        self.id = id
        self.name = name
        self.iconType = iconType
        self.isMasked = isMasked
        self.image = image
    }

    public init(schema: AppStoreAPI.BuildIcon) {
        id = schema.id
        name = schema.attributes?.name
        iconType = schema.attributes?.iconType.flatMap { BuildIconType(rawValue: $0.rawValue) }
        isMasked = schema.attributes?.isMasked ?? false
        image = schema.attributes?.iconAsset.map { ImageAsset(schema: $0) }
    }

    public var isAlternateExperiment: Bool {
        iconType == .alternateExperiment
    }
}

public enum BuildIconType: String, CaseIterable, Sendable, Hashable {
    case appStore = "APP_STORE"
    case messagesAppStore = "MESSAGES_APP_STORE"
    case watchAppStore = "WATCH_APP_STORE"
    case tvOsHomeScreen = "TV_OS_HOME_SCREEN"
    case tvOsTopShelf = "TV_OS_TOP_SHELF"
    case alternateExperiment = "ALTERNATE_EXPERIMENT"
}
