//
// Copyright © 2026 Alexander Romanov
// ASCValueCache.swift, created on 30.07.2026
//

import Foundation
import OversizeCore
#if canImport(CryptoKit)
import CryptoKit
#endif

public struct ASCValueCache: Sendable {
    private let namespace: String
    private let ttl: TimeInterval
    private let accountID: String?

    public init(
        namespace: String,
        ttl: TimeInterval = ASCCache.TTL.month,
        accountID: String? = nil,
    ) {
        self.namespace = namespace
        self.ttl = ttl
        self.accountID = accountID
    }

    public func load<T: Decodable & Sendable>(_ type: T.Type, key: String) -> T? {
        #if canImport(Darwin)
        guard let accountID else { return nil }
        return ASCValueCacheStorage.shared.load(type, namespace: namespace, key: key, ttl: ttl, accountID: accountID)
        #else
        nil
        #endif
    }

    public func save(_ value: some Encodable & Sendable, key: String) {
        #if canImport(Darwin)
        guard let accountID else { return }
        ASCValueCacheStorage.shared.store(value, namespace: namespace, key: key, ttl: ttl, accountID: accountID)
        #endif
    }

    public func remove(key: String) {
        #if canImport(Darwin)
        guard let accountID else { return }
        ASCValueCacheStorage.shared.invalidate(namespace: namespace, key: key, accountID: accountID)
        #endif
    }
}

#if canImport(Darwin)
final class ASCValueCacheStorage: @unchecked Sendable {
    private static let host = "asc-value.invalid"
    private static let lock = NSLock()
    private nonisolated(unsafe) static var storage = ASCValueCacheStorage()

    static var shared: ASCValueCacheStorage {
        get { lock.withLock { storage } }
        set { lock.withLock { storage = newValue } }
    }

    private let responseCache: ASCResponseCache

    init(
        memoryCapacity: Int = 2 * 1024 * 1024,
        diskCapacity: Int = 64 * 1024 * 1024,
        directory: URL? = nil,
    ) {
        let cacheDirectory = directory ?? FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("OversizeAppStoreServices", isDirectory: true)
            .appendingPathComponent("ValueCache", isDirectory: true)
        responseCache = ASCResponseCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            directory: cacheDirectory,
        )
    }

    func load<T: Decodable>(
        _ type: T.Type,
        namespace: String,
        key: String,
        ttl: TimeInterval,
        accountID: String,
    ) -> T? {
        guard let keyRequest = keyRequest(namespace: namespace, key: key, accountID: accountID),
              let keyURL = keyRequest.url,
              let cached = responseCache.cachedResponse(for: keyRequest, originalURL: keyURL, ttl: ttl)
        else {
            return nil
        }

        do {
            return try JSONDecoder().decode(type, from: cached.data)
        } catch {
            Log.error("ASCValueCache: Failed to decode value for \(namespace)/\(key): \(error)")
            responseCache.invalidate(keyRequest)
            return nil
        }
    }

    func store(
        _ value: some Encodable,
        namespace: String,
        key: String,
        ttl: TimeInterval,
        accountID: String,
    ) {
        guard let keyRequest = keyRequest(namespace: namespace, key: key, accountID: accountID),
              let keyURL = keyRequest.url
        else {
            return
        }

        do {
            let data = try JSONEncoder().encode(value)
            guard let response = HTTPURLResponse(
                url: keyURL,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"],
            ) else {
                return
            }
            responseCache.store(data: data, response: response, for: keyRequest, ttl: ttl)
        } catch {
            Log.error("ASCValueCache: Failed to encode value for \(namespace)/\(key): \(error)")
        }
    }

    func invalidate(namespace: String, key: String, accountID: String) {
        guard let keyRequest = keyRequest(namespace: namespace, key: key, accountID: accountID) else { return }
        responseCache.invalidate(keyRequest)
    }

    private func keyRequest(namespace: String, key: String, accountID: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.host
        components.path = "/\(Self.pathComponent(namespace))/\(Self.digest(key))"

        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return responseCache.keyRequest(for: request, scope: ASCCacheScope.valueScope(for: accountID))
    }

    private static func digest(_ key: String) -> String {
        SHA256.hash(data: Data(key.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private static func pathComponent(_ namespace: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-_"))
        let sanitized = String(namespace.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" })
        guard sanitized != namespace else { return sanitized }
        return "\(sanitized)-\(digest(namespace).prefix(16))"
    }
}
#endif
