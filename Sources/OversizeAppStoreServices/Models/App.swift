//
// Copyright © 2024 Alexander Romanov
// App.swift, created on 21.07.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public struct App: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let bundleID: String
    public let sku: String
    public let primaryLocale: AppStoreLanguage
    public let contentRightsDeclaration: ContentRightsDeclaration?
    public let isOrEverWasMadeForKids: Bool?
    public let subscriptionStatusURL: URL?
    public let subscriptionStatusURLVersion: SubscriptionStatusURLVersion?
    public let subscriptionStatusURLForSandbox: URL?
    public let subscriptionStatusURLVersionForSandbox: SubscriptionStatusURLVersion?

    public var included: Included?

    public init?(schema: AppStoreAPI.App) {
        guard let attributes = schema.attributes,
              let bundleID = attributes.bundleID,
              let name = attributes.name,
              let sku = attributes.sku,
              let primaryLocaleRawValue = attributes.primaryLocale,
              let primaryLocale = AppStoreLanguage(rawValue: primaryLocaleRawValue)
        else { return nil }

        id = schema.id
        self.name = name
        self.bundleID = bundleID
        self.sku = sku
        self.primaryLocale = primaryLocale
        contentRightsDeclaration = attributes.contentRightsDeclaration
            .flatMap { ContentRightsDeclaration(rawValue: $0.rawValue) }
        isOrEverWasMadeForKids = attributes.isOrEverWasMadeForKids
        subscriptionStatusURL = attributes.subscriptionStatusURL
        subscriptionStatusURLForSandbox = attributes.subscriptionStatusURLForSandbox
        subscriptionStatusURLVersion = attributes.subscriptionStatusURLVersion
            .flatMap { SubscriptionStatusURLVersion(rawValue: $0.rawValue) } ?? .none
        subscriptionStatusURLVersionForSandbox = attributes.subscriptionStatusURLVersionForSandbox
            .flatMap { SubscriptionStatusURLVersion(rawValue: $0.rawValue) } ?? .none
        included = nil
    }

    public init?(schema: AppStoreAPI.App, included: [AppStoreAPI.AppsResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes,
              let bundleID = attributes.bundleID,
              let name = attributes.name,
              let sku = attributes.sku,
              let primaryLocaleRawValue = attributes.primaryLocale,
              let primaryLocale = AppStoreLanguage(rawValue: primaryLocaleRawValue)
        else { return nil }

        id = schema.id
        self.name = name
        self.bundleID = bundleID
        self.sku = sku
        self.primaryLocale = primaryLocale
        contentRightsDeclaration = attributes.contentRightsDeclaration
            .flatMap { ContentRightsDeclaration(rawValue: $0.rawValue) }
        isOrEverWasMadeForKids = attributes.isOrEverWasMadeForKids
        subscriptionStatusURL = attributes.subscriptionStatusURL
        subscriptionStatusURLForSandbox = attributes.subscriptionStatusURLForSandbox
        subscriptionStatusURLVersion = attributes.subscriptionStatusURLVersion
            .flatMap { SubscriptionStatusURLVersion(rawValue: $0.rawValue) } ?? .none
        subscriptionStatusURLVersionForSandbox = attributes.subscriptionStatusURLVersionForSandbox
            .flatMap { SubscriptionStatusURLVersion(rawValue: $0.rawValue) } ?? .none

        if let includedItems = included {
            var appStoreVersions: [AppStoreAPI.AppStoreVersion] = []
            var builds: [AppStoreAPI.Build] = []
            var prereleaseVersions: [AppStoreAPI.PrereleaseVersion] = []

            for includedItem in includedItems {
                switch includedItem {
                case let .appStoreVersion(includedAppStoreVersion):
                    appStoreVersions.append(includedAppStoreVersion)
                case let .build(includedBuild):
                    builds.append(includedBuild)
                case let .prereleaseVersion(prereleaseVersion):
                    prereleaseVersions.append(prereleaseVersion)
                default:
                    continue
                }
            }

            self.included = Included(
                appStoreVersions: appStoreVersions.compactMap { appStoreVersion in
                    .init(schema: appStoreVersion)
                },
                builds: builds.compactMap { .init(schema: $0) }.sorted(by: { $0.uploadedDate > $1.uploadedDate }),
                prereleaseVersions: prereleaseVersions.compactMap { .init(schema: $0, builds: []) }
            )
        } else {
            self.included = nil
        }
    }

    public init?(schema: AppStoreAPI.App, included: [AppStoreAPI.AppResponse.IncludedItem]? = nil) {
        guard let attributes = schema.attributes,
              let bundleID = attributes.bundleID,
              let name = attributes.name,
              let sku = attributes.sku,
              let primaryLocaleRawValue = attributes.primaryLocale,
              let primaryLocale = AppStoreLanguage(rawValue: primaryLocaleRawValue)
        else { return nil }

        id = schema.id
        self.name = name
        self.bundleID = bundleID
        self.sku = sku
        self.primaryLocale = primaryLocale
        contentRightsDeclaration = attributes.contentRightsDeclaration
            .flatMap { ContentRightsDeclaration(rawValue: $0.rawValue) }
        isOrEverWasMadeForKids = attributes.isOrEverWasMadeForKids
        subscriptionStatusURL = attributes.subscriptionStatusURL
        subscriptionStatusURLForSandbox = attributes.subscriptionStatusURLForSandbox
        subscriptionStatusURLVersion = attributes.subscriptionStatusURLVersion
            .flatMap { SubscriptionStatusURLVersion(rawValue: $0.rawValue) } ?? .none
        subscriptionStatusURLVersionForSandbox = attributes.subscriptionStatusURLVersionForSandbox
            .flatMap { SubscriptionStatusURLVersion(rawValue: $0.rawValue) } ?? .none

        if let includedItems = included {
            var appStoreVersions: [AppStoreAPI.AppStoreVersion] = []
            var builds: [AppStoreAPI.Build] = []
            var prereleaseVersions: [AppStoreAPI.PrereleaseVersion] = []

            for includedItem in includedItems {
                switch includedItem {
                case let .appStoreVersion(includedAppStoreVersion):
                    appStoreVersions.append(includedAppStoreVersion)
                case let .build(includedBuild):
                    builds.append(includedBuild)
                case let .prereleaseVersion(prereleaseVersion):
                    prereleaseVersions.append(prereleaseVersion)
                default:
                    continue
                }
            }

            self.included = Included(
                appStoreVersions: appStoreVersions.compactMap { appStoreVersion in
                    .init(
                        schema: appStoreVersion
                    )
                },
                builds: builds.compactMap { .init(schema: $0) }.sorted(by: { $0.uploadedDate > $1.uploadedDate }),
                prereleaseVersions: prereleaseVersions.compactMap { .init(schema: $0, builds: []) }
            )
        } else {
            self.included = nil
        }
    }
}

