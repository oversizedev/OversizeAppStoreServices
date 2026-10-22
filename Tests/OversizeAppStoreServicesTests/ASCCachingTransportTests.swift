//
// Copyright © 2026 Alexander Romanov
// ASCCachingTransportTests.swift, created on 30.07.2026
//

#if canImport(Darwin)
import AppStoreAPI
import AppStoreConnect
import Foundation
@testable import OversizeAppStoreServices
import Testing

@Suite(.serialized)
struct ASCCachingTransportTests {
    private struct StubAuthenticator: Authenticator {
        let api: API = .appStoreConnect
        func token() throws -> String {
            "stub-token"
        }
    }

    private static let appsBody = Data(#"{"data":[],"links":{"self":"https://api.appstoreconnect.apple.com/v1/apps"}}"#.utf8)

    private func makeClient(
        status: Int = 200,
        body: Data = ASCCachingTransportTests.appsBody,
        headers: [String: String] = ["Content-Type": "application/json"],
        accountID: String? = "asc-transport-tests",
        resetStub: Bool = true,
    ) -> AppStoreConnectClient {
        if resetStub {
            StubURLProtocol.reset(status: status, body: body, headers: headers)

            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("ASCCachingTransportTests", isDirectory: true)
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
            ASCCachingURLProtocol.cache = ASCResponseCache(
                memoryCapacity: 4 * 1024 * 1024,
                diskCapacity: 16 * 1024 * 1024,
                directory: directory,
            )

            let innerConfiguration = URLSessionConfiguration.ephemeral
            innerConfiguration.urlCache = nil
            innerConfiguration.protocolClasses = [StubURLProtocol.self]
            ASCCachingURLProtocol.innerSession = URLSession(configuration: innerConfiguration)
        }

        let outerConfiguration = URLSessionConfiguration.ephemeral
        outerConfiguration.urlCache = nil
        outerConfiguration.protocolClasses = [ASCCachingURLProtocol.self, StubURLProtocol.self]

        return AppStoreConnectClient(
            transport: ASCCachingTransport(
                session: URLSession(configuration: outerConfiguration),
                accountID: accountID,
            ),
            authenticator: StubAuthenticator(),
        )
    }

    @Test("Should serve the second request from cache")
    func cachesRepeatedRequest() async {
        let client = makeClient()

        for _ in 0 ..< 2 {
            _ = await ASCCache.cached(ttl: 300) {
                try await client.send(Resources.v1.apps.get())
            }
        }

        #expect(StubURLProtocol.requestCount == 1)
    }

    @Test("Should hit the network when force is requested")
    func forceBypassesCache() async {
        let client = makeClient()

        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }
        _ = await ASCCache.cached(ttl: 300, force: true) {
            try await client.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 2)
    }

    @Test("Should not cache requests without policy")
    func withoutPolicyGoesToNetwork() async {
        let client = makeClient()

        for _ in 0 ..< 2 {
            _ = try? await client.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 2)
    }

