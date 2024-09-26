//
// Copyright © 2024 Alexander Romanov
// AppStoreCertificate.swift, created on 12.09.2024
//

import SwiftUI

@propertyWrapper
public struct AppStoreCertificateStorage: DynamicProperty {
    private let label: String
    private let storage: KeychainService = .init()

    public init(_ label: String) {
        self.label = label
    }

    public var wrappedValue: KeychainService.AppStoreCertificate? {
        get { storage.getAppStoreCertificate(with: label) }
        nonmutating set {
            if let newValue {
                storage.updateAppStoreCertificate(newValue, with: label)
            } else {
                storage.deleteAppStoreCertificate(with: label)
            }
        }
    }
}
