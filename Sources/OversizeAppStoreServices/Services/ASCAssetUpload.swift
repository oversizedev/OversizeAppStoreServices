//
// Copyright © 2026 Alexander Romanov
// ASCAssetUpload.swift, created on 17.10.2026
//

import AppStoreAPI
import AppStoreConnect
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
import Foundation

enum ASCAssetUpload {
    static func checksum(for data: Data) -> String {
        var md5 = Insecure.MD5()
        md5.update(data: data)
        return md5.finalize().map { String(format: "%02hhx", $0) }.joined()
    }

    static func upload(
        data: Data,
        operations: [AppStoreAPI.UploadOperation],
        client: AppStoreConnectClient,
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for operation in operations {
                group.addTask {
                    try await client.upload(operation: operation, from: data)
                }
            }
            try await group.waitForAll()
        }
    }
}
