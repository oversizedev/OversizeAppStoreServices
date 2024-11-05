//
// Copyright © 2024 Alexander Romanov
// AppStoreCertificate.swift, created on 12.09.2024
//

import Foundation
import Security

public extension KeychainService {
    struct AppStoreCertificate {
        public var issuerId: String
        public var keyId: String
        public var privateKey: String

        public init(issuerId: String, keyId: String, privateKey: String) {
            self.issuerId = issuerId
            self.keyId = keyId
            self.privateKey = privateKey
        }
    }

    func addAppStoreCertificate(_ certificate: AppStoreCertificate, with label: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label
        query[kSecAttrAccount] = certificate.issuerId
        query[kSecAttrService] = certificate.keyId
        query[kSecValueData] = certificate.privateKey.data(using: .utf8)

        do {
            try addItem(query: query)
        } catch {
            return
        }
    }

    func updateAppStoreCertificate(_ certificate: AppStoreCertificate, with label: String) {
        deleteAppStoreCertificate(with: label)
        addAppStoreCertificate(certificate, with: label)
    }

    func getAppStoreCertificate(with label: String) -> AppStoreCertificate? {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label

        var result: [CFString: Any]?

        do {
            result = try findItem(query: query)
        } catch {
            return nil
        }

        if let issuerId = result?[kSecAttrAccount] as? String,
           let keyId = result?[kSecAttrService] as? String,
           let data = result?[kSecValueData] as? Data,
           let privateKey: String = .init(data: data, encoding: .utf8)
        {
            return AppStoreCertificate(
                issuerId: issuerId,
                keyId: keyId,
                privateKey: privateKey
            )
        } else {
            return nil
        }
        return nil
    }

    func deleteAppStoreCertificate(with label: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label

        do {
            try deleteItem(query: query)
        } catch {
            return
        }
    }
}
