//
// Copyright © 2024 Alexander Romanov
// AppCategoryService.swift, created on 03.11.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public actor AppCategoryService {
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
    }

    public func fetchAppCategoryIds(platform: Platform) async -> Result<[String], Error> {
        guard let appCategoriesPlatform: Resources.V1.AppCategories.FilterPlatforms = .init(rawValue: platform.rawValue) else {
            return .failure(NetworkError.invalidURL)
        }


        let request = Resources.v1.appCategories.get(
            filterPlatforms: [appCategoriesPlatform],
            isExistsParent: false,
        )
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { $0.id })
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func fetchAppCategoriesIncludedSubCategories(platform: Platform) async -> Result<[AppCategory], Error> {
        guard let appCategoriesPlatform: Resources.V1.AppCategories.FilterPlatforms = .init(rawValue: platform.rawValue) else {
            return .failure(NetworkError.invalidURL)
        }


        let request = Resources.v1.appCategories.get(
            filterPlatforms: [appCategoriesPlatform],
            isExistsParent: false,
            include: [.subcategories],
        )

        do {
            let responce = try await client.send(request)
            return .success(
                responce.data
                    .compactMap { .init(schema: $0, included: responce.included)
                    },
            )
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }

    public func patchAppCategories(
        appInfoId: String,
        primaryCategoryId: String? = nil,
        primarySubcategoryOneId: String? = nil,
        primarySubcategoryTwoId: String? = nil,
        secondaryCategoryId: String? = nil,
        secondarySubcategoryOneId: String? = nil,
        secondarySubcategoryTwoId: String? = nil,
    ) async -> Result<AppInfo, Error> {


        let primaryCategory: AppInfoUpdateRequest.Data.Relationships.PrimaryCategory? = primaryCategoryId != nil ? .init(data: .init(id: primaryCategoryId!)) : nil
        let primarySubcategoryOne: AppInfoUpdateRequest.Data.Relationships.PrimarySubcategoryOne? = primarySubcategoryOneId != nil ? .init(data: .init(id: primarySubcategoryOneId!)) : nil
        let primarySubcategoryTwo: AppInfoUpdateRequest.Data.Relationships.PrimarySubcategoryTwo? = primarySubcategoryTwoId != nil ? .init(data: .init(id: primarySubcategoryTwoId!)) : nil
        let secondaryCategory: AppInfoUpdateRequest.Data.Relationships.SecondaryCategory? = secondaryCategoryId != nil ? .init(data: .init(id: secondaryCategoryId!)) : nil
        let secondarySubcategoryOne: AppInfoUpdateRequest.Data.Relationships.SecondarySubcategoryOne? = secondarySubcategoryOneId != nil ? .init(data: .init(id: secondarySubcategoryOneId!)) : nil
        let secondarySubcategoryTwo: AppInfoUpdateRequest.Data.Relationships.SecondarySubcategoryTwo? = secondarySubcategoryTwoId != nil ? .init(data: .init(id: secondarySubcategoryTwoId!)) : nil

        let requestRelationships: AppInfoUpdateRequest.Data.Relationships = .init(
            primaryCategory: primaryCategory,
            primarySubcategoryOne: primarySubcategoryOne,
            primarySubcategoryTwo: primarySubcategoryTwo,
            secondaryCategory: secondaryCategory,
            secondarySubcategoryOne: secondarySubcategoryOne,
            secondarySubcategoryTwo: secondarySubcategoryTwo,
        )

        let requestData: AppInfoUpdateRequest.Data = .init(
            type: .appInfos,
            id: appInfoId,
            relationships: requestRelationships,
        )

        let request = Resources.v1.appInfos.id(appInfoId).patch(
            .init(data: requestData),
        )

        do {
            let data = try await client.send(request).data
            guard let appStoreReviewDetail: AppInfo = .init(schema: data) else {
                return .failure(NetworkError.decode)
            }
            return .success(appStoreReviewDetail)
        } catch {
            return .failure(NetworkError.noResponse)
        }
    }
}
