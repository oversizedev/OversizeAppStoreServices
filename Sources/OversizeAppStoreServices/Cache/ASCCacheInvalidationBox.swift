//
// Copyright © 2026 Alexander Romanov
// ASCCacheInvalidationBox.swift, created on 30.07.2026
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class ASCCacheInvalidationBox: @unchecked Sendable {
    private let lock = NSLock()
    private var keyRequests: [URLRequest] = []

    func record(_ keyRequest: URLRequest) {
        lock.lock()
        defer { lock.unlock() }
        keyRequests.append(keyRequest)
    }

    func invalidateRecorded() {
        lock.lock()
        let recorded = keyRequests
        keyRequests = []
        lock.unlock()

        #if canImport(Darwin)
        for keyRequest in recorded {
            ASCCachingURLProtocol.cache.invalidate(keyRequest)
        }
        #endif
    }
}
