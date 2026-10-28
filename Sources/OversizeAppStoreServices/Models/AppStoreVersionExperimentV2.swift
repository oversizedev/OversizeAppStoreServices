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
    public let treatments: [AppStoreVersionExperimentTreatment]

    public init(
        id: String,
        name: String? = nil,
        platform: Platform? = nil,
        trafficProportion: Int? = nil,
        state: State? = nil,
        isReviewRequired: Bool? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        relationships: Relationships? = nil,
        treatments: [AppStoreVersionExperimentTreatment] = [],
    ) {
        self.id = id
        self.name = name
        self.platform = platform
        self.trafficProportion = trafficProportion
        self.state = state
        self.isReviewRequired = isReviewRequired
        self.startDate = startDate
        self.endDate = endDate
        self.relationships = relationships
        self.treatments = treatments
    }

    public init?(schema: AppStoreAPI.AppStoreVersionExperimentV2) {
        self.init(schema: schema, includedTreatments: [:])
    }

    public init(
        schema: AppStoreAPI.AppStoreVersionExperimentV2,
        included: [AppStoreAPI.AppStoreVersionExperimentsV2Response.IncludedItem]?,
    ) {
        let treatments: [String: AppStoreVersionExperimentTreatment] = (included ?? []).reduce(into: [:]) { result, item in
            if case let .appStoreVersionExperimentTreatment(treatment) = item {
                result[treatment.id] = AppStoreVersionExperimentTreatment(schema: treatment)
            }
        }
        self.init(schema: schema, includedTreatments: treatments)
    }

    public init(
        schema: AppStoreAPI.AppStoreVersionExperimentV2,
        included: [AppStoreAPI.AppStoreVersionExperimentV2Response.IncludedItem]?,
    ) {
        let treatments: [String: AppStoreVersionExperimentTreatment] = (included ?? []).reduce(into: [:]) { result, item in
            if case let .appStoreVersionExperimentTreatment(treatment) = item {
                result[treatment.id] = AppStoreVersionExperimentTreatment(schema: treatment)
            }
        }
        self.init(schema: schema, includedTreatments: treatments)
    }

    private init(schema: AppStoreAPI.AppStoreVersionExperimentV2, includedTreatments: [String: AppStoreVersionExperimentTreatment]) {
        let relationships = Relationships(
            appId: schema.relationships?.app?.data?.id,
            latestControlVersionId: schema.relationships?.latestControlVersion?.data?.id,
            controlVersionIds: schema.relationships?.controlVersions?.data?.compactMap { $0.id },
            appStoreVersionExperimentTreatmentIds: schema.relationships?.appStoreVersionExperimentTreatments?.data?.compactMap { $0.id },
        )
        self.init(
            id: schema.id,
            name: schema.attributes?.name,
            platform: schema.attributes?.platform.flatMap { Platform(rawValue: $0.rawValue) },
            trafficProportion: schema.attributes?.trafficProportion,
            state: schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) },
            isReviewRequired: schema.attributes?.isReviewRequired,
            startDate: schema.attributes?.startDate,
            endDate: schema.attributes?.endDate,
            relationships: relationships,
            treatments: (relationships.appStoreVersionExperimentTreatmentIds ?? []).compactMap { includedTreatments[$0] },
        )
    }

    public struct Relationships: Sendable {
        public let appId: String?
        public let latestControlVersionId: String?
        public let controlVersionIds: [String]?
        public let appStoreVersionExperimentTreatmentIds: [String]?

        public init(
            appId: String? = nil,
            latestControlVersionId: String? = nil,
            controlVersionIds: [String]? = nil,
            appStoreVersionExperimentTreatmentIds: [String]? = nil,
        ) {
            self.appId = appId
            self.latestControlVersionId = latestControlVersionId
            self.controlVersionIds = controlVersionIds
            self.appStoreVersionExperimentTreatmentIds = appStoreVersionExperimentTreatmentIds
        }
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

        public var isEditable: Bool {
            self == .prepareForSubmission || self == .rejected
        }
    }
}
