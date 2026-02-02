import AppStoreAPI
import Foundation

public struct BackgroundAssetVersion: Sendable, Identifiable {
    public let id: String
    public let createdDate: Date?
    public let platforms: [Platform]?
    public let state: State?
    public let version: String?
    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.BackgroundAssetVersion) {
        id = schema.id
        createdDate = schema.attributes?.createdDate
        platforms = schema.attributes?.platforms?.compactMap { Platform(rawValue: $0.rawValue) }
        state = schema.attributes?.state.flatMap { State(rawValue: $0.rawValue) }
        version = schema.attributes?.version
        relationships = .init(
            internalBetaReleaseId: schema.relationships?.internalBetaRelease?.data?.id,
            assetFileId: schema.relationships?.assetFile?.data?.id,
            manifestFileId: schema.relationships?.manifestFile?.data?.id,
        )
    }

    public struct Relationships: Sendable {
        public let internalBetaReleaseId: String?
        public let assetFileId: String?
        public let manifestFileId: String?
    }

    public enum State: String, CaseIterable, Codable, Sendable {
        case awaitingUpload = "AWAITING_UPLOAD"
        case processing = "PROCESSING"
        case failed = "FAILED"
        case complete = "COMPLETE"
    }
}
