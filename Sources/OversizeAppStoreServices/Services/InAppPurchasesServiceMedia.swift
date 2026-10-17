//
// Copyright © 2026 Alexander Romanov
// InAppPurchasesServiceMedia.swift, created on 17.10.2026
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public extension InAppPurchasesService {
    func uploadInAppPurchaseImage(
        inAppPurchaseId: String,
        fileName: String,
        data: Data,
    ) async -> Result<Void, Error> {
        do {
            let reserveRequest = Resources.v1.inAppPurchaseImages.post(
                .init(
                    data: .init(
                        attributes: .init(fileSize: data.count, fileName: fileName),
                        relationships: .init(inAppPurchase: .init(data: .init(id: inAppPurchaseId))),
                    ),
                ),
            )
            let reserved = try await client.send(reserveRequest).data
            guard let operations = reserved.attributes?.uploadOperations, !operations.isEmpty else {
                return .failure(NetworkError.noResponse)
            }

            try await ASCAssetUpload.upload(data: data, operations: operations, client: client)

            let commitRequest = Resources.v1.inAppPurchaseImages.id(reserved.id).patch(
                .init(
                    data: .init(
                        id: reserved.id,
                        attributes: .init(sourceFileChecksum: ASCAssetUpload.checksum(for: data), isUploaded: true),
                    ),
                ),
            )
            _ = try await client.send(commitRequest)
            return .success(())
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    func uploadInAppPurchaseReviewScreenshot(
        inAppPurchaseId: String,
        fileName: String,
        data: Data,
    ) async -> Result<Void, Error> {
        do {
            let reserveRequest = Resources.v1.inAppPurchaseAppStoreReviewScreenshots.post(
                .init(
                    data: .init(
                        attributes: .init(fileSize: data.count, fileName: fileName),
                        relationships: .init(inAppPurchaseV2: .init(data: .init(id: inAppPurchaseId))),
                    ),
                ),
            )
            let reserved = try await client.send(reserveRequest).data
            guard let operations = reserved.attributes?.uploadOperations, !operations.isEmpty else {
                return .failure(NetworkError.noResponse)
            }

            try await ASCAssetUpload.upload(data: data, operations: operations, client: client)

            let commitRequest = Resources.v1.inAppPurchaseAppStoreReviewScreenshots.id(reserved.id).patch(
                .init(
                    data: .init(
                        id: reserved.id,
                        attributes: .init(sourceFileChecksum: ASCAssetUpload.checksum(for: data), isUploaded: true),
                    ),
                ),
            )
            _ = try await client.send(commitRequest)
            return .success(())
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }
}
