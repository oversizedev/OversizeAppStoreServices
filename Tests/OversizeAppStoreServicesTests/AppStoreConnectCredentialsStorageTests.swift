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
    private let keychain = Keychain(service: "Tests.OversizeAppStoreServices.Credentials." + UUID().uuidString)
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
            try? AppStoreConnectCredentials.remove(for: accountID, in: keychain)
            try? AppStoreConnectCredentials.remove(for: otherAccountID, in: keychain)
        }
        let withoutVendor = AppStoreConnectCredentials(issuerID: "issuer", keyID: "KEY", privateKey: "pem")

        try credentials.save(for: accountID, in: keychain)
        try withoutVendor.save(for: otherAccountID, in: keychain)

        #expect(try AppStoreConnectCredentials.stored(for: accountID, in: keychain) == credentials)
        #expect(try AppStoreConnectCredentials.stored(for: otherAccountID, in: keychain)?.vendorNumber == nil)
    }

    @Test
    func unknownAccountIsNil() throws {
        #expect(try AppStoreConnectCredentials.stored(for: UUID(), in: keychain) == nil)
    }

    @Test
    func deleteRemovesOnlyThatAccount() throws {
        let removed = UUID()
        let kept = UUID()
        defer {
            try? AppStoreConnectCredentials.remove(for: removed, in: keychain)
            try? AppStoreConnectCredentials.remove(for: kept, in: keychain)
        }
        try credentials.save(for: removed, in: keychain)
        try credentials.save(for: kept, in: keychain)

        try AppStoreConnectCredentials.remove(for: removed, in: keychain)

        #expect(try AppStoreConnectCredentials.stored(for: removed, in: keychain) == nil)
        #expect(try AppStoreConnectCredentials.stored(for: kept, in: keychain) == credentials)
    }

    @Test
    func readsItemsWrittenInTheExistingFormat() throws {
        let accountID = UUID()
        defer { try? AppStoreConnectCredentials.remove(for: accountID, in: keychain) }
        let stored = Data(#"{"issuerID":"issuer","keyID":"KEY123","privateKey":"pem","vendorNumber":"8000000"}"#.utf8)
        try keychain.set(stored, forKey: accountID.uuidString)

        #expect(try AppStoreConnectCredentials.stored(for: accountID, in: keychain) == AppStoreConnectCredentials(
            issuerID: "issuer",
            keyID: "KEY123",
            privateKey: "pem",
            vendorNumber: "8000000",
        ))
    }
}
#endif
