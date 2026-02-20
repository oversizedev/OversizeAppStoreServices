import AppStoreAPI
import Foundation

public struct ReviewSubmissionItem: Sendable, Identifiable {
    public let id: String
    public let state: State?
    public let relationships: Relationships?
    public let included: Included?

    public init?(schema: AppStoreAPI.ReviewSubmissionItem) {
        id = schema.id
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        relationships = .init(
            appStoreVersionId: schema.relationships?.appStoreVersion?.data?.id,
            appCustomProductPageVersionId: schema.relationships?.appCustomProductPageVersion?.data?.id,
            appStoreVersionExperimentId: schema.relationships?.appStoreVersionExperiment?.data?.id,
            appStoreVersionExperimentV2Id: schema.relationships?.appStoreVersionExperimentV2?.data?.id,
            appEventId: schema.relationships?.appEvent?.data?.id,
        )
        included = nil
    }

    public init?(
        schema: AppStoreAPI.ReviewSubmissionItem,
        included: [AppStoreAPI.ReviewSubmissionItemsResponse.IncludedItem]?,
    ) {
        id = schema.id
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        relationships = .init(
            appStoreVersionId: schema.relationships?.appStoreVersion?.data?.id,
            appCustomProductPageVersionId: schema.relationships?.appCustomProductPageVersion?.data?.id,
            appStoreVersionExperimentId: schema.relationships?.appStoreVersionExperiment?.data?.id,
            appStoreVersionExperimentV2Id: schema.relationships?.appStoreVersionExperimentV2?.data?.id,
            appEventId: schema.relationships?.appEvent?.data?.id,
        )

        var appStoreVersion: AppStoreVersion?
        var appCustomProductPageVersion: AppCustomProductPageVersion?
        var appStoreVersionExperiment: AppStoreVersionExperiment?
        var appEvent: AppEvent?
        var backgroundAssetVersion: BackgroundAssetVersion?
        var gameCenterAchievementVersionV2: GameCenterAchievementVersionV2?
        var gameCenterActivityVersion: GameCenterActivityVersion?
        var gameCenterChallengeVersion: GameCenterChallengeVersion?
        var gameCenterLeaderboardSetVersionV2: GameCenterLeaderboardSetVersionV2?
        var gameCenterLeaderboardVersionV2: GameCenterLeaderboardVersionV2?

        if let includedItems = included {
            for includedItem in includedItems {
                switch includedItem {
                case let .appStoreVersion(value):
                    if schema.relationships?.appStoreVersion?.data?.id == value.id {
                        appStoreVersion = .init(schema: value)
                    }
                case let .appCustomProductPageVersion(value):
                    if schema.relationships?.appCustomProductPageVersion?.data?.id == value.id {
                        appCustomProductPageVersion = .init(schema: value)
                    }
                case let .appStoreVersionExperiment(value):
                    if schema.relationships?.appStoreVersionExperiment?.data?.id == value.id {
                        appStoreVersionExperiment = .init(schema: value)
                    }
                case let .appEvent(value):
                    if schema.relationships?.appEvent?.data?.id == value.id {
                        appEvent = .init(schema: value)
                    }
                case let .backgroundAssetVersion(value):
                    if backgroundAssetVersion == nil {
                        backgroundAssetVersion = .init(schema: value)
                    }
                case let .gameCenterAchievementVersionV2(value):
                    if gameCenterAchievementVersionV2 == nil {
                        gameCenterAchievementVersionV2 = .init(schema: value)
                    }
                case let .gameCenterActivityVersion(value):
                    if gameCenterActivityVersion == nil {
                        gameCenterActivityVersion = .init(schema: value)
                    }
                case let .gameCenterChallengeVersion(value):
                    if gameCenterChallengeVersion == nil {
                        gameCenterChallengeVersion = .init(schema: value)
                    }
                case let .gameCenterLeaderboardSetVersionV2(value):
                    if gameCenterLeaderboardSetVersionV2 == nil {
                        gameCenterLeaderboardSetVersionV2 = .init(schema: value)
                    }
                case let .gameCenterLeaderboardVersionV2(value):
                    if gameCenterLeaderboardVersionV2 == nil {
                        gameCenterLeaderboardVersionV2 = .init(schema: value)
                    }
                @unknown default:
                    break
                }
            }
        }
        self.included = .init(
            appStoreVersion: appStoreVersion,
            appCustomProductPageVersion: appCustomProductPageVersion,
            appStoreVersionExperiment: appStoreVersionExperiment,
            appEvent: appEvent,
            backgroundAssetVersion: backgroundAssetVersion,
            gameCenterAchievementVersionV2: gameCenterAchievementVersionV2,
            gameCenterActivityVersion: gameCenterActivityVersion,
            gameCenterChallengeVersion: gameCenterChallengeVersion,
            gameCenterLeaderboardSetVersionV2: gameCenterLeaderboardSetVersionV2,
            gameCenterLeaderboardVersionV2: gameCenterLeaderboardVersionV2,
        )
    }

    public struct Relationships: Sendable {
        public let appStoreVersionId: String?
        public let appCustomProductPageVersionId: String?
        public let appStoreVersionExperimentId: String?
        public let appStoreVersionExperimentV2Id: String?
        public let appEventId: String?
    }

    public struct Included: Sendable {
        public let appStoreVersion: AppStoreVersion?
        public let appCustomProductPageVersion: AppCustomProductPageVersion?
        public let appStoreVersionExperiment: AppStoreVersionExperiment?
        public let appEvent: AppEvent?
        public let backgroundAssetVersion: BackgroundAssetVersion?
        public let gameCenterAchievementVersionV2: GameCenterAchievementVersionV2?
        public let gameCenterActivityVersion: GameCenterActivityVersion?
        public let gameCenterChallengeVersion: GameCenterChallengeVersion?
        public let gameCenterLeaderboardSetVersionV2: GameCenterLeaderboardSetVersionV2?
        public let gameCenterLeaderboardVersionV2: GameCenterLeaderboardVersionV2?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case readyForReview = "READY_FOR_REVIEW"
        case accepted = "ACCEPTED"
        case approved = "APPROVED"
        case rejected = "REJECTED"
        case removed = "REMOVED"
    }
}
