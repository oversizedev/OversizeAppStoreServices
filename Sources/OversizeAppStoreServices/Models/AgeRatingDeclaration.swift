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
        
    }

}

/*
import AppStoreAPI
import AppStoreConnect
import Foundation

public struct AgeRatingDeclaration: Codable, Equatable, Identifiable, Sendable {
    public var type: `Type`
    public var id: String
    public var attributes: Attributes?
    public var links: ResourceLinks?

    public enum `Type`: String, CaseIterable, Codable, Sendable {
        case ageRatingDeclarations
    }

    public struct Attributes: Codable, Equatable, Sendable {
        public var alcoholTobaccoOrDrugUseOrReferences: AlcoholTobaccoOrDrugUseOrReferences?
        public var contests: Contests?
        public var isGamblingAndContests: Bool?
        public var isGambling: Bool?
        public var gamblingSimulated: GamblingSimulated?
        public var kidsAgeBand: KidsAgeBand?
        public var isLootBox: Bool?
        public var medicalOrTreatmentInformation: MedicalOrTreatmentInformation?
        public var profanityOrCrudeHumor: ProfanityOrCrudeHumor?
        public var sexualContentGraphicAndNudity: SexualContentGraphicAndNudity?
        public var sexualContentOrNudity: SexualContentOrNudity?
        public var horrorOrFearThemes: HorrorOrFearThemes?
        public var matureOrSuggestiveThemes: MatureOrSuggestiveThemes?
        public var isUnrestrictedWebAccess: Bool?
        public var violenceCartoonOrFantasy: ViolenceCartoonOrFantasy?
        public var violenceRealisticProlongedGraphicOrSadistic: ViolenceRealisticProlongedGraphicOrSadistic?
        public var violenceRealistic: ViolenceRealistic?
        public var ageRatingOverride: AgeRatingOverride?
        public var koreaAgeRatingOverride: KoreaAgeRatingOverride?
        public var isSeventeenPlus: Bool?

        public enum AlcoholTobaccoOrDrugUseOrReferences: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum Contests: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum GamblingSimulated: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum MedicalOrTreatmentInformation: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum ProfanityOrCrudeHumor: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum SexualContentGraphicAndNudity: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum SexualContentOrNudity: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum HorrorOrFearThemes: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum MatureOrSuggestiveThemes: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum ViolenceCartoonOrFantasy: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum ViolenceRealisticProlongedGraphicOrSadistic: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum ViolenceRealistic: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case infrequentOrMild = "INFREQUENT_OR_MILD"
            case frequentOrIntense = "FREQUENT_OR_INTENSE"
        }

        public enum AgeRatingOverride: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case seventeenPlus = "SEVENTEEN_PLUS"
            case unrated = "UNRATED"
        }

        public enum KoreaAgeRatingOverride: String, CaseIterable, Codable, Sendable {
            case `none` = "NONE"
            case fifteenPlus = "FIFTEEN_PLUS"
            case nineteenPlus = "NINETEEN_PLUS"
        }

        public init(alcoholTobaccoOrDrugUseOrReferences: AlcoholTobaccoOrDrugUseOrReferences? = nil, contests: Contests? = nil, isGamblingAndContests: Bool? = nil, isGambling: Bool? = nil, gamblingSimulated: GamblingSimulated? = nil, kidsAgeBand: KidsAgeBand? = nil, isLootBox: Bool? = nil, medicalOrTreatmentInformation: MedicalOrTreatmentInformation? = nil, profanityOrCrudeHumor: ProfanityOrCrudeHumor? = nil, sexualContentGraphicAndNudity: SexualContentGraphicAndNudity? = nil, sexualContentOrNudity: SexualContentOrNudity? = nil, horrorOrFearThemes: HorrorOrFearThemes? = nil, matureOrSuggestiveThemes: MatureOrSuggestiveThemes? = nil, isUnrestrictedWebAccess: Bool? = nil, violenceCartoonOrFantasy: ViolenceCartoonOrFantasy? = nil, violenceRealisticProlongedGraphicOrSadistic: ViolenceRealisticProlongedGraphicOrSadistic? = nil, violenceRealistic: ViolenceRealistic? = nil, ageRatingOverride: AgeRatingOverride? = nil, koreaAgeRatingOverride: KoreaAgeRatingOverride? = nil, isSeventeenPlus: Bool? = nil) {
            self.alcoholTobaccoOrDrugUseOrReferences = alcoholTobaccoOrDrugUseOrReferences
            self.contests = contests
            self.isGamblingAndContests = isGamblingAndContests
            self.isGambling = isGambling
            self.gamblingSimulated = gamblingSimulated
            self.kidsAgeBand = kidsAgeBand
            self.isLootBox = isLootBox
            self.medicalOrTreatmentInformation = medicalOrTreatmentInformation
            self.profanityOrCrudeHumor = profanityOrCrudeHumor
            self.sexualContentGraphicAndNudity = sexualContentGraphicAndNudity
            self.sexualContentOrNudity = sexualContentOrNudity
            self.horrorOrFearThemes = horrorOrFearThemes
            self.matureOrSuggestiveThemes = matureOrSuggestiveThemes
            self.isUnrestrictedWebAccess = isUnrestrictedWebAccess
            self.violenceCartoonOrFantasy = violenceCartoonOrFantasy
            self.violenceRealisticProlongedGraphicOrSadistic = violenceRealisticProlongedGraphicOrSadistic
            self.violenceRealistic = violenceRealistic
            self.ageRatingOverride = ageRatingOverride
            self.koreaAgeRatingOverride = koreaAgeRatingOverride
            self.isSeventeenPlus = isSeventeenPlus
        }

        private enum CodingKeys: String, CodingKey {
            case alcoholTobaccoOrDrugUseOrReferences
            case contests
            case isGamblingAndContests = "gamblingAndContests"
            case isGambling = "gambling"
            case gamblingSimulated
            case kidsAgeBand
            case isLootBox = "lootBox"
            case medicalOrTreatmentInformation
            case profanityOrCrudeHumor
            case sexualContentGraphicAndNudity
            case sexualContentOrNudity
            case horrorOrFearThemes
            case matureOrSuggestiveThemes
            case isUnrestrictedWebAccess = "unrestrictedWebAccess"
            case violenceCartoonOrFantasy
            case violenceRealisticProlongedGraphicOrSadistic
            case violenceRealistic
            case ageRatingOverride
            case koreaAgeRatingOverride
            case isSeventeenPlus = "seventeenPlus"
        }
    }

    public init(type: `Type` = .ageRatingDeclarations, id: String, attributes: Attributes? = nil, links: ResourceLinks? = nil) {
        self.type = type
        self.id = id
        self.attributes = attributes
        self.links = links
    }
}
*/
