//
// Copyright © 2025 Alexander Romanov
// AppMediaAssetState.swift, created on 01.12.2025
//

import AppStoreAPI
import Foundation

public struct AppMediaAssetState: Codable, Equatable, Sendable {
    public let errors: [AppMediaStateError]?
    public let warnings: [AppMediaStateError]?
    public let state: State?

    public enum State: String, CaseIterable, Codable, Sendable {
        case awaitingUpload = "AWAITING_UPLOAD"
        case uploadComplete = "UPLOAD_COMPLETE"
        case complete = "COMPLETE"
        case failed = "FAILED"
    }

    public init(
        errors: [AppMediaStateError]? = nil,
        warnings: [AppMediaStateError]? = nil,
        state: State? = nil,
    ) {
        self.errors = errors
        self.warnings = warnings
        self.state = state
    }

    public init(schema: AppStoreAPI.AppMediaAssetState) {
        errors = schema.errors?.map { AppMediaStateError(schema: $0) }
        warnings = schema.warnings?.map { AppMediaStateError(schema: $0) }
        state = schema.state.map { State(rawValue: $0.rawValue) ?? .awaitingUpload }
    }
}
