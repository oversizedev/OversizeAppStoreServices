//
// Copyright © 2024 Alexander Romanov
// VersionService.swift, created on 29.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation
import OversizeModels

public actor VersionsService {
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }
    
    public func fetchAllVersionLocalizations(forVersion versionId: String) async throws -> Result<[(String, AppStoreLanguage)], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).appStoreVersionLocalizations.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { localization in
                guard let locale = localization.attributes?.locale, let language = AppStoreLanguage(rawValue: locale) else {
                    return nil
                }
                return (localization.id, language)
            }
            )
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppVersionLocalizations(forVersion versionId: String) async -> Result<[VersionLocalization], AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appStoreVersions.id(versionId).appStoreVersionLocalizations.get()
        do {
            let data = try await client.send(request).data
            return .success(data.compactMap { .init(schema: $0) })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }


    public func patchBuild(platform _: Platform, versionId: String, buildId: String) async -> Result<AppStoreVersion, AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }

        let relationships: AppStoreVersionUpdateRequest.Data.Relationships = .init(
            build: .init(data: .init(type: .builds, id: buildId))
        )

        let requestData: AppStoreVersionUpdateRequest.Data = .init(
            type: .appStoreVersions,
            id: versionId,
            relationships: relationships
        )

        let request = Resources.v1.appStoreVersions.id(versionId).patch(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: AppStoreVersion = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
    
    public func patchVersionLocalization(
        localizationId: String,
        whatsNew: String? = nil,
        description: String? = nil,
        promotionalText: String? = nil,
        keywords: String? = nil,
        marketingURL: URL? = nil,
        supportURL: URL? = nil
    ) async -> Result<VersionLocalization, AppError> {
        guard let client = client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppStoreVersionLocalizationUpdateRequest.Data.Attributes = .init(
            description: description,
            keywords: keywords,
            marketingURL: marketingURL,
            promotionalText: promotionalText,
            supportURL: supportURL,
            whatsNew: whatsNew
        )

        let requestData: AppStoreVersionLocalizationUpdateRequest.Data = .init(
            type: .appStoreVersionLocalizations,
            id: localizationId,
            attributes: requestAttributes
        )

        let request = Resources.v1.appStoreVersionLocalizations.id(localizationId).patch(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: VersionLocalization = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
