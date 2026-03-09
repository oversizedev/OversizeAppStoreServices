//
// Copyright © 2026 Alexander Romanov
// ReviewSubmissionAssociatedErrors.swift, created on 20.02.2026
//

import Foundation

public struct ReviewSubmissionAssociatedErrors: Error, LocalizedError, Sendable {
    public struct AssociatedError: Identifiable, Hashable, Sendable {
        public let id: String
        public let title: String
        public let detail: String
        public let code: String?
        public let pointer: String?

        public init(id: String? = nil, title: String, detail: String, code: String? = nil, pointer: String? = nil) {
            self.id = id ?? UUID().uuidString
            self.title = title
            self.detail = detail
            self.code = code
            self.pointer = pointer
        }
    }

    public let title: String
    public let detail: String?
    public let errors: [AssociatedError]

    public init(title: String, detail: String? = nil, errors: [AssociatedError]) {
        self.title = title
        self.detail = detail
        self.errors = errors
    }

    public var errorDescription: String? {
        title
    }

    public var failureReason: String? {
        let details = errors.map(\.detail).joined(separator: "\n")
        if details.isEmpty {
            return detail
        }
        return details
    }
}
