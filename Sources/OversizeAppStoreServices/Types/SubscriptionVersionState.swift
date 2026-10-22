//
// Copyright © 2026 Alexander Romanov
// SubscriptionVersionState.swift, created on 21.08.2026
//

#if !os(Linux)
import SwiftUI
#endif

public extension SubscriptionVersion.State {
    var displayName: String {
        switch self {
        case .prepareForSubmission:
            "Prepare for Submission"
        case .readyForReview:
            "Ready for Review"
        case .waitingForReview:
            "Waiting for Review"
        case .inReview:
            "In Review"
        case .accepted:
            "Accepted"
        case .approved:
            "Approved"
        case .replacedWithNewVersion:
            "Replaced with New Version"
        case .rejected:
            "Rejected"
        case .developerRejected:
            "Developer Rejected"
        }
    }

    #if !os(Linux)
    var statusColor: Color {
        switch self {
        case .prepareForSubmission:
            .gray
        case .readyForReview, .waitingForReview, .inReview:
            .yellow
        case .accepted, .approved:
            .green
        case .replacedWithNewVersion:
            .orange
        case .rejected, .developerRejected:
            .red
        }
    }
    #endif
}
