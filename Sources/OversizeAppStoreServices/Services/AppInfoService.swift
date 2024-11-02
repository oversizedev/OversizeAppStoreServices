//
// Copyright © 2024 Alexander Romanov
// BuildsService_2.swift, created on 30.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeCore
import OversizeModels

public actor AppInfoService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppInfos(appId: String) async -> Result<[AppInfo], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appInfos.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppInfoIncludedCategory(appId: String) async -> Result<[AppInfo], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appInfos.get(include: [.primaryCategory, .secondaryCategory, .ageRatingDeclaration])
        do {
            let responce = try await client.send(request)
            return .success(
                responce.data
                    .compactMap {
                        .init(schema: $0, included: responce.included)
                    })
        } catch {
            return .failure(.network(type: .noResponse))
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
