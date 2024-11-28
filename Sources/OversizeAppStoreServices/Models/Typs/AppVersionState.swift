//
// Copyright © 2024 Alexander Romanov
// AppVersionState.swift, created on 06.10.2024
//

import SwiftUI

public enum AppVersionState: String, CaseIterable, Codable, Sendable {
    case accepted = "ACCEPTED"
    case developerRejected = "DEVELOPER_REJECTED"
    case inReview = "IN_REVIEW"
    case invalidBinary = "INVALID_BINARY"
    case metadataRejected = "METADATA_REJECTED"
    case pendingAppleRelease = "PENDING_APPLE_RELEASE"
    case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case processingForDistribution = "PROCESSING_FOR_DISTRIBUTION"
    case readyForDistribution = "READY_FOR_DISTRIBUTION"
    case readyForReview = "READY_FOR_REVIEW"
    case rejected = "REJECTED"
    case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
    case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
    case waitingForReview = "WAITING_FOR_REVIEW"

    // Computed property to return color based on the state
    public var statusColor: Color {
        switch self {
        case .accepted, .readyForDistribution:
            .green
        case .inReview, .readyForReview, .pendingAppleRelease, .pendingDeveloperRelease, .processingForDistribution, .waitingForReview, .waitingForExportCompliance:
            .yellow
        case .developerRejected, .rejected, .metadataRejected, .invalidBinary, .replacedWithNewVersion:
            .red
        case .prepareForSubmission:
            .gray
        }
    }

    // Computed property to return display-friendly name
    public var displayName: String {
        switch self {
        case .accepted:
            "Accepted"
        case .developerRejected:
            "Developer Rejected"
        case .inReview:
            "In Review"
        case .invalidBinary:
            "Invalid Binary"
        case .metadataRejected:
            "Metadata Rejected"
        case .pendingAppleRelease:
            "Pending Apple Release"
        case .pendingDeveloperRelease:
            "Pending Developer Release"
        case .prepareForSubmission:
            "Prepare for Submission"
        case .processingForDistribution:
            "Processing for Distribution"
        case .readyForDistribution:
            "Ready for Distribution"
        case .readyForReview:
            "Ready for Review"
        case .rejected:
            "Rejected"
        case .replacedWithNewVersion:
            "Replaced with New Version"
        case .waitingForExportCompliance:
            "Waiting for Export Compliance"
        case .waitingForReview:
            "Waiting for Review"
        }
    }

    public var isCanBeHidden: Bool {
        switch self {
        case .replacedWithNewVersion:
            true
        default:
            false
        }
    }

    public var isEditable: Bool {
        switch self {
        case .prepareForSubmission, .metadataRejected, .developerRejected, .rejected, .invalidBinary:
            true
        default:
            false
        }
    }
}
