//
// Copyright © 2026 Alexander Romanov
// ReviewSubmissionState.swift, created on 03.02.2026
//

#if !os(Linux)
import SwiftUI
#endif

public enum ReviewSubmissionState: String, CaseIterable, Codable, Sendable {
    case readyForReview = "READY_FOR_REVIEW"
    case waitingForReview = "WAITING_FOR_REVIEW"
    case inReview = "IN_REVIEW"
    case unresolvedIssues = "UNRESOLVED_ISSUES"
    case canceling = "CANCELING"
    case completing = "COMPLETING"
    case complete = "COMPLETE"

    public var displayName: String {
        switch self {
        case .readyForReview:
            "Ready for Review"
        case .waitingForReview:
            "Waiting for Review"
        case .inReview:
            "In Review"
        case .unresolvedIssues:
            "Unresolved Issues"
        case .canceling:
            "Canceling"
        case .completing:
            "Completing"
        case .complete:
            "Review Completed"
        }
    }

    #if !os(Linux)
    public var statusColor: Color {
        switch self {
        case .readyForReview:
            .blue
        case .waitingForReview:
            .yellow
        case .inReview:
            .yellow
        case .unresolvedIssues:
            .red
        case .canceling:
            .orange
        case .completing:
            .yellow
        case .complete:
            .green
        }
    }
    #endif
}
