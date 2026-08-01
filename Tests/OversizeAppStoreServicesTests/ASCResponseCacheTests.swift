//
// Copyright © 2026 Alexander Romanov
// ASCResponseCacheTests.swift, created on 30.07.2026
//

#if canImport(Darwin)
import Foundation
@testable import OversizeAppStoreServices
import Testing

struct ASCResponseCacheTests {
    private static let url = URL(string: "https://api.appstoreconnect.apple.com/v1/apps?limit=10")!

    private func makeCache() -> ASCResponseCache {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ASCResponseCacheTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        return ASCResponseCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 16 * 1024 * 1024, directory: directory)
    }

    private func makeResponse(statusCode: Int = 200, headers: [String: String] = [:]) -> HTTPURLResponse {
        HTTPURLResponse(
            url: Self.url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers,
        )!
    }

    @Test("Should return stored response for the same key")
    func storeAndLoad() throws {
        let cache = makeCache()
        var request = URLRequest(url: Self.url)
        request.httpMethod = "GET"
        let key = try #require(cache.keyRequest(for: request, scope: "account-a.0"))
        let payload = Data("{\"data\":[]}".utf8)

        cache.store(
            data: payload,
            response: makeResponse(headers: ["X-Rate-Limit": "user-hour-lim:3600;user-hour-rem:3599;"]),
            for: key,
            ttl: 300,
        )

        let cached = cache.cachedResponse(for: key, originalURL: Self.url, ttl: 300)

        #expect(cached?.data == payload)
        #expect(cached?.response.url == Self.url)
        #expect(cached?.response.statusCode == 200)
        #expect(cached?.response.value(forHTTPHeaderField: "X-Rate-Limit") != nil)
    }

    @Test("Should drop sensitive headers before storing")
    func dropsSensitiveHeaders() throws {
        let cache = makeCache()
        let request = URLRequest(url: Self.url)
        let key = try #require(cache.keyRequest(for: request, scope: "account-a.0"))

        cache.store(
            data: Data("{}".utf8),
            response: makeResponse(headers: ["Set-Cookie": "session=secret", "Authorization": "Bearer token"]),
            for: key,
            ttl: 300,
        )

        let cached = cache.cachedResponse(for: key, originalURL: Self.url, ttl: 300)

        #expect(cached?.response.value(forHTTPHeaderField: "Set-Cookie") == nil)
        #expect(cached?.response.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("Should miss when entry is older than ttl")
    func expiresByTTL() throws {
        let cache = makeCache()
        let request = URLRequest(url: Self.url)
        let key = try #require(cache.keyRequest(for: request, scope: "account-a.0"))

        cache.store(data: Data("{}".utf8), response: makeResponse(), for: key, ttl: 300)

        #expect(cache.cachedResponse(for: key, originalURL: Self.url, ttl: 0) == nil)
    }

    @Test("Should isolate entries of different accounts")
    func isolatesScopes() throws {
        let cache = makeCache()
        let request = URLRequest(url: Self.url)
        let keyA = try #require(cache.keyRequest(for: request, scope: "account-a.0"))
        let keyB = try #require(cache.keyRequest(for: request, scope: "account-b.0"))

        cache.store(data: Data("a".utf8), response: makeResponse(), for: keyA, ttl: 300)

        #expect(cache.cachedResponse(for: keyA, originalURL: Self.url, ttl: 300)?.data == Data("a".utf8))
        #expect(cache.cachedResponse(for: keyB, originalURL: Self.url, ttl: 300) == nil)
    }

    @Test("Should make entries unreachable after generation bump")
    func generationBumpInvalidates() throws {
        let cache = makeCache()
        let request = URLRequest(url: Self.url)
        let oldKey = try #require(cache.keyRequest(for: request, scope: "account-a.0"))
        let newKey = try #require(cache.keyRequest(for: request, scope: "account-a.1"))

        cache.store(data: Data("old".utf8), response: makeResponse(), for: oldKey, ttl: 300)

        #expect(cache.cachedResponse(for: newKey, originalURL: Self.url, ttl: 300) == nil)
    }

    @Test("Should keep query parameters distinct in keys")
    func distinctQueriesProduceDistinctKeys() throws {
        let cache = makeCache()
        let firstURL = URL(string: "https://api.appstoreconnect.apple.com/v1/apps?limit=1")!
        let secondURL = URL(string: "https://api.appstoreconnect.apple.com/v1/apps?limit=10")!
        let firstKey = try #require(cache.keyRequest(for: .init(url: firstURL), scope: "account-a.0"))
        let secondKey = try #require(cache.keyRequest(for: .init(url: secondURL), scope: "account-a.0"))

        cache.store(data: Data("first".utf8), response: makeResponse(), for: firstKey, ttl: 300)

        #expect(cache.cachedResponse(for: firstKey, originalURL: firstURL, ttl: 300)?.data == Data("first".utf8))
        #expect(cache.cachedResponse(for: secondKey, originalURL: secondURL, ttl: 300) == nil)
    }

    @Test("Should keep entries of different HTTP methods apart")
    func distinctMethodsProduceDistinctKeys() throws {
        let cache = makeCache()
        var getRequest = URLRequest(url: Self.url)
        getRequest.httpMethod = "GET"
        var headRequest = URLRequest(url: Self.url)
        headRequest.httpMethod = "HEAD"
        let getKey = try #require(cache.keyRequest(for: getRequest, scope: "account-a.0"))
        let headKey = try #require(cache.keyRequest(for: headRequest, scope: "account-a.0"))

        #expect(getKey.httpMethod == "GET")
        #expect(headKey.httpMethod == "HEAD")
        #expect(getKey.url == headKey.url)
    }
}
#endif
