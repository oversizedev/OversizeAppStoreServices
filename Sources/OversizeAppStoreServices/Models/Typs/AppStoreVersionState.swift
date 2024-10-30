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
            return .green
        case .inReview, .readyForReview, .pendingAppleRelease, .pendingDeveloperRelease, .processingForAppStore, .waitingForReview, .waitingForExportCompliance:
            return .yellow
        case .developerRemovedFromSale, .removedFromSale:
            return .orange
        case .developerRejected, .rejected, .metadataRejected, .invalidBinary, .replacedWithNewVersion:
            return .red
        case .pendingContract:
            return .purple
        case .prepareForSubmission, .notApplicable:
            return .gray
        }
    }

    // Computed property to return display-friendly name
    public var displayName: String {
        switch self {
        case .accepted:
            return "Accepted"
        case .developerRemovedFromSale:
            return "Developer Removed from Sale"
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
        case .pendingContract:
            return "Pending Contract"
        case .pendingDeveloperRelease:
            return "Pending Developer Release"
        case .prepareForSubmission:
            return "Prepare for Submission"
        case .preorderReadyForSale:
            return "Preorder Ready for Sale"
        case .processingForAppStore:
            return "Processing for App Store"
        case .readyForReview:
            return "Ready for Review"
        case .readyForSale:
            return "Ready for Sale"
        case .rejected:
            return "Rejected"
        case .removedFromSale:
            return "Removed from Sale"
        case .waitingForExportCompliance:
            return "Waiting for Export Compliance"
        case .waitingForReview:
            return "Waiting for Review"
        case .replacedWithNewVersion:
            return "Replaced with New Version"
        case .notApplicable:
            return "Not Applicable"
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

    public var isCanBeHidden: Bool {
        switch self {
        case .replacedWithNewVersion:
            return true
        default:
            return false
        }
    }
}
