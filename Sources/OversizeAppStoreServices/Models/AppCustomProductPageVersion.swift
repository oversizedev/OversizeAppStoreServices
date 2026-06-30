import AppStoreAPI
import Foundation

public struct AppCustomProductPageVersion: Sendable, Identifiable {
    public let id: String
    public let version: String?
    public let state: State?
    public let deepLink: URL?
    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.AppCustomProductPageVersion) {
        id = schema.id
        version = schema.attributes?.version
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        deepLink = schema.attributes?.deepLink
        relationships = .init(
            appCustomProductPageId: schema.relationships?.appCustomProductPage?.data?.id,
            appCustomProductPageLocalizationIds: schema.relationships?.appCustomProductPageLocalizations?.data?.compactMap { $0.id },
        )
    }

    public struct Relationships: Sendable {
        public let appCustomProductPageId: String?
        public let appCustomProductPageLocalizationIds: [String]?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case readyForReview = "READY_FOR_REVIEW"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case inReview = "IN_REVIEW"
        case accepted = "ACCEPTED"
        case approved = "APPROVED"
        case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
        case rejected = "REJECTED"
    }
}
