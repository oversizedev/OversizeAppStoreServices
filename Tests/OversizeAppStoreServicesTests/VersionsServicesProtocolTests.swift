import Testing
@testable import OversizeAppStoreServices

struct VersionsServicesProtocolTests {
    @Test
    func keepsDefaultArgumentCallShapesOnProtocolExistentials() async {
        let service: any VersionsServicesProtocol = VersionsService(
            authenticator: CredentialsAuthenticator(
                credentials: AppStoreConnectCredentials(issuerID: "issuer", keyID: "key", privateKey: "invalid"),
            ),
        )

        _ = await service.fetchActualAppStoreVersions(appId: "app")
        _ = await service.fetchActualAppStoreVersions(appId: "app", platform: .ios)
        _ = await service.fetchAppVersions(appId: "app", platform: .ios)
        _ = await service.fetchRelisedAppVersionsIncludeLocalizations(appId: "app", limit: 1)
        _ = await service.fetchRelisedAppVersionsIncludeLocalizations(appId: "app", platform: .ios, limit: 1)
        _ = await service.fetchActualAppStoreVersionsIncludeBuilds(appId: "app", limit: 1)
    }
}
