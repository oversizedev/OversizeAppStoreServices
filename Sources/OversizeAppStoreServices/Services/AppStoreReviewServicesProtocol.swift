//
// Copyright © 2026 Alexander Romanov
// AppStoreReviewServicesProtocol.swift, created on 14.08.2026
//

import AppStoreAPI
import Foundation

public protocol AppStoreReviewServicesProtocol: Sendable {
    func fetchAppStoreReviewDetail(versionId: String) async -> Result<AppStoreReviewDetail, Error>
    func fetchAppStoreReviewDetailAttachments(versionId: String) async -> Result<[AppStoreReviewAttachment], Error>
    func patchAppStoreReviewDetail(
        appStoreReviewDetailId: String,
        contactFirstName: String?,
        contactLastName: String?,
        contactPhone: String?,
        contactEmail: String?,
        demoAccountName: String?,
        demoAccountPassword: String?,
        isDemoAccountRequired: Bool?,
        notes: String?,
    ) async -> Result<AppStoreReviewDetail, Error>
    func postAppStoreReviewDetail(
        versionId: String,
        contactFirstName: String?,
        contactLastName: String?,
        contactPhone: String?,
        contactEmail: String?,
        demoAccountName: String?,
        demoAccountPassword: String?,
        isDemoAccountRequired: Bool?,
        notes: String?,
    ) async -> Result<AppStoreReviewDetail, Error>
}
