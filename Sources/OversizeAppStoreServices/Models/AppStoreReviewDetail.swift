//
// Copyright © 2024 Alexander Romanov
// AppInfoLocalization_2.swift, created on 31.10.2024
//

import AppStoreAPI
import Foundation
import OversizeCore

public struct AppStoreReviewDetail: Sendable {
    public let id: String

    public var contactFirstName: String
    public var contactLastName: String
    public var contactPhone: String
    public var contactEmail: String
    public var demoAccountName: String
    public var demoAccountPassword: String
    public var isDemoAccountRequired: Bool
    public var notes: String

    public init?(schema: AppStoreAPI.AppStoreReviewDetail) {
        guard let attributes = schema.attributes else { return nil }
        id = schema.id
        contactFirstName = attributes.contactFirstName.valueOrEmpty
        contactLastName = attributes.contactLastName.valueOrEmpty
        contactPhone = attributes.contactPhone.valueOrEmpty
        contactEmail = attributes.contactEmail.valueOrEmpty
        demoAccountName = attributes.demoAccountName.valueOrEmpty
        demoAccountPassword = attributes.demoAccountPassword.valueOrEmpty
        isDemoAccountRequired = attributes.isDemoAccountRequired.valueOrFalse
        notes = attributes.notes.valueOrEmpty
    }
}
