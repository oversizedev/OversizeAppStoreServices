//
// Copyright © 2024 Alexander Romanov
// AppScreenshotSet.swift, created on 20.11.2024
//

import AppStoreAPI
import Foundation

public struct AppScreenshotSet: Identifiable, Sendable {
    public let id: String
    public let type: String
    public var screenshotDisplayType: ScreenshotDisplayType?
    public var appScreenshots: [AppScreenshot]?

    public init(
        id: String,
        type: String = "appScreenshotSets",
        screenshotDisplayType: ScreenshotDisplayType? = nil,
        appScreenshots: [AppScreenshot]? = nil,
    ) {
        self.id = id
        self.type = type
        self.screenshotDisplayType = screenshotDisplayType
        self.appScreenshots = appScreenshots
    }

    public init(schema: AppStoreAPI.AppScreenshotSet, included: [AppStoreAPI.AppScreenshotSetsResponse.IncludedItem]? = nil) {
        id = schema.id
        type = "appScreenshotSets"

        if let displayType = schema.attributes?.screenshotDisplayType {
            screenshotDisplayType = ScreenshotDisplayType(schema: displayType)
        }

        if let includedItems = included {
            let screenshotSchemas = includedItems.compactMap { item -> AppStoreAPI.AppScreenshot? in
                if case let .appScreenshot(screenshot) = item {
                    return screenshot
                }
                return nil
            }
            appScreenshots = screenshotSchemas.map { AppScreenshot(schema: $0) }
        }
    }

    public static func from(response: AppStoreAPI.AppScreenshotSetsResponse) -> [AppScreenshotSet] {
        response.data.map { AppScreenshotSet(schema: $0, included: response.included) }
    }
}
