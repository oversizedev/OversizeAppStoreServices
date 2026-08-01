//
// Copyright © 2026 Alexander Romanov
// ASCResponseCache.swift, created on 30.07.2026
//

#if canImport(Darwin)
import Foundation

public final class ASCResponseCache: @unchecked Sendable {
    public static let shared = ASCResponseCache()

    private enum Header {
        static let cacheControl = "Cache-Control"
        static let cachedAt = "X-ASC-Cached-At"
        static let dropped: Set<String> = ["set-cookie", "authorization", "pragma", "expires", "age", "vary"]
    }

    private static let scopeQueryName = "__ascScope"

    private let urlCache: URLCache

    public init(
        memoryCapacity: Int = 32 * 1024 * 1024,
        diskCapacity: Int = 512 * 1024 * 1024,
        directory: URL? = nil,
    ) {
        let cacheDirectory = directory ?? FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("OversizeAppStoreServices", isDirectory: true)
            .appendingPathComponent("ResponseCache", isDirectory: true)
        urlCache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            directory: cacheDirectory,
        )
    }

    func keyRequest(for request: URLRequest, scope: String) -> URLRequest? {
        guard let url = request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }
        var items = components.queryItems ?? []
        items.append(.init(name: Self.scopeQueryName, value: scope))
        components.queryItems = items
        guard let keyURL = components.url else { return nil }
        var keyRequest = URLRequest(url: keyURL)
        keyRequest.httpMethod = request.httpMethod
        return keyRequest
    }

    func cachedResponse(
        for keyRequest: URLRequest,
        originalURL: URL,
        ttl: TimeInterval,
    ) -> (response: HTTPURLResponse, data: Data)? {
        guard let cached = urlCache.cachedResponse(for: keyRequest),
              let httpResponse = cached.response as? HTTPURLResponse
        else {
            return nil
        }

        guard let cachedAtValue = httpResponse.value(forHTTPHeaderField: Header.cachedAt),
              let cachedAt = TimeInterval(cachedAtValue),
              Date().timeIntervalSince1970 - cachedAt < ttl
        else {
            return nil
        }

        guard let response = HTTPURLResponse(
            url: originalURL,
            statusCode: httpResponse.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headerFields(of: httpResponse),
        ) else {
            return nil
        }

        return (response, cached.data)
    }

    func store(
        data: Data,
        response: HTTPURLResponse,
        for keyRequest: URLRequest,
        ttl: TimeInterval,
    ) {
        var headers = headerFields(of: response).filter { !Header.dropped.contains($0.key.lowercased()) }
        headers[Header.cacheControl] = "max-age=\(Int(ttl))"
        headers[Header.cachedAt] = String(Date().timeIntervalSince1970)

        guard let keyURL = keyRequest.url,
              let storedResponse = HTTPURLResponse(
                  url: keyURL,
                  statusCode: response.statusCode,
                  httpVersion: "HTTP/1.1",
                  headerFields: headers,
              )
        else {
            return
        }

        urlCache.storeCachedResponse(
            .init(response: storedResponse, data: data, storagePolicy: .allowed),
            for: keyRequest,
        )
    }

    func invalidate(_ keyRequest: URLRequest) {
        guard let cached = urlCache.cachedResponse(for: keyRequest),
              let httpResponse = cached.response as? HTTPURLResponse
        else {
            return
        }

        var headers = headerFields(of: httpResponse)
        headers[Header.cachedAt] = "0"

        guard let keyURL = keyRequest.url,
              let expiredResponse = HTTPURLResponse(
                  url: keyURL,
                  statusCode: httpResponse.statusCode,
                  httpVersion: "HTTP/1.1",
                  headerFields: headers,
              )
        else {
            return
        }

        urlCache.storeCachedResponse(
            .init(response: expiredResponse, data: cached.data, storagePolicy: .allowed),
            for: keyRequest,
        )
    }

    private func headerFields(of response: HTTPURLResponse) -> [String: String] {
        var fields: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            guard let key = key as? String, let value = value as? String else { continue }
            fields[key] = value
        }
        return fields
    }
}
#endif
