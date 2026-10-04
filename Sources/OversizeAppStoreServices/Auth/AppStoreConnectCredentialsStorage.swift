//
// Copyright © 2026 Alexander Romanov
// AppStoreConnectCredentialsStorage.swift, created on 03.10.2026
//

#if canImport(Darwin)
import Foundation
import OversizeServices

public extension AppStoreConnectCredentials {
    static let keychainService = "AppConnector.AppStoreConnectCredentials"
}

public extension Keychain {
    static let appStoreConnectCredentials = Keychain(
        service: AppStoreConnectCredentials.keychainService,
        synchronizable: true,
        useDataProtectionKeychain: true,
    )
}

public extension AppStoreConnectCredentials {
    static func stored(for accountID: UUID) throws -> Self? {
        try stored(for: accountID, in: .appStoreConnectCredentials)
    }

    static func currentAccount() -> Self? {
        guard let accountValue = UserDefaults.standard.string(forKey: "AppStore.Account"),
              let accountID = UUID(uuidString: accountValue)
        else { return nil }
        return try? stored(for: accountID)
    }

    func save(for accountID: UUID) throws {
        try save(for: accountID, in: .appStoreConnectCredentials)
    }

    static func remove(for accountID: UUID) throws {
        try remove(for: accountID, in: .appStoreConnectCredentials)
    }

    static func removeAll() throws {
        try removeAll(in: .appStoreConnectCredentials)
    }
}

extension AppStoreConnectCredentials {
    static func stored(for accountID: UUID, in keychain: Keychain) throws -> Self? {
        try keychain.object(forKey: accountID.uuidString)
    }

    func save(for accountID: UUID, in keychain: Keychain) throws {
        try keychain.setObject(self, forKey: accountID.uuidString)
    }

    static func remove(for accountID: UUID, in keychain: Keychain) throws {
        try keychain.remove(forKey: accountID.uuidString)
    }

    static func removeAll(in keychain: Keychain) throws {
        try keychain.removeAll()
    }
}
#endif
