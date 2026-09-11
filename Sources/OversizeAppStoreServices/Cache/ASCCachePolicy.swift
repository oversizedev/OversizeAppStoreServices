//
// Copyright © 2026 Alexander Romanov
// ASCCachePolicy.swift, created on 30.07.2026
//

import AppStoreConnect
import Foundation

public struct ASCCachePolicy: Sendable {
    public let ttl: TimeInterval
    public let force: Bool

    public init(ttl: TimeInterval, force: Bool) {
        self.ttl = ttl
        self.force = force
    }
}

public enum ASCCache {
    @TaskLocal public static var policy: ASCCachePolicy?
    @TaskLocal static var invalidationBox: ASCCacheInvalidationBox?

    public static func cached<T: Sendable>(
        ttl: TimeInterval = TTL.default,
        force: Bool = false,
        _ operation: @Sendable () async throws -> T,
    ) async -> Result<T, Error> {
        let box = ASCCacheInvalidationBox()
        do {
            let value = try await $policy.withValue(.init(ttl: ttl, force: force)) {
                try await $invalidationBox.withValue(box) {
                    try await operation()
                }
            }
            return .success(value)
        } catch {
            if isDecodingFailure(error) {
                box.invalidateRecorded()
            }
            return .failure(error.asNetworkError)
        }
    }

    private static func isDecodingFailure(_ error: Error) -> Bool {
        if error is DecodingError {
            return true
        }
        if let responseError = error as? ResponseError, case .dataAssertionFailed = responseError {
            return true
        }
        return false
    }

    public enum TTL {
        public static let short: TimeInterval = 60
        public static let `default`: TimeInterval = 300
        public static let long: TimeInterval = 60 * 60
        public static let veryLong: TimeInterval = 60 * 60 * 24
        public static let week: TimeInterval = 60 * 60 * 24 * 7
        public static let month: TimeInterval = 60 * 60 * 24 * 30
    }
}
