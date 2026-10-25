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
        #expect(Set(AssetLibraryPlacementType.allCases.map(\.rawValue)) == Set(AppStoreAPI.AppAssetLibraryPlacementType.allCases.map(\.rawValue)))
        #expect(Set(AssetLibraryAssetCategory.allCases.map(\.rawValue)) == Set(AppStoreAPI.AppAssetLibraryAssetCategory.allCases.map(\.rawValue)))
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

    @Test("Ref data should map header and search results creatives by placement type")
    func refDataMapsCreatives() throws {
        let json = """
        {
          "type": "appAssetLibraryRefData",
          "id": "ref",
          "attributes": {
            "imageSpecs": [
              {"specId": "s-header", "aspectRatio": "21:9", "dimensions": {"minWidth": 3840, "maxWidth": 3840, "minHeight": 1646, "maxHeight": 1646},
               "alphaAllowed": false, "mimeTypes": ["image/png"], "universalAsset": false,
               "compatiblePlacementTypes": ["PRODUCT_PAGE_HEADER_ASSET"]},
              {"specId": "s-search", "aspectRatio": "3:2", "dimensions": {"minWidth": 1920, "maxWidth": 1920, "minHeight": 1280, "maxHeight": 1280},
               "universalAsset": true, "compatiblePlacementTypes": ["APP_STORE_SEARCH_RESULTS_ASSET"]}
            ],
            "placementTypes": [
              {"placementTypeId": "PRODUCT_PAGE_HEADER_ASSET", "acceptsAssetCategories": ["CREATIVE_ASSETS"],
               "specMappings": [{"placementGroupId": "header-group", "specs": ["s-header"]}]},
              {"placementTypeId": "APP_STORE_SEARCH_RESULTS_ASSET", "acceptsAssetCategories": ["CREATIVE_ASSETS"],
               "specMappings": [{"placementGroupId": "search-group", "specs": ["s-search"]}]},
              {"placementTypeId": "APP_SCREENSHOT", "acceptsAssetCategories": ["APP_SCREENSHOTS_AND_PREVIEWS"],
               "specMappings": [{"placementGroupId": "phone", "specs": []}]}
            ]
          }
        }
        """
        let datum = try JSONDecoder().decode(AppStoreAPI.AppAssetLibraryRefDatum.self, from: Data(json.utf8))

        let header = AssetLibraryRefData(schema: [datum], placementType: .productPageHeaderAsset)
        #expect(header.groups.map(\.id) == ["header-group"])
        #expect(header.acceptedCategories == [.creativeAssets])
        #expect(header.uploadCategory == .creativeAssets)
        let headerSpec = try #require(header.groups.first?.specs.first)
        #expect(headerSpec.mimeTypes == ["image/png"])
        #expect(headerSpec.compatiblePlacementTypes == [.productPageHeaderAsset])
        #expect(!headerSpec.isAlphaAllowed)
        #expect(header.groups.first?.accepts(width: 3840, height: 1646) == true)
        #expect(header.groups.first?.accepts(width: 1920, height: 1280) == false)

        let search = AssetLibraryRefData(schema: [datum], placementType: .appStoreSearchResultsAsset)
        #expect(search.groups.map(\.id) == ["search-group"])
        #expect(search.groups.first?.specs.first?.isUniversalAsset == true)
        #expect(search.groups.first?.preferredSize == .init(width: 1920, height: 1280))

        let screenshots = AssetLibraryRefData(schema: [datum])
        #expect(screenshots.screenshotGroups.map(\.id) == ["phone"])
        #expect(screenshots.uploadCategory == .appScreenshotsAndPreviews)
    }

    @Test("Upload category should fall back to the placement type when ref data is empty")
    func uploadCategoryFallback() {
        #expect(AssetLibraryRefData(placementType: .productPageHeaderAsset, groups: []).uploadCategory == .creativeAssets)
        #expect(AssetLibraryRefData(placementType: .appScreenshot, groups: []).uploadCategory == .appScreenshotsAndPreviews)
    }

    @Test("Placement should carry its placement type")
    func placementType() throws {
        let json = """
        {"type": "appAssetLibraryPlacements", "id": "p1", "attributes": {"mediaType": "IMAGE", "placementType": "PRODUCT_PAGE_HEADER_ASSET", "placementGroup": "g"}}
        """
        let schema = try JSONDecoder().decode(AppStoreAPI.AppAssetLibraryPlacement.self, from: Data(json.utf8))
        let placement = AssetLibraryPlacement(schema: schema)
        #expect(placement.placementType == .productPageHeaderAsset)
        #expect(placement.placementGroup == "g")
    }

    @Test("Mock service should list placements for the requested type")
    func mockPlacements() async throws {
        let service: any AppAssetLibraryServicesProtocol = MockAppAssetLibraryService()
        let placements = try await service.fetchPlacements(localizationId: "loc", placementType: .appStoreSearchResultsAsset).get()
        #expect(!placements.isEmpty)
        #expect(placements.allSatisfy { $0.placementType == .appStoreSearchResultsAsset })
    }

    @Test("Build device families should be read from device protocols")
    func deviceFamilies() {
        #expect(BuildDeviceFamilies(deviceProtocols: ["iPhone-ipad-minimum-performance-a12"]).supportsiPad)
        #expect(!BuildDeviceFamilies(deviceProtocols: ["iphone-performance-gaming-tier"]).supportsiPad)
        #expect(!BuildDeviceFamilies(deviceProtocols: []).isRecognized)
    }
}
