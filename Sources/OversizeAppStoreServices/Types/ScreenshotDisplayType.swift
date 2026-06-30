//
// Copyright © 2024 Alexander Romanov
// ScreenshotDisplayType.swift, created on 20.11.2024
//

import AppStoreAPI
import Foundation

public enum ScreenshotDisplayType: String, CaseIterable, Codable, Sendable {
    case appIphone67 = "APP_IPHONE_67"
    case appIphone65 = "APP_IPHONE_65"
    case appIphone61 = "APP_IPHONE_61"
    case appIphone58 = "APP_IPHONE_58"
    case appIphone55 = "APP_IPHONE_55"
    case appIphone47 = "APP_IPHONE_47"
    case appIphone40 = "APP_IPHONE_40"
    case appIphone35 = "APP_IPHONE_35"
    case appIpadPro129 = "APP_IPAD_PRO_129"
    case appIpadPro3gen129 = "APP_IPAD_PRO_3GEN_129"
    case appIpadPro3gen11 = "APP_IPAD_PRO_3GEN_11"
    case appIpad105 = "APP_IPAD_105"
    case appIpad97 = "APP_IPAD_97"
    case appDesktop = "APP_DESKTOP"
    case appWatchUltra = "APP_WATCH_ULTRA"
    case appWatchSeries10 = "APP_WATCH_SERIES_10"
    case appWatchSeries7 = "APP_WATCH_SERIES_7"
    case appWatchSeries4 = "APP_WATCH_SERIES_4"
    case appWatchSeries3 = "APP_WATCH_SERIES_3"
    case appAppleTv = "APP_APPLE_TV"
    case appAppleVisionPro = "APP_APPLE_VISION_PRO"
    case imessageAppIphone67 = "IMESSAGE_APP_IPHONE_67"
    case imessageAppIphone65 = "IMESSAGE_APP_IPHONE_65"
    case imessageAppIphone61 = "IMESSAGE_APP_IPHONE_61"
    case imessageAppIphone58 = "IMESSAGE_APP_IPHONE_58"
    case imessageAppIphone55 = "IMESSAGE_APP_IPHONE_55"
    case imessageAppIphone47 = "IMESSAGE_APP_IPHONE_47"
    case imessageAppIphone40 = "IMESSAGE_APP_IPHONE_40"
    case imessageAppIpadPro129 = "IMESSAGE_APP_IPAD_PRO_129"
    case imessageAppIpadPro3gen129 = "IMESSAGE_APP_IPAD_PRO_3GEN_129"
    case imessageAppIpadPro3gen11 = "IMESSAGE_APP_IPAD_PRO_3GEN_11"
    case imessageAppIpad105 = "IMESSAGE_APP_IPAD_105"
    case imessageAppIpad97 = "IMESSAGE_APP_IPAD_97"

    public var displayName: String {
        switch self {
        case .appIphone67: "iPhone 6.7\""
        case .appIphone65: "iPhone 6.5\""
        case .appIphone61: "iPhone 6.1\""
        case .appIphone58: "iPhone 5.8\""
        case .appIphone55: "iPhone 5.5\""
        case .appIphone47: "iPhone 4.7\""
        case .appIphone40: "iPhone 4.0\""
        case .appIphone35: "iPhone 3.5\""
        case .appIpadPro129: "iPad Pro 12.9\""
        case .appIpadPro3gen129: "iPad Pro 12.9\" (3rd gen)"
        case .appIpadPro3gen11: "iPad Pro 11\" (3rd gen)"
        case .appIpad105: "iPad 10.5\""
        case .appIpad97: "iPad 9.7\""
        case .appDesktop: "Desktop"
        case .appWatchUltra: "Apple Watch Ultra"
        case .appWatchSeries10: "Apple Watch Series 10"
        case .appWatchSeries7: "Apple Watch Series 7"
        case .appWatchSeries4: "Apple Watch Series 4"
        case .appWatchSeries3: "Apple Watch Series 3"
        case .appAppleTv: "Apple TV"
        case .appAppleVisionPro: "Apple Vision Pro"
        case .imessageAppIphone67: "iMessage iPhone 6.7\""
        case .imessageAppIphone65: "iMessage iPhone 6.5\""
        case .imessageAppIphone61: "iMessage iPhone 6.1\""
        case .imessageAppIphone58: "iMessage iPhone 5.8\""
        case .imessageAppIphone55: "iMessage iPhone 5.5\""
        case .imessageAppIphone47: "iMessage iPhone 4.7\""
        case .imessageAppIphone40: "iMessage iPhone 4.0\""
        case .imessageAppIpadPro129: "iMessage iPad Pro 12.9\""
        case .imessageAppIpadPro3gen129: "iMessage iPad Pro 12.9\" (3rd gen)"
        case .imessageAppIpadPro3gen11: "iMessage iPad Pro 11\" (3rd gen)"
        case .imessageAppIpad105: "iMessage iPad 10.5\""
        case .imessageAppIpad97: "iMessage iPad 9.7\""
        }
    }

