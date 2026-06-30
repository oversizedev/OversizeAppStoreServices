//
// Copyright © 2024 Alexander Romanov
// AppScreenshotsService.swift, created on 20.11.2024
//

import AppStoreAPI
import AppStoreConnect
import CryptoKit
import Foundation
import OversizeCore

public actor AppScreenshotsService {
    private let cacheService: CacheService
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator, cacheService: CacheService = CacheService()) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
        self.cacheService = cacheService
    }

    public func fetchAppScreenshotSets(
        localizationId: String,
        screenshotDisplayType: ScreenshotDisplayType? = nil,
        force: Bool = false,
    ) async -> Result<[AppScreenshotSet], Error> {


        let cacheKey = "fetchScreenshotSets\(localizationId)\(screenshotDisplayType?.rawValue ?? "")"

        return await cacheService.fetchWithCache(key: cacheKey, force: force) {
            let request = Resources.v1.appStoreVersionLocalizations.id(localizationId).appScreenshotSets.get(include: [.appScreenshots])
            return try await client.send(request)
        }.flatMap {
            let sets = AppScreenshotSet.from(response: $0)
            if let displayType = screenshotDisplayType {
                let filtered = sets.filter { $0.screenshotDisplayType == displayType }
                return .success(filtered)
            }
            return .success(sets)
        }
    }

    public func postAppScreenshotSet(
        localizationId: String,
        screenshotDisplayType: ScreenshotDisplayType,
    ) async -> Result<AppScreenshotSet, Error> {


        do {
            let request = Resources.v1.appScreenshotSets.post(
                .init(
                    data: .init(
                        type: .appScreenshotSets,
                        attributes: .init(screenshotDisplayType: screenshotDisplayType.schema),
                        relationships: .init(
                            appStoreVersionLocalization: .init(
                                data: .init(
                                    type: .appStoreVersionLocalizations,
                                    id: localizationId,
                                ),
                            ),
                        ),
                    ),
                ),
            )

            let response = try await client.send(request)
            let screenshotSet = AppScreenshotSet(schema: response.data)
            return .success(screenshotSet)
        } catch {
            print("AppScreenshotsService error: \(error.localizedDescription)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func deleteScreenshotSet(id: String) async -> Result<Void, Error> {


        do {
            let request = Resources.v1.appScreenshotSets.id(id).delete
            _ = try await client.send(request)
            return .success(())
        } catch {
            print("AppScreenshotsService error: \(error.localizedDescription)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func reserveAppScreenshot(
        screenshotSetId: String,
        fileName: String,
        fileSize: Int,
    ) async -> Result<AppScreenshot, Error> {


        do {
            let request = Resources.v1.appScreenshots.post(
                .init(
                    data: .init(
                        type: .appScreenshots,
                        attributes: .init(
                            fileSize: fileSize,
                            fileName: fileName,
                        ),
                        relationships: .init(
                            appScreenshotSet: .init(
                                data: .init(
                                    type: .appScreenshotSets,
                                    id: screenshotSetId,
                                ),
                            ),
                        ),
                    ),
                ),
            )

            let response = try await client.send(request)
            let screenshot = AppScreenshot(schema: response.data)
            return .success(screenshot)
        } catch {
            print("AppScreenshotsService error: \(error.localizedDescription)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func uploadAppScreenshot(
        fileData: Data,
        uploadOperations: [UploadOperation],
    ) async -> Result<Void, Error> {


        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for operation in uploadOperations {
                    group.addTask { [client] in
                        try await client.upload(operation: operation, from: fileData)
                    }
                }
                try await group.waitForAll()
            }
            return .success(())
        } catch {
            print("AppScreenshotsService error: \(error.localizedDescription)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func commitAppScreenshot(
        screenshotId: String,
        sourceFileChecksum: String,
    ) async -> Result<AppScreenshot, Error> {


        do {
            let request = Resources.v1.appScreenshots.id(screenshotId)
                .patch(
                    .init(
                        data: .init(
                            type: .appScreenshots,
                            id: screenshotId,
                            attributes: .init(
                                sourceFileChecksum: sourceFileChecksum,
                                isUploaded: true,
                            ),
                        ),
                    ),
                )

            let response = try await client.send(request)
            let screenshot = AppScreenshot(schema: response.data)
            return .success(screenshot)
        } catch {
            print("AppScreenshotsService error: \(error.localizedDescription)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func deleteAppScreenshot(id: String) async -> Result<Void, Error> {


        do {
            let request = Resources.v1.appScreenshots.id(id).delete
            _ = try await client.send(request)
            return .success(())
        } catch {
            print("AppScreenshotsService error: \(error.localizedDescription)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func updateScreenshotOrder(
        screenshotSetId: String,
        screenshotIds: [String],
    ) async -> Result<Void, Error> {


        do {
            let relationships: [AppStoreAPI.AppScreenshotSetAppScreenshotsLinkagesRequest.Datum] = screenshotIds.map {
                .init(type: .appScreenshots, id: $0)
            }

            let request = Resources.v1.appScreenshotSets.id(screenshotSetId)
                .relationships.appScreenshots
                .patch(.init(data: relationships))

            _ = try await client.send(request)
            return .success(())
        } catch {
            print("AppScreenshotsService error: \(error.localizedDescription)")
            return .failure(NetworkError.noResponse)
        }
    }

    public func calculateChecksum(for data: Data) -> String {
        var md5 = Insecure.MD5()
        md5.update(data: data)
        let digest = md5.finalize()
        return digest.description
    }
}
