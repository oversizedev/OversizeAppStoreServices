//
// Copyright © 2024 Alexander Romanov
// AppCategoryService.swift, created on 03.11.2024
//  

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
import OversizeModels

public actor AppCategoryService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppCategoryIds(platform: Platform) async -> Result<[String], AppError> {
        guard let appCategoriesPlatform: Resources.V1.AppCategories.FilterPlatforms = .init(rawValue: platform.rawValue) else {
            return .failure(.network(type: .invalidURL))
        }

        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appCategories.get(
            filterPlatforms: [appCategoriesPlatform],
            isExistsParent: false
        )
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { $0.id })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppCategoriesIncludedSubCategories(platform: Platform) async -> Result<[AppCategory], AppError> {
        guard let appCategoriesPlatform: Resources.V1.AppCategories.FilterPlatforms = .init(rawValue: platform.rawValue) else {
            return .failure(.network(type: .invalidURL))
        }

        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appCategories.get(
            filterPlatforms: [appCategoriesPlatform],
            isExistsParent: false,
            include: [.subcategories]
        )

        do {
            let responce = try await client.send(request)
            return .success(
                responce.data
                    .compactMap { .init(schema: $0, included: responce.included)
                    })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
