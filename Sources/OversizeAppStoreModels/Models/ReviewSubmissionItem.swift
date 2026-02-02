import AppStoreAPI
import Foundation

public struct ReviewSubmissionItem: Sendable, Identifiable {
    public let id: String
    public let state: State?
    public let relationships: Relationships?

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
    }

    public struct Relationships: Sendable {
        public let appStoreVersionId: String?
        public let appCustomProductPageVersionId: String?
        public let appStoreVersionExperimentId: String?
        public let appStoreVersionExperimentV2Id: String?
        public let appEventId: String?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case readyForReview = "READY_FOR_REVIEW"
        case accepted = "ACCEPTED"
        case approved = "APPROVED"
        case rejected = "REJECTED"
        case removed = "REMOVED"
    }
}
