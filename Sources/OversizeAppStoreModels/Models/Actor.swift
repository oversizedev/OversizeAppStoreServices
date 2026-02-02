import AppStoreAPI

public struct Actor: Sendable, Identifiable {
    public let id: String
    public let actorType: ActorType?
    public let userFirstName: String?
    public let userLastName: String?
    public let userEmail: String?
    public let apiKeyId: String?

    public init?(schema: AppStoreAPI.Actor) {
        id = schema.id
        actorType = schema.attributes?.actorType.flatMap { ActorType(rawValue: $0.rawValue) }
        userFirstName = schema.attributes?.userFirstName
        userLastName = schema.attributes?.userLastName
        userEmail = schema.attributes?.userEmail
        apiKeyId = schema.attributes?.apiKeyID
    }

    public enum ActorType: String, CaseIterable, Codable, Sendable {
        case user = "USER"
        case apiKey = "API_KEY"
        case xcodeCloud = "XCODE_CLOUD"
        case apple = "APPLE"
    }
}
