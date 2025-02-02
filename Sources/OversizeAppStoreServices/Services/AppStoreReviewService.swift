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
        guard let client else { return .failure(.network(type: .unauthorized)) }
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
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppStoreReviewDetailAttachments(versionId: String) async -> Result<[AppStoreReviewAttachment], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
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
        appStoreReviewDetailId: String,
        contactFirstName: String?,
        contactLastName: String?,
        contactPhone: String?,
        contactEmail: String?,
        demoAccountName: String?,
        demoAccountPassword: String?,
        isDemoAccountRequired: Bool?,
        notes: String?
    ) async -> Result<AppStoreReviewDetail, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppStoreReviewDetailUpdateRequest.Data.Attributes = .init(
            contactFirstName: contactFirstName?.isEmpty == true ? nil : contactFirstName,
            contactLastName: contactLastName?.isEmpty == true ? nil : contactLastName,
            contactPhone: contactPhone?.isEmpty == true ? nil : contactPhone,
            contactEmail: contactEmail?.isEmpty == true ? nil : contactEmail,
            demoAccountName: demoAccountName?.isEmpty == true ? nil : demoAccountName,
            demoAccountPassword: demoAccountPassword?.isEmpty == true ? nil : demoAccountPassword,
            isDemoAccountRequired: isDemoAccountRequired,
            notes: notes?.isEmpty == true ? nil : notes
        )

        let requestData: AppStoreReviewDetailUpdateRequest.Data = .init(
            type: .appStoreReviewDetails,
            id: appStoreReviewDetailId,
            attributes: requestAttributes
        )

        let request = Resources.v1.appStoreReviewDetails.id(appStoreReviewDetailId).patch(
            .init(data: requestData)
        )

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

    public func postAppStoreReviewDetail(
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
        guard let client else { return .failure(.network(type: .unauthorized)) }

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
