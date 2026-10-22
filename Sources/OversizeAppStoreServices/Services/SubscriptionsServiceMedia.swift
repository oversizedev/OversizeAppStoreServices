//
// Copyright © 2026 Alexander Romanov
// SubscriptionsServiceMedia.swift, created on 17.10.2026
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore

public extension SubscriptionsService {
    func uploadSubscriptionImage(
        subscriptionId: String,
        fileName: String,
        data: Data,
    ) async -> Result<Void, Error> {
        do {
            let reserveRequest = Resources.v1.subscriptionImages.post(
                .init(
                    data: .init(
                        attributes: .init(fileSize: data.count, fileName: fileName),
                        relationships: .init(subscription: .init(data: .init(id: subscriptionId))),
                    ),
                ),
            )
            let reserved = try await client.send(reserveRequest).data
            do {
                guard let operations = reserved.attributes?.uploadOperations, !operations.isEmpty else {
                    throw NetworkError.noResponse
                }

                try await ASCAssetUpload.upload(data: data, operations: operations, client: client)

                let commitRequest = Resources.v1.subscriptionImages.id(reserved.id).patch(
                    .init(
                        data: .init(
                            id: reserved.id,
                            attributes: .init(sourceFileChecksum: ASCAssetUpload.checksum(for: data), isUploaded: true),
                        ),
                    ),
                )
                _ = try await client.send(commitRequest)
            } catch {
                _ = try? await client.send(Resources.v1.subscriptionImages.id(reserved.id).delete)
                throw error
            }
            return .success(())
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }

    func uploadSubscriptionReviewScreenshot(
        subscriptionId: String,
        fileName: String,
        data: Data,
    ) async -> Result<Void, Error> {
        do {
            let reserveRequest = Resources.v1.subscriptionAppStoreReviewScreenshots.post(
                .init(
                    data: .init(
                        attributes: .init(fileSize: data.count, fileName: fileName),
                        relationships: .init(subscription: .init(data: .init(id: subscriptionId))),
                    ),
                ),
            )
            let reserved = try await client.send(reserveRequest).data
            do {
                guard let operations = reserved.attributes?.uploadOperations, !operations.isEmpty else {
                    throw NetworkError.noResponse
                }

                try await ASCAssetUpload.upload(data: data, operations: operations, client: client)

                let commitRequest = Resources.v1.subscriptionAppStoreReviewScreenshots.id(reserved.id).patch(
                    .init(
                        data: .init(
                            id: reserved.id,
                            attributes: .init(sourceFileChecksum: ASCAssetUpload.checksum(for: data), isUploaded: true),
                        ),
                    ),
                )
                _ = try await client.send(commitRequest)
            } catch {
                _ = try? await client.send(Resources.v1.subscriptionAppStoreReviewScreenshots.id(reserved.id).delete)
                throw error
            }
            return .success(())
        } catch {
            return handleRequestFailure(error: error, replaces: [:])
        }
    }
}
