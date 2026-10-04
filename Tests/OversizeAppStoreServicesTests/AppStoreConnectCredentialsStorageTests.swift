//
// Copyright © 2026 Alexander Romanov
// AppStoreConnectCredentialsStorageTests.swift, created on 03.10.2026
//

#if canImport(Darwin)
import Foundation
@testable import OversizeAppStoreServices
import OversizeServices
import Testing

struct AppStoreConnectCredentialsStorageTests {
    private let credentials = AppStoreConnectCredentials(
        issuerID: "issuer",
        keyID: "KEY123",
        privateKey: "-----BEGIN PRIVATE KEY-----\nabc\n-----END PRIVATE KEY-----",
        vendorNumber: "8000000",
    )

    @Test
    func roundTrip() throws {
        let accountID = UUID()
        let otherAccountID = UUID()
        defer {
            try? AppStoreConnectCredentials.remove(for: accountID)
            try? AppStoreConnectCredentials.remove(for: otherAccountID)
        }
        let withoutVendor = AppStoreConnectCredentials(issuerID: "issuer", keyID: "KEY", privateKey: "pem")

        try credentials.save(for: accountID)
        try withoutVendor.save(for: otherAccountID)

        #expect(try AppStoreConnectCredentials.stored(for: accountID) == credentials)
        #expect(try AppStoreConnectCredentials.stored(for: otherAccountID)?.vendorNumber == nil)
    }

    @Test
    func unknownAccountIsNil() throws {
        #expect(try AppStoreConnectCredentials.stored(for: UUID()) == nil)
    }

    @Test
    func deleteRemovesOnlyThatAccount() throws {
        let removed = UUID()
        let kept = UUID()
        defer {
            try? AppStoreConnectCredentials.remove(for: removed)
            try? AppStoreConnectCredentials.remove(for: kept)
        }
        try credentials.save(for: removed)
        try credentials.save(for: kept)

        try AppStoreConnectCredentials.remove(for: removed)

        #expect(try AppStoreConnectCredentials.stored(for: removed) == nil)
        #expect(try AppStoreConnectCredentials.stored(for: kept) == credentials)
    }

    @Test
    func readsItemsWrittenInTheExistingFormat() throws {
        let accountID = UUID()
        defer { try? AppStoreConnectCredentials.remove(for: accountID) }
        let stored = Data(#"{"issuerID":"issuer","keyID":"KEY123","privateKey":"pem","vendorNumber":"8000000"}"#.utf8)
        try Keychain.appStoreConnectCredentials.set(stored, forKey: accountID.uuidString)

        #expect(try AppStoreConnectCredentials.stored(for: accountID) == AppStoreConnectCredentials(
            issuerID: "issuer",
            keyID: "KEY123",
            privateKey: "pem",
            vendorNumber: "8000000",
        ))
    }
}
#endif
