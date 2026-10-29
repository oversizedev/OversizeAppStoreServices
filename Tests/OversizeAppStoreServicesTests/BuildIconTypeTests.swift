//
// Copyright © 2026 Alexander Romanov
// BuildIconTypeTests.swift, created on 29.10.2026
//

import AppStoreAPI
@testable import OversizeAppStoreServices
import Testing

struct BuildIconTypeTests {
    @Test("BuildIconType should have the same cases as AppStoreAPI")
    func checkBuildIconTypeCasesMatch() {
        let localCases = Set(OversizeAppStoreServices.BuildIconType.allCases.map(\.rawValue))
        let generatedCases = Set(AppStoreAPI.IconAssetType.allCases.map(\.rawValue))

        #expect(localCases == generatedCases)
    }

    @Test("BuildIconAsset maps the schema attributes")
    func mapsSchema() {
        let schema = AppStoreAPI.BuildIcon(
            id: "icon-1",
            attributes: .init(
                iconAsset: .init(templateURL: "https://example.com/icon/{w}x{h}.{f}", width: 1024, height: 1024),
                iconType: .alternateExperiment,
                isMasked: true,
                name: "AppIconDark",
            ),
        )
        let icon = BuildIconAsset(schema: schema)

        #expect(icon.id == "icon-1")
        #expect(icon.name == "AppIconDark")
        #expect(icon.iconType == .alternateExperiment)
        #expect(icon.isAlternateExperiment)
        #expect(icon.isMasked)
        #expect(icon.image?.imageURL?.absoluteString == "https://example.com/icon/1024x1024.png")
    }
}
