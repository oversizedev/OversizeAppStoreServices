//
// Copyright © 2024 Alexander Romanov
// AppStoreReviewService.swift, created on 31.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeModels

public actor AppStoreReviewService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppStoreReviewDetail(versionId: String) async -> Result<AppStoreReviewDetail, AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).appStoreReviewDetail.get(
            include: [.appStoreReviewAttachments]
        )
        do {
            let data = try await client.send(request).data
            guard let appStoreReviewDetail: AppStoreReviewDetail = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(appStoreReviewDetail)
        } catch {
            print(error)
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppStoreReviewDetailAttachments(versionId: String) async -> Result<[AppStoreReviewAttachment], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreReviewDetails.id(
            versionId
        ).appStoreReviewAttachments.get()

        do {
            let data = try await client.send(request).data
            return .success(data)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func patchAppStoreReviewDetail(
        versionId: String,
        contactFirstName: String?,
        contactLastName: String?,
        contactPhone: String?,
        contactEmail: String?,
        demoAccountName: String?,
        demoAccountPassword: String?,
        isDemoAccountRequired: Bool?,
        notes: String?
    ) async -> Result<AppStoreReviewDetail, AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppStoreReviewDetailCreateRequest.Data.Attributes = .init(
            contactFirstName: contactFirstName,
            contactLastName: contactLastName,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            demoAccountName: demoAccountName,
            demoAccountPassword: demoAccountPassword,
            isDemoAccountRequired: isDemoAccountRequired,
            notes: notes
        )

        let requestData: AppStoreReviewDetailCreateRequest.Data = .init(
            type: .appStoreReviewDetails,
            attributes: requestAttributes,
            relationships: .init(
                appStoreVersion: .init(
                    data: .init(
                        type: .appStoreVersions,
                        id: versionId
                    )
                )
            )
        )

        let request = Resources.v1.appStoreReviewDetails.post(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let appStoreReviewDetail: AppStoreReviewDetail = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(appStoreReviewDetail)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
