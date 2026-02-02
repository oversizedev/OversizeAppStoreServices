import AppStoreAPI

public struct GameCenterLeaderboardSetVersionV2: Sendable, Identifiable {
    public let id: String
    public let version: Int?
    public let state: State?
    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.GameCenterLeaderboardSetVersionV2) {
        id = schema.id
        version = schema.attributes?.version
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        relationships = .init(
            leaderboardSetId: schema.relationships?.leaderboardSet?.data?.id,
            localizationIds: schema.relationships?.localizations?.data?.compactMap { $0.id },
        )
    }

    public struct Relationships: Sendable {
        public let leaderboardSetId: String?
        public let localizationIds: [String]?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case readyForReview = "READY_FOR_REVIEW"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case inReview = "IN_REVIEW"
        case rejected = "REJECTED"
        case accepted = "ACCEPTED"
        case pendingRelease = "PENDING_RELEASE"
        case live = "LIVE"
        case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
    }
}
