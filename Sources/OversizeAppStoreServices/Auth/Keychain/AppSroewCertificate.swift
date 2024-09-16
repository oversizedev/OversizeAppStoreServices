//
// Copyright © 2024 Alexander Romanov
// AppStoreCertificate.swift, created on 12.09.2024
//

import Security
import Foundation

public extension SecureStorageService {
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
        
        let combinedData = "\(certificate.keyId):\(certificate.privateKey)"
        query[kSecValueData] = combinedData.data(using: .utf8)
        
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
           let data = result?[kSecValueData] as? Data,
           let combinedString = String(data: data, encoding: .utf8) {
            let components = combinedString.split(separator: ":")
            if components.count == 2 {
                let keyId = String(components[0])
                let privateKey = String(components[1])
                return AppStoreCertificate(issuerId: issuerId, keyId: keyId, privateKey: privateKey)
            }
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