    public init?(schema: AppStoreAPI.ScreenshotDisplayType) {
        switch schema {
        case .appIphone67: self = .appIphone67
        case .appIphone65: self = .appIphone65
        case .appIphone61: self = .appIphone61
        case .appIphone58: self = .appIphone58
        case .appIphone55: self = .appIphone55
        case .appIphone47: self = .appIphone47
        case .appIphone40: self = .appIphone40
        case .appIphone35: self = .appIphone35
        case .appIpadPro129: self = .appIpadPro129
        case .appIpadPro3gen129: self = .appIpadPro3gen129
        case .appIpadPro3gen11: self = .appIpadPro3gen11
        case .appIpad105: self = .appIpad105
        case .appIpad97: self = .appIpad97
        case .appDesktop: self = .appDesktop
        case .appWatchUltra: self = .appWatchUltra
        case .appWatchSeries10: self = .appWatchSeries10
        case .appWatchSeries7: self = .appWatchSeries7
        case .appWatchSeries4: self = .appWatchSeries4
        case .appWatchSeries3: self = .appWatchSeries3
        case .appAppleTv: self = .appAppleTv
        case .appAppleVisionPro: self = .appAppleVisionPro
        case .imessageAppIphone67: self = .imessageAppIphone67
        case .imessageAppIphone65: self = .imessageAppIphone65
        case .imessageAppIphone61: self = .imessageAppIphone61
        case .imessageAppIphone58: self = .imessageAppIphone58
        case .imessageAppIphone55: self = .imessageAppIphone55
        case .imessageAppIphone47: self = .imessageAppIphone47
        case .imessageAppIphone40: self = .imessageAppIphone40
        case .imessageAppIpadPro129: self = .imessageAppIpadPro129
        case .imessageAppIpadPro3gen129: self = .imessageAppIpadPro3gen129
        case .imessageAppIpadPro3gen11: self = .imessageAppIpadPro3gen11
        case .imessageAppIpad105: self = .imessageAppIpad105
        case .imessageAppIpad97: self = .imessageAppIpad97
        }
    }

    public var schema: AppStoreAPI.ScreenshotDisplayType {
        switch self {
        case .appIphone67: .appIphone67
        case .appIphone65: .appIphone65
        case .appIphone61: .appIphone61
        case .appIphone58: .appIphone58
        case .appIphone55: .appIphone55
        case .appIphone47: .appIphone47
        case .appIphone40: .appIphone40
        case .appIphone35: .appIphone35
        case .appIpadPro129: .appIpadPro129
        case .appIpadPro3gen129: .appIpadPro3gen129
        case .appIpadPro3gen11: .appIpadPro3gen11
        case .appIpad105: .appIpad105
        case .appIpad97: .appIpad97
        case .appDesktop: .appDesktop
        case .appWatchUltra: .appWatchUltra
        case .appWatchSeries10: .appWatchSeries10
        case .appWatchSeries7: .appWatchSeries7
        case .appWatchSeries4: .appWatchSeries4
        case .appWatchSeries3: .appWatchSeries3
        case .appAppleTv: .appAppleTv
        case .appAppleVisionPro: .appAppleVisionPro
        case .imessageAppIphone67: .imessageAppIphone67
        case .imessageAppIphone65: .imessageAppIphone65
        case .imessageAppIphone61: .imessageAppIphone61
        case .imessageAppIphone58: .imessageAppIphone58
        case .imessageAppIphone55: .imessageAppIphone55
        case .imessageAppIphone47: .imessageAppIphone47
        case .imessageAppIphone40: .imessageAppIphone40
        case .imessageAppIpadPro129: .imessageAppIpadPro129
        case .imessageAppIpadPro3gen129: .imessageAppIpadPro3gen129
        case .imessageAppIpadPro3gen11: .imessageAppIpadPro3gen11
        case .imessageAppIpad105: .imessageAppIpad105
        case .imessageAppIpad97: .imessageAppIpad97
        }
    }
}
