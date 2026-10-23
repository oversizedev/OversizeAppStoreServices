//
// Copyright © 2026 Alexander Romanov
// AssetLibraryDisplayClass.swift, created on 23.10.2026
//

import AppStoreAPI

public enum AssetLibraryDisplayClass: String, CaseIterable, Codable, Sendable {
    case `default` = "DEFAULT"
    case watchUltra = "WATCH_ULTRA"
    case watchSeries10 = "WATCH_SERIES_10"
    case watchSeries7 = "WATCH_SERIES_7"
    case watchSeries4 = "WATCH_SERIES_4"
    case watchSeries3 = "WATCH_SERIES_3"
    case iPhoneDuo = "IPHONE_DUO"
    case iPhoneDynamicIslandLarge = "IPHONE_DYNAMIC_ISLAND_LARGE_DISPLAY"
    case iPhoneDynamicIslandMedium = "IPHONE_DYNAMIC_ISLAND_MEDIUM_DISPLAY"
    case iPhoneFaceIDLarge = "IPHONE_FACE_ID_LARGE_DISPLAY"
    case iPhoneFaceIDMedium = "IPHONE_FACE_ID_MEDIUM_DISPLAY"
    case iPhoneHomeButtonLarge = "IPHONE_HOME_BUTTON_LARGE_DISPLAY"
    case iPhoneHomeButtonMedium = "IPHONE_HOME_BUTTON_MEDIUM_DISPLAY"
    case iPhoneHomeButton40 = "IPHONE_HOME_BUTTON_40_DISPLAY"
    case iPhoneHomeButton35 = "IPHONE_HOME_BUTTON_35_DISPLAY"
    case iPad13 = "IPAD_13_DISPLAY"
    case iPad11 = "IPAD_11_DISPLAY"
    case iPad129 = "IPAD_129_DISPLAY"
    case iPad105 = "IPAD_105_DISPLAY"
    case iPad97 = "IPAD_97_DISPLAY"

    public init?(schema: AppStoreAPI.AppAssetLibraryDisplayClass) {
        self.init(rawValue: schema.rawValue)
    }

    public var displayName: String {
        switch self {
        case .default: "Default"
        case .watchUltra: "Apple Watch Ultra"
        case .watchSeries10: "Apple Watch Series 10"
        case .watchSeries7: "Apple Watch Series 7"
        case .watchSeries4: "Apple Watch Series 4"
        case .watchSeries3: "Apple Watch Series 3"
        case .iPhoneDuo: "iPhone Duo"
        case .iPhoneDynamicIslandLarge: "iPhone 6.9\""
        case .iPhoneDynamicIslandMedium: "iPhone 6.3\""
        case .iPhoneFaceIDLarge: "iPhone 6.5\""
        case .iPhoneFaceIDMedium: "iPhone 6.1\""
        case .iPhoneHomeButtonLarge: "iPhone 5.5\""
        case .iPhoneHomeButtonMedium: "iPhone 4.7\""
        case .iPhoneHomeButton40: "iPhone 4\""
        case .iPhoneHomeButton35: "iPhone 3.5\""
        case .iPad13: "iPad 13\""
        case .iPad11: "iPad 11\""
        case .iPad129: "iPad 12.9\""
        case .iPad105: "iPad 10.5\""
        case .iPad97: "iPad 9.7\""
        }
    }
}
