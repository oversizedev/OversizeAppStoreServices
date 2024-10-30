//
// Copyright © 2024 Alexander Romanov
// AppInfo.swift, created on 23.07.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeCore

public struct AppInfo: Sendable {
    public let id: String
    
    public let appStoreAgeRating: AppStoreAgeRating
    public let australiaAgeRating: AustraliaAgeRating
    public let brazilAgeRating: BrazilAgeRating
    public let brazilAgeRatingV2: BrazilAgeRatingV2
    public let koreaAgeRating: KoreaAgeRating
    public let kidsAgeBand: KidsAgeBand

    public let relationships: Relationships?
    
    public init?(schema: AppStoreAPI.AppInfo) {
        guard let appStoreAgeRatingRaw = schema.attributes?.appStoreAgeRating?.rawValue,
              let appStoreAgeRating = AppStoreAgeRating(rawValue: appStoreAgeRatingRaw),
              let australiaAgeRatingRaw = schema.attributes?.australiaAgeRating?.rawValue,
              let australiaAgeRating = AustraliaAgeRating(rawValue: australiaAgeRatingRaw),
              let brazilAgeRatingRaw = schema.attributes?.brazilAgeRating?.rawValue,
              let brazilAgeRating = BrazilAgeRating(rawValue: brazilAgeRatingRaw),
              let brazilAgeRatingV2Raw = schema.attributes?.brazilAgeRatingV2?.rawValue,
              let brazilAgeRatingV2 = BrazilAgeRatingV2(rawValue: brazilAgeRatingV2Raw),
              let koreaAgeRatingRaw = schema.attributes?.koreaAgeRating?.rawValue,
              let koreaAgeRating = KoreaAgeRating(rawValue: koreaAgeRatingRaw),
              let kidsAgeBandRaw = schema.attributes?.kidsAgeBand?.rawValue,
              let kidsAgeBand = KidsAgeBand(rawValue: kidsAgeBandRaw) else {
            return nil
        }
        
        self.id = schema.id
        self.appStoreAgeRating = appStoreAgeRating
        self.australiaAgeRating = australiaAgeRating
        self.brazilAgeRating = brazilAgeRating
        self.brazilAgeRatingV2 = brazilAgeRatingV2
        self.koreaAgeRating = koreaAgeRating
        self.kidsAgeBand = kidsAgeBand
        
        self.relationships = Relationships(
            primaryCategoryId: schema.relationships?.primaryCategory?.data?.id,
            secondaryCategoryId: schema.relationships?.secondaryCategory?.data?.id
        )
    }
    
    public struct Relationships: Sendable {
        
        public let primaryCategoryId: String?
        public let secondaryCategoryId: String?
        public var primaryCategory: String {
            return primaryCategoryId?.capitalizingFirstLetter() ?? ""
        }
    }
}
