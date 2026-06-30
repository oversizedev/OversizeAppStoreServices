//
// Copyright © 2026 Alexander Romanov
// NetworkErrorMapper.swift, created on 23.06.2026
//

import AppStoreConnect
import Foundation

extension Error {
    var asNetworkError: NetworkError {
        if self is CancellationError { return .unknown(self) }
        if let urlError = self as? URLError {
            switch urlError.code {
            case .cancelled:
                return .unknown(self)
            case .notConnectedToInternet, .networkConnectionLost:
                return .noConnection
            case .timedOut:
                return .timeout
            default:
                return .noResponse
            }
        }
        if let responseError = self as? ResponseError {
            switch responseError {
            case let .requestFailure(errorResponse, _, _):
                if let first = errorResponse?.errors?.first {
                    return .apiError(title: first.title, detail: first.detail)
                }
                return .unexpectedStatusCode
            case .rateLimitExceeded:
                return .apiError(title: "Rate limit exceeded", detail: nil)
            case .dataAssertionFailed:
                return .decode
            }
        }
        if let networkError = self as? NetworkError { return networkError }
        return .noResponse
    }

    var isCancellation: Bool {
        if self is CancellationError { return true }
        if let urlError = self as? URLError, urlError.code == .cancelled { return true }
        return false
    }
}
