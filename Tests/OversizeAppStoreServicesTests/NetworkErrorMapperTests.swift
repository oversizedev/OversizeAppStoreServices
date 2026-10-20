//
// Copyright © 2026 Alexander Romanov
// NetworkErrorMapperTests.swift, created on 05.10.2026
//

import Foundation
@testable import OversizeAppStoreServices
import OversizeCore
import Testing

struct NetworkErrorMapperTests {
    @Test("Should recognize a wrapped task cancellation")
    func wrappedCancellationIsRecognized() {
        let wrapped: Error = NetworkError.unknown(CancellationError())

        #expect(wrapped.isCancellation)
    }

    @Test("Should recognize a mapped task cancellation")
    func mappedCancellationIsRecognized() {
        let mapped: Error = CancellationError().asNetworkError

        #expect(mapped.isCancellation)
    }

    @Test("Should recognize a wrapped URL cancellation")
    func wrappedURLCancellationIsRecognized() {
        let wrapped: Error = NetworkError.unknown(URLError(.cancelled))

        #expect(wrapped.isCancellation)
    }

    @Test("Should not treat other unknown errors as cancellation")
    func otherUnknownErrorIsNotCancellation() {
        let wrapped: Error = NetworkError.unknown(URLError(.badServerResponse))

        #expect(!wrapped.isCancellation)
        #expect(!NetworkError.unknown(nil).isCancellation)
    }
}
