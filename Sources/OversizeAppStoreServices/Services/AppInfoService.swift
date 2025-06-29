//
// Copyright © 2024 Alexander Romanov
// AppInfoService.swift, created on 30.10.2024
//

import AppStoreAPI
import AppStoreConnect
import FactoryKit
import Foundation
import OversizeCore
import OversizeModels

public actor AppInfoService {
    @Injected(\.cacheService) private var cacheService: CacheService
    private let client: AppStoreConnectClient?

    public init() {
        do {
            client = try AppStoreConnectClient(authenticator: EnvAuthenticator())
        } catch {
            client = nil
        }
    }

    public func fetchAppInfos(appId: String, force: Bool = false) async -> Result<[AppInfo], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppInfos\(appId)", force: force) {
            let request = Resources.v1.apps.id(appId).appInfos.get()
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchAppInfoIncludedCategory(appId: String) async -> Result<[AppInfo], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.apps.id(appId).appInfos.get(include: [.primaryCategory, .secondaryCategory, .ageRatingDeclaration])
        do {
            let responce = try await client.send(request)
            return .success(responce.data.compactMap {
                .init(schema: $0, included: responce.included)
            })
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func fetchAppInfoLocalizations(appInfoId: String, force: Bool = false) async -> Result<[AppInfoLocalization], AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        return await cacheService.fetchWithCache(key: "fetchAppInfoLocalizations\(appInfoId)", force: force) {
            let request = Resources.v1.appInfos.id(appInfoId).appInfoLocalizations.get()
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchAppInfoLocalization(appInfoId: String, locale: String) async -> Result<AppInfoLocalization?, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }
        let request = Resources.v1.appInfos.id(appInfoId).appInfoLocalizations.get(
            filterLocale: [locale],
        )
        do {
            let data = try await client.send(request).data
            guard let firstDataItem = data.first, let appInfoLocalization: AppInfoLocalization = .init(schema: firstDataItem) else {
                return .failure(.network(type: .decode))
            }
            return .success(appInfoLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func patchAgeRatingDeclarations(
        ageRatingDeclarationId: String,
        alcoholTobaccoOrDrugUseOrReferences: AgeRatingDeclarationUpdateRequest.Data.Attributes.AlcoholTobaccoOrDrugUseOrReferences?,
        contests: AgeRatingDeclarationUpdateRequest.Data.Attributes.Contests?,
        isGamblingAndContests: Bool?,
        isGambling: Bool?,
        gamblingSimulated: AgeRatingDeclarationUpdateRequest.Data.Attributes.GamblingSimulated?,
        kidsAgeBand: AppStoreAPI.KidsAgeBand?,
        isLootBox: Bool?,
        medicalOrTreatmentInformation: AgeRatingDeclarationUpdateRequest.Data.Attributes.MedicalOrTreatmentInformation?,
        profanityOrCrudeHumor: AgeRatingDeclarationUpdateRequest.Data.Attributes.ProfanityOrCrudeHumor?,
        sexualContentGraphicAndNudity: AgeRatingDeclarationUpdateRequest.Data.Attributes.SexualContentGraphicAndNudity?,
        sexualContentOrNudity: AgeRatingDeclarationUpdateRequest.Data.Attributes.SexualContentOrNudity?,
        horrorOrFearThemes: AgeRatingDeclarationUpdateRequest.Data.Attributes.HorrorOrFearThemes?,
        matureOrSuggestiveThemes: AgeRatingDeclarationUpdateRequest.Data.Attributes.MatureOrSuggestiveThemes?,
        isUnrestrictedWebAccess: Bool?,
        violenceCartoonOrFantasy: AgeRatingDeclarationUpdateRequest.Data.Attributes.ViolenceCartoonOrFantasy?,
        violenceRealisticProlongedGraphicOrSadistic: AgeRatingDeclarationUpdateRequest.Data.Attributes.ViolenceRealisticProlongedGraphicOrSadistic?,
        violenceRealistic: AgeRatingDeclarationUpdateRequest.Data.Attributes.ViolenceRealistic?,
        ageRatingOverride: AgeRatingDeclarationUpdateRequest.Data.Attributes.AgeRatingOverride?,
        koreaAgeRatingOverride: AgeRatingDeclarationUpdateRequest.Data.Attributes.KoreaAgeRatingOverride?,
        isSeventeenPlus: Bool?,
    ) async -> Result<AgeRatingDeclaration, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AgeRatingDeclarationUpdateRequest.Data.Attributes = .init(
            alcoholTobaccoOrDrugUseOrReferences: alcoholTobaccoOrDrugUseOrReferences,
            contests: contests,
            isGamblingAndContests: isGamblingAndContests,
            isGambling: isGambling,
            gamblingSimulated: gamblingSimulated,
            kidsAgeBand: kidsAgeBand,
            isLootBox: isLootBox,
            medicalOrTreatmentInformation: medicalOrTreatmentInformation,
            profanityOrCrudeHumor: profanityOrCrudeHumor,
            sexualContentGraphicAndNudity: sexualContentGraphicAndNudity,
            sexualContentOrNudity: sexualContentOrNudity,
            horrorOrFearThemes: horrorOrFearThemes,
            matureOrSuggestiveThemes: matureOrSuggestiveThemes,
            isUnrestrictedWebAccess: isUnrestrictedWebAccess,
            violenceCartoonOrFantasy: violenceCartoonOrFantasy,
            violenceRealisticProlongedGraphicOrSadistic: violenceRealisticProlongedGraphicOrSadistic,
            violenceRealistic: violenceRealistic,
            ageRatingOverride: ageRatingOverride,
            koreaAgeRatingOverride: koreaAgeRatingOverride,
            isSeventeenPlus: isSeventeenPlus,
        )

        let requestData: AgeRatingDeclarationUpdateRequest.Data = .init(
            type: .ageRatingDeclarations,
            id: ageRatingDeclarationId,
            attributes: requestAttributes,
        )

        let request = Resources.v1.ageRatingDeclarations.id(ageRatingDeclarationId).patch(
            .init(data: requestData),
        )

        do {
            let data = try await client.send(request).data
            guard let ageRatingDeclaration: AgeRatingDeclaration = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(ageRatingDeclaration)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func patchAppInfoLocalization(
        localizationId: String,
        name: String? = nil,
        subtitle: String? = nil,
        privacyPolicyURL: String? = nil,
        privacyChoicesURL: String? = nil,
        privacyPolicyText: String? = nil,
    ) async -> Result<AppInfoLocalization, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppInfoLocalizationUpdateRequest.Data.Attributes = .init(
            name: name,
            subtitle: subtitle,
            privacyPolicyURL: privacyPolicyURL,
            privacyChoicesURL: privacyChoicesURL,
            privacyPolicyText: privacyPolicyText,
        )

        let requestData: AppInfoLocalizationUpdateRequest.Data = .init(
            type: .appInfoLocalizations,
            id: localizationId,
            attributes: requestAttributes,
        )

        let request = Resources.v1.appInfoLocalizations.id(localizationId).patch(
            .init(data: requestData),
        )

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: AppInfoLocalization = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }

    public func postAppInfoLocalization(
        appInfoId: String,
        language: AppStoreLanguage,
        name: String,
        subtitle: String? = nil,
        privacyPolicyURL: String? = nil,
        privacyChoicesURL: String? = nil,
        privacyPolicyText: String? = nil,
    ) async -> Result<AppInfoLocalization, AppError> {
        guard let client else { return .failure(.network(type: .unauthorized)) }

        let requestAttributes: AppInfoLocalizationCreateRequest.Data.Attributes = .init(
            locale: language.rawValue,
            name: name,
            subtitle: subtitle,
            privacyPolicyURL: privacyPolicyURL,
            privacyChoicesURL: privacyChoicesURL,
            privacyPolicyText: privacyPolicyText,
        )

        let requestData: AppInfoLocalizationCreateRequest.Data = .init(
            type: .appInfoLocalizations,
            attributes: requestAttributes,
            relationships: .init(
                appInfo: .init(data: .init(
                    type: .appInfos,
                    id: appInfoId,
                )),
            ),
        )
        let request = Resources.v1.appInfoLocalizations.post(.init(data: requestData))

        do {
            let data = try await client.send(request).data
            guard let versionLocalization: AppInfoLocalization = .init(schema: data) else {
                return .failure(.network(type: .decode))
            }
            return .success(versionLocalization)
        } catch {
            return .failure(.network(type: .noResponse))
        }
    }
}
