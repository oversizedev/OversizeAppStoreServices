import AppStoreAPI
import Foundation

public struct AppEvent: Sendable, Identifiable {
    public let id: String
    public let referenceName: String?
    public let badge: Badge?
    public let eventState: EventState?
    public let deepLink: URL?
    public let purchaseRequirement: String?
    public let primaryLocale: String?
    public let priority: Priority?
    public let purpose: Purpose?
    public let territorySchedules: [TerritorySchedule]?
    public let archivedTerritorySchedules: [ArchivedTerritorySchedule]?
    public let relationships: Relationships?

    public init?(schema: AppStoreAPI.AppEvent) {
        id = schema.id
        referenceName = schema.attributes?.referenceName
        badge = schema.attributes?.badge.flatMap { Badge(rawValue: $0.rawValue) }
        eventState = schema.attributes?.eventState.flatMap { EventState(rawValue: $0.rawValue) }
        deepLink = schema.attributes?.deepLink
        purchaseRequirement = schema.attributes?.purchaseRequirement
        primaryLocale = schema.attributes?.primaryLocale
        priority = schema.attributes?.priority.flatMap { Priority(rawValue: $0.rawValue) }
        purpose = schema.attributes?.purpose.flatMap { Purpose(rawValue: $0.rawValue) }
        territorySchedules = schema.attributes?.territorySchedules?.map { TerritorySchedule(schema: $0) }
        archivedTerritorySchedules = schema.attributes?.archivedTerritorySchedules?.map { ArchivedTerritorySchedule(schema: $0) }
        relationships = .init(
            appEventLocalizationIds: schema.relationships?.localizations?.data?.compactMap { $0.id },
        )
    }

    public struct Relationships: Sendable {
        public let appEventLocalizationIds: [String]?
    }

    public enum Badge: String, CaseIterable, Codable, Sendable {
        case liveEvent = "LIVE_EVENT"
        case premiere = "PREMIERE"
        case challenge = "CHALLENGE"
        case competition = "COMPETITION"
        case newSeason = "NEW_SEASON"
        case majorUpdate = "MAJOR_UPDATE"
        case specialEvent = "SPECIAL_EVENT"
    }

    public enum EventState: String, CaseIterable, Codable, Sendable {
        case draft = "DRAFT"
        case readyForReview = "READY_FOR_REVIEW"
        case waitingForReview = "WAITING_FOR_REVIEW"
        case inReview = "IN_REVIEW"
        case rejected = "REJECTED"
        case accepted = "ACCEPTED"
        case approved = "APPROVED"
        case published = "PUBLISHED"
        case past = "PAST"
        case archived = "ARCHIVED"
    }

    public enum Priority: String, CaseIterable, Codable, Sendable {
        case high = "HIGH"
        case normal = "NORMAL"
    }

    public enum Purpose: String, CaseIterable, Codable, Sendable {
        case appropriateForAllUsers = "APPROPRIATE_FOR_ALL_USERS"
        case attractNewUsers = "ATTRACT_NEW_USERS"
        case keepActiveUsersInformed = "KEEP_ACTIVE_USERS_INFORMED"
        case bringBackLapsedUsers = "BRING_BACK_LAPSED_USERS"
    }

    public struct TerritorySchedule: Sendable {
        public let territories: [String]?
        public let publishStart: Date?
        public let eventStart: Date?
        public let eventEnd: Date?

        public init(schema: AppStoreAPI.AppEvent.Attributes.TerritorySchedule) {
            territories = schema.territories
            publishStart = schema.publishStart
            eventStart = schema.eventStart
            eventEnd = schema.eventEnd
        }
    }

    public struct ArchivedTerritorySchedule: Sendable {
        public let territories: [String]?
        public let publishStart: Date?
        public let eventStart: Date?
        public let eventEnd: Date?

        public init(schema: AppStoreAPI.AppEvent.Attributes.ArchivedTerritorySchedule) {
            territories = schema.territories
            publishStart = schema.publishStart
            eventStart = schema.eventStart
            eventEnd = schema.eventEnd
        }
    }
}
