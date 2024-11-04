//
// Copyright © 2024 Alexander Romanov
// AgeRatingDeclaration.swift, created on 04.11.2024
//

import AppStoreAPI
import AppStoreConnect
import OversizeCore

public struct AgeRatingDeclaration: Sendable {
    public let id: String

    public var alcoholTobaccoOrDrugUseOrReferences: AppStoreAgeRatingDeclaration?
    public var contests: AppStoreAgeRatingDeclaration?
    public var isGamblingAndContests: Bool?
    public var isGambling: Bool?
    public var gamblingSimulated: AppStoreAgeRatingDeclaration?
    public var kidsAgeBand: KidsAgeBand?
    public var isLootBox: Bool?
    public var medicalOrTreatmentInformation: AppStoreAgeRatingDeclaration?
    public var profanityOrCrudeHumor: AppStoreAgeRatingDeclaration?
    public var sexualContentGraphicAndNudity: AppStoreAgeRatingDeclaration?
    public var sexualContentOrNudity: AppStoreAgeRatingDeclaration?
    public var horrorOrFearThemes: AppStoreAgeRatingDeclaration?
    public var matureOrSuggestiveThemes: AppStoreAgeRatingDeclaration?
    public var isUnrestrictedWebAccess: Bool?
    public var violenceCartoonOrFantasy: AppStoreAgeRatingDeclaration?
    public var violenceRealisticProlongedGraphicOrSadistic: AppStoreAgeRatingDeclaration?
    public var violenceRealistic: AppStoreAgeRatingDeclaration?
    public var ageRatingOverride: AgeRatingOverride?
    public var koreaAgeRatingOverride: KoreaAgeRatingOverride?
    public var isSeventeenPlus: Bool?

    public init?(schema: AppStoreAPI.AgeRatingDeclaration) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        alcoholTobaccoOrDrugUseOrReferences = attributes.alcoholTobaccoOrDrugUseOrReferences.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        contests = attributes.contests.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        isGamblingAndContests = attributes.isGamblingAndContests
        isGambling = attributes.isGambling
        gamblingSimulated = attributes.gamblingSimulated.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        kidsAgeBand = attributes.kidsAgeBand.flatMap { KidsAgeBand(rawValue: $0.rawValue) }
        isLootBox = attributes.isLootBox
        medicalOrTreatmentInformation = attributes.medicalOrTreatmentInformation.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        profanityOrCrudeHumor = attributes.profanityOrCrudeHumor.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        sexualContentGraphicAndNudity = attributes.sexualContentGraphicAndNudity.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        sexualContentOrNudity = attributes.sexualContentOrNudity.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        horrorOrFearThemes = attributes.horrorOrFearThemes.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        matureOrSuggestiveThemes = attributes.matureOrSuggestiveThemes.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        isUnrestrictedWebAccess = attributes.isUnrestrictedWebAccess
        violenceCartoonOrFantasy = attributes.violenceCartoonOrFantasy.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        violenceRealisticProlongedGraphicOrSadistic = attributes.violenceRealisticProlongedGraphicOrSadistic.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        violenceRealistic = attributes.violenceRealistic.flatMap { AppStoreAgeRatingDeclaration(rawValue: $0.rawValue) }
        ageRatingOverride = attributes.ageRatingOverride.flatMap { AgeRatingOverride(rawValue: $0.rawValue) }
        koreaAgeRatingOverride = attributes.koreaAgeRatingOverride.flatMap { KoreaAgeRatingOverride(rawValue: $0.rawValue) }
        isSeventeenPlus = attributes.isSeventeenPlus
    }
}
