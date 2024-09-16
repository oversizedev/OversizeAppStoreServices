//
// Copyright © 2022 Alexander Romanov
// SecureStorageService.swift
//

import Foundation
import OversizeCore
import Security

public final class SecureStorageService {
    enum KeychainError: Error {
        case itemAlreadyExist
        case itemNotFound
        case errorStatus(String?)

        init(status: OSStatus) {
            switch status {
            case errSecDuplicateItem:
                self = .itemAlreadyExist
            case errSecItemNotFound:
                self = .itemNotFound
            default:
                let message = SecCopyErrorMessageString(status, nil) as String?
                self = .errorStatus(message)
            }
        }
    }

    func addItem(query: [CFString: Any]) throws {
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    func findItem(query: [CFString: Any]) throws -> [CFString: Any]? {
        var query = query
        query[kSecReturnAttributes] = kCFBooleanTrue
        query[kSecReturnData] = kCFBooleanTrue

        var searchResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &searchResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }

        if status != errSecSuccess {
            throw KeychainError(status: status)
        } else {
            return searchResult as? [CFString: Any]
        }
    }

    func updateItem(query: [CFString: Any], attributesToUpdate: [CFString: Any]) throws {
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    func deleteItem(query: [CFString: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    public func deleteAll() throws {
        let status = SecItemDelete([kSecClass: kSecClassGenericPassword] as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
}
