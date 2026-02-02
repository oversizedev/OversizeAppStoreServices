import AppStoreAPI
import Foundation

public struct ReviewSubmission: Sendable, Identifiable {
    public let id: String
    public let platform: Platform?
    public let submittedDate: Date?
    public let state: State?
    public let relationships: Relationships?
    
    public let included: Included?

    public init?(schema: AppStoreAPI.ReviewSubmission, included: [AppStoreAPI.ReviewSubmissionsResponse.IncludedItem]? = nil) {
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

        if let includedItems = included {
            var app: App?
            var appStoreVersionForReview: AppStoreVersion?
            var reviewSubmissionItems: [ReviewSubmissionItem] = []
            var submittedByActor: Actor?
            var lastUpdatedByActor: Actor?

            for includedItem in includedItems {
                switch includedItem {
                case let .app(value):
                    if schema.relationships?.app?.data?.id == value.id {
                        app = .init(schema: value)
                    }
                case let .reviewSubmissionItem(value):
                    if schema.relationships?.items?.data?.first(where: { $0.id == value.id }) != nil,
                       let item = ReviewSubmissionItem(schema: value, included: nil) {
                        reviewSubmissionItems.append(item)
                    }
                case let .appStoreVersion(value):
                    if schema.relationships?.appStoreVersionForReview?.data?.id == value.id {
                        appStoreVersionForReview = .init(schema: value)
                    }
                case let .actor(value):
                    if schema.relationships?.submittedByActor?.data?.id == value.id {
                        submittedByActor = .init(schema: value)
                    }
                    if schema.relationships?.lastUpdatedByActor?.data?.id == value.id {
                        lastUpdatedByActor = .init(schema: value)
                    }
                }
            }

            self.included = .init(
                app: app,
                appStoreVersionForReview: appStoreVersionForReview,
                reviewSubmissionItems: reviewSubmissionItems.isEmpty ? nil : reviewSubmissionItems,
                submittedByActor: submittedByActor,
                lastUpdatedByActor: lastUpdatedByActor,
            )
        } else {
            self.included = nil
        }
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
    
    public struct Included: Sendable {
        public let app: App?
        public let appStoreVersionForReview: AppStoreVersion?
        public let reviewSubmissionItems: [ReviewSubmissionItem]?
        public let submittedByActor: Actor?
        public let lastUpdatedByActor: Actor?
    }
}
