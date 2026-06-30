import AppStoreAPI
import Foundation

public struct GameCenterActivityVersion: Sendable, Identifiable {
    public let id: String
    public let version: Int?
    public let state: State?
    public let fallbackUrl: String?
    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.GameCenterActivityVersion) {
        id = schema.id
        version = schema.attributes?.version
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        fallbackUrl = schema.attributes?.fallbackURL
        relationships = .init(
            activityId: schema.relationships?.activity?.data?.id,
            localizationIds: schema.relationships?.localizations?.data?.compactMap { $0.id },
            defaultImageId: schema.relationships?.defaultImage?.data?.id,
            releaseIds: schema.relationships?.releases?.data?.compactMap { $0.id },
        )
    }

    public struct Relationships: Sendable {
        public let activityId: String?
        public let localizationIds: [String]?
        public let defaultImageId: String?
        public let releaseIds: [String]?
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
