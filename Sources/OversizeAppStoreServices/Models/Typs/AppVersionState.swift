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
            return .green
        case .inReview, .readyForReview, .pendingAppleRelease, .pendingDeveloperRelease, .processingForDistribution, .waitingForReview, .waitingForExportCompliance:
            return .yellow
        case .developerRejected, .rejected, .metadataRejected, .invalidBinary, .replacedWithNewVersion:
            return .red
        case .prepareForSubmission:
            return .gray
        }
    }

    // Computed property to return display-friendly name
    public var displayName: String {
        switch self {
        case .accepted:
            return "Accepted"
        case .developerRejected:
            return "Developer Rejected"
        case .inReview:
            return "In Review"
        case .invalidBinary:
            return "Invalid Binary"
        case .metadataRejected:
            return "Metadata Rejected"
        case .pendingAppleRelease:
            return "Pending Apple Release"
        case .pendingDeveloperRelease:
            return "Pending Developer Release"
        case .prepareForSubmission:
            return "Prepare for Submission"
        case .processingForDistribution:
            return "Processing for Distribution"
        case .readyForDistribution:
            return "Ready for Distribution"
        case .readyForReview:
            return "Ready for Review"
        case .rejected:
            return "Rejected"
        case .replacedWithNewVersion:
            return "Replaced with New Version"
        case .waitingForExportCompliance:
            return "Waiting for Export Compliance"
        case .waitingForReview:
            return "Waiting for Review"
        }
    }

    public var isCanBeHidden: Bool {
        switch self {
        case .replacedWithNewVersion:
            return true
        default:
            return false
        }
    }

    public var isEditable: Bool {
        switch self {
        case .prepareForSubmission, .metadataRejected, .developerRejected, .rejected, .invalidBinary:
            return true
        default:
            return false
        }
    }
}
