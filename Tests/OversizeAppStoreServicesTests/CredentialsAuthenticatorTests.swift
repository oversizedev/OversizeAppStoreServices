#if canImport(Darwin)
import AppStoreAPI
import AppStoreConnect
import CryptoKit
import FactoryKit
import Foundation
@testable import OversizeAppStoreServices
import Testing

struct CredentialsAuthenticatorTests {
    @Test
    func signsAndReusesTokenFromInjectedCredentials() throws {
        let key = P256.Signing.PrivateKey()
        let credentials = AppStoreConnectCredentials(issuerID: "issuer", keyID: "key", privateKey: key.pemRepresentation)
        var authenticator = CredentialsAuthenticator(credentials: credentials)
        let before = Date().timeIntervalSince1970
        let token = try authenticator.token()
        let parts = token.split(separator: ".")
        #expect(parts.count == 3)
        let header = try JSONDecoder().decode(Header.self, from: decode(parts[0]))
        let payload = try JSONDecoder().decode(Payload.self, from: decode(parts[1]))
        #expect(header.kid == credentials.keyID)
        #expect(header.alg == "ES256")
        #expect(payload.iss == credentials.issuerID)
        #expect(payload.aud == "appstoreconnect-v1")
        #expect(payload.exp >= before + 1200)
        #expect(payload.exp <= Date().timeIntervalSince1970 + 1200)
        let signature = try P256.Signing.ECDSASignature(rawRepresentation: decode(parts[2]))
        #expect(key.publicKey.isValidSignature(signature, for: Data("\(parts[0]).\(parts[1])".utf8)))
        #expect(try authenticator.token() == token)
    }

    @Test
    func invalidPEMPreservesUnderlyingError() {
        var authenticator = CredentialsAuthenticator(credentials: .init(issuerID: "issuer", keyID: "key", privateKey: "invalid"))
        do {
            _ = try authenticator.token()
            Issue.record("Expected invalid private key")
        } catch let ASCAuthenticationError.invalidPrivateKey(underlying) {
            #expect(!(underlying is ASCAuthenticationError))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func snapshotsDoNotShareCredentialsOrCacheIDs() throws {
        let key = P256.Signing.PrivateKey().pemRepresentation
        let first = ASCServiceContext(configuration: .success(.init(
            accountID: UUID(), credentials: .init(issuerID: "first", keyID: "A", privateKey: key),
        )))
        let second = ASCServiceContext(configuration: .success(.init(
            accountID: UUID(), credentials: .init(issuerID: "second", keyID: "B", privateKey: key),
        )))
        var firstAuth = first.authenticator
        var secondAuth = second.authenticator
        let firstToken = try firstAuth.token()
        let secondToken = try secondAuth.token()
        #expect(first.cacheAccountID != second.cacheAccountID)
        #expect(try JSONDecoder().decode(Payload.self, from: decode(firstToken.split(separator: ".")[1])).iss == "first")
        #expect(try JSONDecoder().decode(Payload.self, from: decode(secondToken.split(separator: ".")[1])).iss == "second")
        #expect(ASCClientFactory.resolveCacheAccountID(for: firstAuth) == nil)
        #expect(ASCClientFactory.resolveCacheAccountID(for: firstAuth, explicit: first.cacheAccountID) == first.cacheAccountID)
    }

    @Test
    func missingConfigurationNeverReachesTransport() async {
        let transport = RejectingTransport()
        let context = ASCServiceContext(configuration: .failure(ASCAuthenticationError.missingCredentials))
        let client = AppStoreConnectClient(transport: transport, authenticator: context.authenticator)
        #expect(context.cacheAccountID == nil)
        do {
            _ = try await client.send(Resources.v1.apps.get())
            Issue.record("Expected missing credentials")
        } catch ASCAuthenticationError.missingCredentials {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        #expect(await transport.requestCount == 0)
    }

    @Test
    func configurationFailureIsPreserved() {
        var authenticator = ASCServiceContext(configuration: .failure(TestError.storageUnavailable)).authenticator
        #expect(throws: TestError.storageUnavailable) { try authenticator.token() }
    }

    private func decode(_ part: Substring) throws -> Data {
        var base64 = part.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        return try #require(Data(base64Encoded: base64))
    }

    private struct Header: Decodable {
        let kid: String
        let alg: String
    }

    private struct Payload: Decodable {
        let iss: String
        let aud: String
        let exp: Double
    }

    private enum TestError: Error {
        case storageUnavailable
    }

    private actor RejectingTransport: Transport {
        private(set) var requestCount = 0

        func send(request _: URLRequest, decoder _: JSONDecoder) async throws -> Response<Data> {
            requestCount += 1
            throw TestError.storageUnavailable
        }

        func download(request _: URLRequest) async throws -> Response<URL> {
            requestCount += 1
            throw TestError.storageUnavailable
        }

        func upload(request _: URLRequest, data _: Data, decoder _: JSONDecoder) async throws -> Response<Data> {
            requestCount += 1
            throw TestError.storageUnavailable
        }
    }
}
#endif
