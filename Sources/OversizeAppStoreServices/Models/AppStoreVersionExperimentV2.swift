import AppStoreAPI
import Foundation

public struct AppStoreVersionExperimentV2: Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let platform: Platform?
    public let trafficProportion: Int?
    public let state: State?
    public let isReviewRequired: Bool?
    public let startDate: Date?
    public let endDate: Date?
    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.AppStoreVersionExperimentV2) {
        id = schema.id
        name = schema.attributes?.name
        platform = schema.attributes?.platform.flatMap { Platform(rawValue: $0.rawValue) }
        trafficProportion = schema.attributes?.trafficProportion
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        isReviewRequired = schema.attributes?.isReviewRequired
        startDate = schema.attributes?.startDate
        endDate = schema.attributes?.endDate
        relationships = .init(
            appId: schema.relationships?.app?.data?.id,
            latestControlVersionId: schema.relationships?.latestControlVersion?.data?.id,
            controlVersionIds: schema.relationships?.controlVersions?.data?.compactMap { $0.id },
            appStoreVersionExperimentTreatmentIds: schema.relationships?.appStoreVersionExperimentTreatments?.data?.compactMap { $0.id },
        )
    }

    public struct Relationships: Sendable {
        public let appId: String?
        public let latestControlVersionId: String?
        public let controlVersionIds: [String]?
        public let appStoreVersionExperimentTreatmentIds: [String]?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case readyForReview = "READY_FOR_REVIEW"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case inReview = "IN_REVIEW"
        case accepted = "ACCEPTED"
        case approved = "APPROVED"
        case rejected = "REJECTED"
        case completed = "COMPLETED"
        case stopped = "STOPPED"
    }
}
