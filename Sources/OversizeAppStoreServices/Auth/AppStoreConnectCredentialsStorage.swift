//
// Copyright © 2026 Alexander Romanov
// AppStoreConnectCredentialsStorage.swift, created on 08.07.2026
//

#if canImport(Darwin)
import Foundation
import Security

public struct AppStoreConnectCredentials: Codable, Sendable, Equatable {
    public let issuerID: String
    public let keyID: String
    public let privateKey: String

    public init(issuerID: String, keyID: String, privateKey: String) {
        self.issuerID = issuerID
        self.keyID = keyID
        self.privateKey = privateKey
    }
}

public struct AppStoreConnectCredentialsStorage: Sendable {
    public enum StorageError: Error {
        case encodingFailed
        case keychain(OSStatus)
    }

    public static let service = "AppConnector.AppStoreConnectCredentials"

    public init() {}

    public func save(_ credentials: AppStoreConnectCredentials, for accountID: UUID) throws {
        guard let data = try? JSONEncoder().encode(credentials) else {
            throw StorageError.encodingFailed
        }

        var addQuery = baseQuery(for: accountID)
        addQuery[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
        addQuery[kSecValueData] = data

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        switch addStatus {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            let updateStatus = SecItemUpdate(
                baseQuery(for: accountID) as CFDictionary,
                [kSecValueData: data] as CFDictionary,
            )
            guard updateStatus == errSecSuccess else {
                throw StorageError.keychain(updateStatus)
            }
        default:
            throw StorageError.keychain(addStatus)
        }
    }

    public func credentials(for accountID: UUID) -> AppStoreConnectCredentials? {
        var query = baseQuery(for: accountID)
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(AppStoreConnectCredentials.self, from: data)
    }

    public func delete(for accountID: UUID) {
        SecItemDelete(baseQuery(for: accountID) as CFDictionary)
    }

    public func deleteAll() throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Self.service,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw StorageError.keychain(status)
        }
    }

    private func baseQuery(for accountID: UUID) -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Self.service,
            kSecAttrAccount: accountID.uuidString,
        ]
    }
}
#endif
