//
// Copyright © 2026 Alexander Romanov
// AssetLibraryTests.swift, created on 23.10.2026
//

import AppStoreAPI
import Foundation
@testable import OversizeAppStoreServices
import Testing

struct AssetLibraryTests {
    @Test("Asset library enums should match AppStoreAPI")
    func enumsMatchGeneratedAPI() {
        #expect(Set(AssetLibraryDisplayClass.allCases.map(\.rawValue)) == Set(AppStoreAPI.AppAssetLibraryDisplayClass.allCases.map(\.rawValue)))
        #expect(Set(AssetLibraryPlacementPlatform.allCases.map(\.rawValue)) == Set(AppStoreAPI.AppAssetLibraryPlacementPlatform.allCases.map(\.rawValue)))
        #expect(Set(AssetLibraryAssetState.allCases.map(\.rawValue)) == Set(AppStoreAPI.AppAssetLibraryAssetState.allCases.map(\.rawValue)))
    }

    @Test("Ref data should join screenshot specs with placement groups")
    func refDataMapsScreenshotGroups() throws {
        let json = """
        {
          "type": "appAssetLibraryRefData",
          "id": "ref",
          "attributes": {
            "placementProfileGroups": [
              {"placementProfileGroupId": "ipad13", "platform": "IPAD_APP_STORE", "displayClassId": "IPAD_13_DISPLAY"},
              {"placementProfileGroupId": "phone63", "platform": "IPHONE_APP_STORE", "displayClassId": "IPHONE_DYNAMIC_ISLAND_MEDIUM_DISPLAY"}
            ],
            "imageSpecs": [
              {"specId": "s-ipad", "dimensions": {"minWidth": 2064, "maxWidth": 2064, "minHeight": 2752, "maxHeight": 2752}, "alphaAllowed": false},
              {"specId": "s-phone", "dimensions": {"minWidth": 1206, "maxWidth": 1206, "minHeight": 2622, "maxHeight": 2622}}
            ],
            "placementTypes": [
              {"placementTypeId": "APP_SCREENSHOT", "specMappings": [
                {"placementGroupId": "ipad13", "specs": ["s-ipad"]},
                {"placementGroupId": "phone63", "specs": ["s-phone"]}
              ]},
              {"placementTypeId": "APP_PREVIEW", "specMappings": [{"placementGroupId": "video", "specs": []}]}
            ]
          }
        }
        """
        let datum = try JSONDecoder().decode(AppStoreAPI.AppAssetLibraryRefDatum.self, from: Data(json.utf8))
        let refData = AssetLibraryRefData(schema: [datum])

        #expect(refData.screenshotGroups.map(\.id) == ["ipad13", "phone63"])
        let ipad = try #require(refData.group(id: "ipad13"))
        #expect(ipad.platform == .iPad)
        #expect(ipad.displayClass == .iPad13)
        #expect(ipad.preferredSize == .init(width: 2064, height: 2752))
        #expect(ipad.accepts(width: 2064, height: 2752))
        #expect(!ipad.accepts(width: 1206, height: 2622))
    }

    @Test("Build device families should be read from device protocols")
    func deviceFamilies() {
        #expect(BuildDeviceFamilies(deviceProtocols: ["iPhone-ipad-minimum-performance-a12"]).supportsiPad)
        #expect(!BuildDeviceFamilies(deviceProtocols: ["iphone-performance-gaming-tier"]).supportsiPad)
        #expect(!BuildDeviceFamilies(deviceProtocols: []).isRecognized)
    }
}
