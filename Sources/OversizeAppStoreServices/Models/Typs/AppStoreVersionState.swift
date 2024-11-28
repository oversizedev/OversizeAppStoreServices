//
// Copyright © 2024 Alexander Romanov
// AppStoreVersionState.swift, created on 06.10.2024
//

import SwiftUI

public enum AppStoreVersionState: String, CaseIterable, Codable, Sendable {
    case accepted = "ACCEPTED"
    case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
    case developerRejected = "DEVELOPER_REJECTED"
    case inReview = "IN_REVIEW"
    case invalidBinary = "INVALID_BINARY"
    case metadataRejected = "METADATA_REJECTED"
    case pendingAppleRelease = "PENDING_APPLE_RELEASE"
    case pendingContract = "PENDING_CONTRACT"
    case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case preorderReadyForSale = "PREORDER_READY_FOR_SALE"
    case processingForAppStore = "PROCESSING_FOR_APP_STORE"
    case readyForReview = "READY_FOR_REVIEW"
    case readyForSale = "READY_FOR_SALE"
    case rejected = "REJECTED"
    case removedFromSale = "REMOVED_FROM_SALE"
    case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
    case waitingForReview = "WAITING_FOR_REVIEW"
    case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
    case notApplicable = "NOT_APPLICABLE"

    // Computed property to return color based on the state
    public var statusColor: Color {
        switch self {
        case .accepted, .readyForSale, .preorderReadyForSale:
            .green
        case .inReview, .readyForReview, .pendingAppleRelease, .pendingDeveloperRelease, .processingForAppStore, .waitingForReview, .waitingForExportCompliance:
            .yellow
        case .developerRemovedFromSale, .removedFromSale:
            .orange
        case .developerRejected, .rejected, .metadataRejected, .invalidBinary, .replacedWithNewVersion:
            .red
        case .pendingContract:
            .purple
        case .prepareForSubmission, .notApplicable:
            .gray
        }
    }

    // Computed property to return display-friendly name
    public var displayName: String {
        switch self {
        case .accepted:
            "Accepted"
        case .developerRemovedFromSale:
            "Developer Removed from Sale"
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
        case .pendingContract:
            "Pending Contract"
        case .pendingDeveloperRelease:
            "Pending Developer Release"
        case .prepareForSubmission:
            "Prepare for Submission"
        case .preorderReadyForSale:
            "Preorder Ready for Sale"
        case .processingForAppStore:
            "Processing for App Store"
        case .readyForReview:
            "Ready for Review"
        case .readyForSale:
            "Ready for Sale"
        case .rejected:
            "Rejected"
        case .removedFromSale:
            "Removed from Sale"
        case .waitingForExportCompliance:
            "Waiting for Export Compliance"
        case .waitingForReview:
            "Waiting for Review"
        case .replacedWithNewVersion:
            "Replaced with New Version"
        case .notApplicable:
            "Not Applicable"
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

    public var isCanBeHidden: Bool {
        switch self {
        case .replacedWithNewVersion:
            true
        default:
            false
        }
    }
}