public extension App {
    struct Included: Sendable {
        public let appStoreVersions: [AppStoreVersion]
        public let builds: [Build]
        public let prereleaseVersions: [PrereleaseVersion]

        public var appStoreVersion: AppStoreVersion? {
            appStoreVersions.last
        }

        public var macOsAppStoreVersions: [AppStoreVersion] {
            appStoreVersions.filter { $0.platform == .macOs }
        }

        public var iOsAppStoreVersions: [AppStoreVersion] {
            appStoreVersions.filter { $0.platform == .ios }
        }

        public var tvOsAppStoreVersions: [AppStoreVersion] {
            appStoreVersions.filter { $0.platform == .tvOs }
        }

        public var visionOsAppStoreVersions: [AppStoreVersion] {
            appStoreVersions.filter { $0.platform == .visionOs }
        }

        public var appStoreVersionsPlatforms: [Platform] {
            var platforms: [Platform] = []

            if !macOsAppStoreVersions.isEmpty {
                platforms.append(.macOs)
            }
            if !iOsAppStoreVersions.isEmpty {
                platforms.append(.ios)
            }
            if !tvOsAppStoreVersions.isEmpty {
                platforms.append(.tvOs)
            }
            if !visionOsAppStoreVersions.isEmpty {
                platforms.append(.visionOs)
            }

            return platforms
        }
    }

    var firstNamePath: String {
        name.components(separatedBy: [".", "-", "—"]).first ?? ""
    }

    var lastNamePath: String {
        name.components(separatedBy: [".", "-", "—"]).last ?? ""
    }
}