    @Test("Should refetch after the entry expires")
    func expiredEntryIsRefetched() async {
        let client = makeClient()

        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }
        _ = await ASCCache.cached(ttl: 0) {
            try await client.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 2)
    }

    @Test("Should not cache failed responses and should map the error")
    func failedResponseIsNotCached() async {
        let client = makeClient(status: 404, body: Data(#"{"errors":[{"id":"1","status":"404","code":"NOT_FOUND","title":"Not found","detail":"No app"}]}"#.utf8))

        let first: Result<AppsResponse, Error> = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }
        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 2)
        guard case let .failure(error) = first else {
            Issue.record("Expected failure")
            return
        }
        guard case let .apiError(title, detail) = error.asNetworkError else {
            Issue.record("Expected apiError, got \(error.asNetworkError)")
            return
        }
        #expect(title == "Not found")
        #expect(detail == "No app")
    }

    @Test("Should map rate limit responses")
    func rateLimitIsMapped() async {
        let client = makeClient(
            status: 429,
            body: Data("{}".utf8),
            headers: ["Content-Type": "application/json", "X-Rate-Limit": "user-hour-lim:3600;user-hour-rem:0;"],
        )

        let result: Result<AppsResponse, Error> = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }

        guard case let .failure(error) = result else {
            Issue.record("Expected failure")
            return
        }
        guard case let .apiError(title, _) = error.asNetworkError else {
            Issue.record("Expected apiError, got \(error.asNetworkError)")
            return
        }
        #expect(title == "Rate limit exceeded")
    }

    @Test("Should not share cached responses between accounts")
    func accountsDoNotShareCache() async {
        let firstAccountClient = makeClient(accountID: "account-a")
        let secondAccountClient = makeClient(accountID: "account-b", resetStub: false)

        _ = await ASCCache.cached(ttl: 300) {
            try await firstAccountClient.send(Resources.v1.apps.get())
        }
        _ = await ASCCache.cached(ttl: 300) {
            try await secondAccountClient.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 2)
    }

    @Test("Should not reuse a response that failed to decode")
    func undecodableResponseIsNotReused() async {
        let client = makeClient(body: Data(#"{"data":"not-an-array"}"#.utf8))

        for _ in 0 ..< 2 {
            let result: Result<AppsResponse, Error> = await ASCCache.cached(ttl: 300) {
                try await client.send(Resources.v1.apps.get())
            }
            guard case .failure = result else {
                Issue.record("Expected decoding failure")
                return
            }
        }

        #expect(StubURLProtocol.requestCount == 2)
    }

    @Test("Should invalidate cache after a mutating request")
    func mutationInvalidatesCache() async {
        let client = makeClient()

        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }

        ASCCacheScope.bumpGeneration(for: "asc-transport-tests")

        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 2)
    }

    @Test("Should invalidate cache after a mutating request sent through the client")
    func mutationThroughClientInvalidatesCache() async throws {
        let client = makeClient()
        let patchURL = try #require(URL(string: "https://api.appstoreconnect.apple.com/v1/apps/123"))

        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }
        try await client.send(Request<Void>.patch(patchURL))
        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 3)
    }

    @Test("Should invalidate responses cached while a mutation was running")
    func mutationInvalidatesCacheAgainWhenItFinishes() async throws {
        let accountID = "concurrent-mutation-tests-" + UUID().uuidString
        let client = makeClient(accountID: accountID)
        let patchURL = try #require(URL(string: "https://api.appstoreconnect.apple.com/v1/apps/123"))

        try await client.send(Request<Void>.patch(patchURL))

        #expect(ASCCacheScope.generation(for: accountID) == 2)
    }

    @Test("Should invalidate cached responses when a mutation fails")
    func failedMutationInvalidatesCache() async throws {
        let accountID = "failed-mutation-tests-" + UUID().uuidString
        let client = makeClient(accountID: accountID)
        let patchURL = try #require(URL(string: "https://api.appstoreconnect.apple.com/v1/apps/123"))

        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }
        StubURLProtocol.failRequests()

        do {
            try await client.send(Request<Void>.patch(patchURL))
            Issue.record("Expected mutation to fail")
        } catch {
            #expect(ASCCacheScope.generation(for: accountID) == 2)
        }

        StubURLProtocol.reset(status: 200, body: Self.appsBody, headers: ["Content-Type": "application/json"])
        _ = await ASCCache.cached(ttl: 300) {
            try await client.send(Resources.v1.apps.get())
        }

        #expect(StubURLProtocol.requestCount == 1)
    }

    @Test("Should not cache non-200 successful responses")
    func partialContentIsNotCached() async {
        let client = makeClient(status: 206)

        for _ in 0 ..< 2 {
            _ = await ASCCache.cached(ttl: 300) {
                try await client.send(Resources.v1.apps.get())
            }
        }

        #expect(StubURLProtocol.requestCount == 2)
    }

    @Test("Should accept an infinite ttl")
    func infiniteTTLIsClamped() async {
        let client = makeClient()

        for _ in 0 ..< 2 {
            _ = await ASCCache.cached(ttl: .infinity) {
                try await client.send(Resources.v1.apps.get())
            }
        }

        #expect(StubURLProtocol.requestCount == 1)
    }
}

final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    private nonisolated(unsafe) static var status: Int = 200
    private nonisolated(unsafe) static var body: Data = .init()
    private nonisolated(unsafe) static var headers: [String: String] = [:]
    private nonisolated(unsafe) static var failsRequests = false
    private nonisolated(unsafe) static var count: Int = 0
    private static let lock = NSLock()

    static var requestCount: Int {
        lock.withLock { count }
    }

    static func reset(status: Int, body: Data, headers: [String: String]) {
        lock.withLock {
            Self.status = status
            Self.body = body
            Self.headers = headers
            failsRequests = false
            count = 0
        }
    }

    static func failRequests() {
        lock.withLock { failsRequests = true }
    }

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let (status, body, headers, failsRequests) = Self.lock.withLock {
            Self.count += 1
            return (Self.status, Self.body, Self.headers, Self.failsRequests)
        }

        if failsRequests {
            client?.urlProtocol(self, didFailWithError: URLError(.timedOut))
            return
        }

        guard let url = request.url,
              let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
#endif
