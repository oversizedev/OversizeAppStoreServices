//
// Copyright © 2024 Alexander Romanov
// AppInfo.swift, created on 23.07.2024
//

import AppStoreAPI

import OversizeCore

public struct AppInfo: Sendable {
    public let id: String

    public var appStoreState: AppStoreVersionState?
    public var state: State?
    public let appStoreAgeRating: AppStoreAgeRating?
    public let australiaAgeRating: AustraliaAgeRating?
    public let brazilAgeRating: BrazilAgeRating?
    public let brazilAgeRatingV2: BrazilAgeRatingV2?
    public let koreaAgeRating: KoreaAgeRating?
    public let kidsAgeBand: KidsAgeBand?

    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.AppInfo, included: [AppInfosResponse.IncludedItem]? = []) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        appStoreState = attributes.appStoreState.flatMap { .init(rawValue: $0.rawValue) }
        state = attributes.state.flatMap { .init(rawValue: $0.rawValue) }
        appStoreAgeRating = attributes.appStoreAgeRating.flatMap { AppStoreAgeRating(rawValue: $0.rawValue) }
        australiaAgeRating = attributes.australiaAgeRating.flatMap { AustraliaAgeRating(rawValue: $0.rawValue) }
        brazilAgeRating = attributes.brazilAgeRating.flatMap { BrazilAgeRating(rawValue: $0.rawValue) }
        brazilAgeRatingV2 = attributes.brazilAgeRatingV2.flatMap { BrazilAgeRatingV2(rawValue: $0.rawValue) }
        koreaAgeRating = attributes.koreaAgeRating.flatMap { KoreaAgeRating(rawValue: $0.rawValue) }
        kidsAgeBand = attributes.kidsAgeBand.flatMap { KidsAgeBand(rawValue: $0.rawValue) }

        relationships = .init(
            primaryCategoryId: schema.relationships?.primaryCategory?.data?.id,
            secondaryCategoryId: schema.relationships?.secondaryCategory?.data?.id,
            ageRatingDeclarationId: schema.relationships?.ageRatingDeclaration?.data?.id
        )

        var appCategories: [AppStoreAPI.AppCategory] = []
        var ageRatingDeclarations: [AppStoreAPI.AgeRatingDeclaration] = []

        if let includedItems = included {
            for includedItem in includedItems {
                switch includedItem {
                case let .appCategory(appCategory):
                    appCategories.append(appCategory)
                case let .ageRatingDeclaration(ageRatingDeclaration):
                    ageRatingDeclarations.append(ageRatingDeclaration)
                default:
                    continue
                }
            }

            let primaryCategory: AppStoreAPI.AppCategory? = appCategories
                .first {
                    $0.id == schema.relationships?.primaryCategory?.data?.id
                }
            let seconaryCategory: AppStoreAPI.AppCategory? = appCategories
                .first {
                    $0.id == schema.relationships?.secondaryCategory?.data?.id
                }
            let ageRatingDeclaration: AppStoreAPI.AgeRatingDeclaration? = ageRatingDeclarations
                .first {
                    $0.id == schema.relationships?.ageRatingDeclaration?.data?.id
                }
            if let primaryCategory, let seconaryCategory {
                self.included = .init(
                    primaryCategory: .init(schema: primaryCategory),
                    secondaryCategory: .init(schema: seconaryCategory),
                    ageRatingDeclaration: ageRatingDeclaration != nil ? .init(schema: ageRatingDeclaration!) : nil
                )
            } else {
                self.included = nil
            }
        } else {
            self.included = nil
        }
    }

    public struct Relationships: Sendable {
        public let primaryCategoryId: String?
        public let secondaryCategoryId: String?
        public let ageRatingDeclarationId: String?
    }

    public struct Included: Sendable {
        public let primaryCategory: AppCategory?
        public let secondaryCategory: AppCategory?
        public let ageRatingDeclaration: AgeRatingDeclaration?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case accepted = "ACCEPTED"
        case developerRejected = "DEVELOPER_REJECTED"
        case inReview = "IN_REVIEW"
        case pendingRelease = "PENDING_RELEASE"
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case readyForDistribution = "READY_FOR_DISTRIBUTION"
        case readyForReview = "READY_FOR_REVIEW"
        case rejected = "REJECTED"
        case replacedWithNewInfo = "REPLACED_WITH_NEW_INFO"
        case waitingForReview = "WAITING_FOR_REVIEW"
    }
}
