//
// Copyright © 2024 Alexander Romanov
// AppStoreAgeRating.swift, created on 30.10.2024
//

import Foundation

public enum AppStoreAgeRating: String, CaseIterable, Codable, Sendable {
    case fourPlus = "FOUR_PLUS"
    case ninePlus = "NINE_PLUS"
    case twelvePlus = "TWELVE_PLUS"
    case seventeenPlus = "SEVENTEEN_PLUS"
    case unrated = "UNRATED"
}

public enum KidsAgeBand: String, CaseIterable, Codable, Sendable {
    case fiveAndUnder = "FIVE_AND_UNDER"
    case sixToEight = "SIX_TO_EIGHT"
    case nineToEleven = "NINE_TO_ELEVEN"
}

public enum AustraliaAgeRating: String, CaseIterable, Codable, Sendable {
    case fifteen = "FIFTEEN"
    case eighteen = "EIGHTEEN"
}

public enum BrazilAgeRatingV2: String, CaseIterable, Codable, Sendable {
    case selfRatedL = "SELF_RATED_L"
    case selfRatedTen = "SELF_RATED_TEN"
    case selfRatedTwelve = "SELF_RATED_TWELVE"
    case selfRatedFourteen = "SELF_RATED_FOURTEEN"
    case selfRatedSixteen = "SELF_RATED_SIXTEEN"
    case selfRatedEighteen = "SELF_RATED_EIGHTEEN"
    case officialL = "OFFICIAL_L"
    case officialTen = "OFFICIAL_TEN"
    case officialTwelve = "OFFICIAL_TWELVE"
    case officialFourteen = "OFFICIAL_FOURTEEN"
    case officialSixteen = "OFFICIAL_SIXTEEN"
    case officialEighteen = "OFFICIAL_EIGHTEEN"
}

public enum KoreaAgeRating: String, CaseIterable, Codable, Sendable {
    case all = "ALL"
    case twelve = "TWELVE"
    case fifteen = "FIFTEEN"
    case nineteen = "NINETEEN"
    case notApplicable = "NOT_APPLICABLE"
}
