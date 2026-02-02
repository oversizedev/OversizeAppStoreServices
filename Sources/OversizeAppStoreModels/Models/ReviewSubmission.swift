import AppStoreAPI
import Foundation

public struct ReviewSubmission: Sendable, Identifiable {
    public let id: String
    public let platform: Platform?
    public let submittedDate: Date?
    public let state: State?
    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.ReviewSubmission) {
        id = schema.id
        platform = schema.attributes?.platform.flatMap { Platform(rawValue: $0.rawValue) }
        submittedDate = schema.attributes?.submittedDate
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        relationships = .init(
            appId: schema.relationships?.app?.data?.id,
            itemIds: schema.relationships?.items?.data?.compactMap { $0.id },
            appStoreVersionForReviewId: schema.relationships?.appStoreVersionForReview?.data?.id,
            submittedByActorId: schema.relationships?.submittedByActor?.data?.id,
            lastUpdatedByActorId: schema.relationships?.lastUpdatedByActor?.data?.id,
        )
    }

    public struct Relationships: Sendable {
        public let appId: String?
        public let itemIds: [String]?
        public let appStoreVersionForReviewId: String?
        public let submittedByActorId: String?
        public let lastUpdatedByActorId: String?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case readyForReview = "READY_FOR_REVIEW"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case inReview = "IN_REVIEW"
        case unresolvedIssues = "UNRESOLVED_ISSUES"
        case canceling = "CANCELING"
        case completing = "COMPLETING"
        case complete = "COMPLETE"
    }
}
