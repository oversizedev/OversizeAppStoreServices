//
// Copyright © 2026 Alexander Romanov
// ASCCachingURLProtocol.swift, created on 30.07.2026
//

#if canImport(Darwin)
import Foundation

private struct UncheckedBox<Value>: @unchecked Sendable {
    let value: Value
}

final class ASCCachingURLProtocol: URLProtocol {
    enum Key {
        static let ttl = "ASCCache.ttl"
        static let force = "ASCCache.force"
        static let scope = "ASCCache.scope"
        static let handled = "ASCCache.handled"
    }

    private static let lock = NSLock()
    private nonisolated(unsafe) static var storedCache: ASCResponseCache = .shared
    private nonisolated(unsafe) static var storedSession: URLSession = makeDefaultSession()

    static var cache: ASCResponseCache {
        get { lock.withLock { storedCache } }
        set { lock.withLock { storedCache = newValue } }
    }

    static var innerSession: URLSession {
        get { lock.withLock { storedSession } }
        set { lock.withLock { storedSession = newValue } }
    }

    private var loadTask: Task<Void, Never>?

    static func makeDefaultSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        request.httpMethod?.uppercased() == "GET"
            && property(forKey: Key.ttl, in: request) != nil
            && property(forKey: Key.handled, in: request) == nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let request = request
        let box = UncheckedBox(value: self)
        loadTask = Task {
            await box.value.load(request)
        }
    }

    override func stopLoading() {
        loadTask?.cancel()
        loadTask = nil
    }

    // MARK: - Loading

    private func load(_ request: URLRequest) async {
        let ttl = (Self.property(forKey: Key.ttl, in: request) as? NSNumber)?.doubleValue ?? 0
        let force = (Self.property(forKey: Key.force, in: request) as? NSNumber)?.boolValue ?? false
        let scope = Self.property(forKey: Key.scope, in: request) as? String ?? ASCCacheScope.current
        let cache = Self.cache
        let keyRequest = cache.keyRequest(for: request, scope: scope)

        if !force, let url = request.url, let keyRequest,
           let cached = cache.cachedResponse(for: keyRequest, originalURL: url, ttl: ttl)
        {
            finish(response: cached.response, data: cached.data)
            return
        }

        do {
            let (data, response) = try await Self.innerSession.data(for: marked(request))
            if let httpResponse = response as? HTTPURLResponse {
                if (200 ..< 300).contains(httpResponse.statusCode), let keyRequest {
                    cache.store(data: data, response: httpResponse, for: keyRequest, ttl: ttl)
                }
            }
            finish(response: response, data: data)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    private func marked(_ request: URLRequest) -> URLRequest {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return request
        }
        Self.setProperty(true, forKey: Key.handled, in: mutableRequest)
        return mutableRequest as URLRequest
    }

    private func finish(response: URLResponse, data: Data) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
}
#endif
