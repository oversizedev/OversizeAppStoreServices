//
// Copyright © 2026 Alexander Romanov
// ReviewSubmissionItemState.swift, created on 14.08.2026
//

#if !os(Linux)
import SwiftUI
#endif

public extension ReviewSubmissionItem.State {
    var displayName: String {
        switch self {
        case .readyForReview:
            "Ready for Review"
        case .accepted:
            "Accepted"
        case .approved:
            "Approved"
        case .rejected:
            "Rejected"
        case .removed:
            "Removed"
        }
    }

    #if !os(Linux)
    var statusColor: Color {
        switch self {
        case .readyForReview:
            .blue
        case .accepted, .approved:
            .green
        case .rejected:
            .red
        case .removed:
            .orange
        }
    }
    #endif
}
