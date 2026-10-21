//
// Copyright © 2026 Alexander Romanov
// ASCCachingTransport.swift, created on 30.07.2026
//

#if canImport(Darwin)
import AppStoreConnect
import Foundation

public struct ASCCachingTransport: Transport {
    private static let mutatingMethods: Set<String> = ["POST", "PATCH", "PUT", "DELETE"]

    public static let sharedSession = makeDefaultSession()

    private let session: URLSession
    private let scopeAccount: String?

    public init(session: URLSession = ASCCachingTransport.sharedSession, accountID: String? = nil) {
        self.session = session
        scopeAccount = accountID
    }

    public static func makeDefaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.protocolClasses = [ASCCachingURLProtocol.self] + (configuration.protocolClasses ?? [])
        return URLSession(configuration: configuration)
    }

    public func send(request: URLRequest, decoder: JSONDecoder) async throws -> Response<Data> {
        if Self.mutatingMethods.contains(request.httpMethod?.uppercased() ?? "") {
            return try await invalidatingCache {
                try await session.send(request: request, decoder: decoder)
            }
        }

        guard let policy = ASCCache.policy, let scopeAccount else {
            return try await session.send(request: request, decoder: decoder)
        }

        let scope = ASCCacheScope.scope(for: scopeAccount)
        let response = try await session.send(request: stamped(request, policy: policy, scope: scope), decoder: decoder)
        recordForInvalidation(request, scope: scope)
        return response
    }

    public func download(request: URLRequest) async throws -> Response<URL> {
        try await session.download(request: request)
    }

    public func upload(request: URLRequest, data: Data, decoder: JSONDecoder) async throws -> Response<Data> {
        try await invalidatingCache {
            try await session.upload(request: request, data: data, decoder: decoder)
        }
    }

    // MARK: - Invalidation

    /// The generation moves before the mutation, so a lost response still invalidates the cache, and
    /// again once it finishes, so a read that ran alongside it cannot keep the old state cached.
    private func invalidatingCache<Value>(_ mutation: () async throws -> Value) async throws -> Value {
        guard let scopeAccount else { return try await mutation() }
        ASCCacheScope.bumpGeneration(for: scopeAccount)
        defer { ASCCacheScope.bumpGeneration(for: scopeAccount) }
        return try await mutation()
    }

    // MARK: - Request stamping

    private func stamped(_ request: URLRequest, policy: ASCCachePolicy, scope: String) -> URLRequest {
        guard request.httpMethod?.uppercased() == "GET",
              let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest
        else {
            return request
        }
        URLProtocol.setProperty(NSNumber(value: policy.ttl), forKey: ASCCachingURLProtocol.Key.ttl, in: mutableRequest)
        URLProtocol.setProperty(NSNumber(value: policy.force), forKey: ASCCachingURLProtocol.Key.force, in: mutableRequest)
        URLProtocol.setProperty(scope, forKey: ASCCachingURLProtocol.Key.scope, in: mutableRequest)
        return mutableRequest as URLRequest
    }

    private func recordForInvalidation(_ request: URLRequest, scope: String) {
        guard request.httpMethod?.uppercased() == "GET",
              let box = ASCCache.invalidationBox,
              let keyRequest = ASCCachingURLProtocol.cache.keyRequest(for: request, scope: scope)
        else {
            return
        }
        box.record(keyRequest)
    }
}
#endif
