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
    static let appStoreConnectCredentials = Keychain(service: AppStoreConnectCredentials.keychainService)
}

public extension AppStoreConnectCredentials {
    static func stored(for accountID: UUID) throws -> Self? {
        try Keychain.appStoreConnectCredentials.object(forKey: accountID.uuidString)
    }

    static func currentAccount() -> Self? {
        guard let accountValue = UserDefaults.standard.string(forKey: "AppStore.Account"),
              let accountID = UUID(uuidString: accountValue)
        else { return nil }
        return try? stored(for: accountID)
    }

    func save(for accountID: UUID) throws {
        try Keychain.appStoreConnectCredentials.setObject(self, forKey: accountID.uuidString)
    }

    static func remove(for accountID: UUID) throws {
        try Keychain.appStoreConnectCredentials.remove(forKey: accountID.uuidString)
    }

    static func removeAll() throws {
        try Keychain.appStoreConnectCredentials.removeAll()
    }
}
#endif
