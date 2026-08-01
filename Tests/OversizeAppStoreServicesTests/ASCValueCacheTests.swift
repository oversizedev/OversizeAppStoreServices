//
// Copyright © 2026 Alexander Romanov
// ASCValueCacheTests.swift, created on 30.07.2026
//

import Foundation
@testable import OversizeAppStoreServices
import Testing

#if canImport(Darwin)
@Suite(.serialized)
struct ASCValueCacheTests {
    private struct Payload: Codable, Equatable, Sendable {
        let name: String
        let total: Double
    }

    private struct Table: Codable, Equatable, Sendable {
        let headers: [String]
    }

    private static let payload = Payload(name: "proceeds", total: 42.5)

    private func redirectStorage() {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ASCValueCacheTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        ASCValueCacheStorage.shared = ASCValueCacheStorage(
            memoryCapacity: 2 * 1024 * 1024,
            diskCapacity: 16 * 1024 * 1024,
            directory: directory,
        )
    }

    private func account() -> String { "asc-value-tests-\(UUID().uuidString)" }

    @Test("Should return the stored value for the same key")
    func storeAndLoadRoundTrip() {
        redirectStorage()
        let cache = ASCValueCache(namespace: "round-trip", ttl: 300, accountID: account())

        cache.save(Self.payload, key: "key")

        #expect(cache.load(Payload.self, key: "key") == Self.payload)
    }

    @Test("Should miss for an unknown key")
    func missesForUnknownKey() {
        redirectStorage()
        let cache = ASCValueCache(namespace: "unknown", ttl: 300, accountID: account())

        #expect(cache.load(Payload.self, key: "never-written") == nil)
    }

    @Test("Should not cache when the account is unknown")
    func withoutAccountNothingIsCached() {
        redirectStorage()
        let cache = ASCValueCache(namespace: "no-account", ttl: 300, accountID: nil)

        cache.save(Self.payload, key: "key")

        #expect(cache.load(Payload.self, key: "key") == nil)
    }

    @Test("Should respect the manually injected ttl")
    func respectsInjectedTTL() {
        redirectStorage()
        let accountID = account()
        let writer = ASCValueCache(namespace: "ttl", ttl: 300, accountID: accountID)
        let expiredReader = ASCValueCache(namespace: "ttl", ttl: 0, accountID: accountID)

        writer.save(Self.payload, key: "key")

        #expect(writer.load(Payload.self, key: "key") == Self.payload)
        #expect(expiredReader.load(Payload.self, key: "key") == nil)
    }

    @Test("Should isolate namespaces")
    func namespacesAreIsolated() {
        redirectStorage()
        let accountID = account()
        let first = ASCValueCache(namespace: "first", ttl: 300, accountID: accountID)
        let second = ASCValueCache(namespace: "second", ttl: 300, accountID: accountID)

        first.save(Self.payload, key: "key")

        #expect(second.load(Payload.self, key: "key") == nil)
    }

    @Test("Should isolate accounts")
    func accountsAreIsolated() {
        redirectStorage()
        let first = ASCValueCache(namespace: "accounts", ttl: 300, accountID: account())
        let second = ASCValueCache(namespace: "accounts", ttl: 300, accountID: account())

        first.save(Self.payload, key: "key")

        #expect(second.load(Payload.self, key: "key") == nil)
    }

    @Test("Should drop values after a value generation bump")
    func valueGenerationBumpInvalidates() {
        redirectStorage()
        let accountID = account()
        let cache = ASCValueCache(namespace: "generation", ttl: 300, accountID: accountID)

        cache.save(Self.payload, key: "key")
        ASCCacheScope.bumpValueGeneration(for: accountID)

        #expect(cache.load(Payload.self, key: "key") == nil)
    }

    @Test("Should keep values after a response generation bump")
    func responseGenerationBumpKeepsValues() {
        redirectStorage()
        let accountID = account()
        let cache = ASCValueCache(namespace: "mutation", ttl: 300, accountID: accountID)

        cache.save(Self.payload, key: "key")
        ASCCacheScope.bumpGeneration(for: accountID)

        #expect(cache.load(Payload.self, key: "key") == Self.payload)
    }

    @Test("Should drop the entry on remove")
    func removeInvalidates() {
        redirectStorage()
        let cache = ASCValueCache(namespace: "remove", ttl: 300, accountID: account())

        cache.save(Self.payload, key: "key")
        cache.remove(key: "key")

        #expect(cache.load(Payload.self, key: "key") == nil)
    }

    @Test("Should degrade to a miss when the entry cannot be decoded")
    func undecodableEntryDegradesToMiss() {
        redirectStorage()
        let accountID = account()
        let writer = ASCValueCache(namespace: "decode", ttl: 300, accountID: accountID)
        let reader = ASCValueCache(namespace: "decode", ttl: 300, accountID: accountID)

        writer.save(Self.payload, key: "key")

        #expect(reader.load(Table.self, key: "key") == nil)
        #expect(writer.load(Payload.self, key: "key") == nil)
    }
}
#endif
