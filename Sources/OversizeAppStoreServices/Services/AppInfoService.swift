//
// Copyright © 2024 Alexander Romanov
// AppInfoService.swift, created on 30.10.2024
//

import AppStoreAPI
import AppStoreConnect
import Foundation

public actor AppInfoService {
    private let cacheService: CacheService
    private let client: AppStoreConnectClient

    public init(authenticator: some AppStoreConnect.Authenticator, cacheService: CacheService = CacheService()) {
        self.client = AppStoreConnectClient(authenticator: authenticator)
        self.cacheService = cacheService
    }

    public func fetchAppInfos(appId: String, force: Bool = false) async -> Result<[AppInfo], Error> {

        return await cacheService.fetchWithCache(key: "fetchAppInfos\(appId)", force: force) {
            let request = Resources.v1.apps.id(appId).appInfos.get()
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchAppInfoIncludedCategory(appId: String) async -> Result<[AppInfo], Error> {

        let request = Resources.v1.apps.id(appId).appInfos.get(include: [.primaryCategory, .secondaryCategory, .ageRatingDeclaration])
        do {
            let responce = try await client.send(request)
            return .success(responce.data.compactMap {
                .init(schema: $0, included: responce.included)
            })
        } catch {
            return .failure(error.asNetworkError)
        }
    }

    public func fetchAppInfoLocalizations(appInfoId: String, force: Bool = false) async -> Result<[AppInfoLocalization], Error> {

        return await cacheService.fetchWithCache(key: "fetchAppInfoLocalizations\(appInfoId)", force: force) {
            let request = Resources.v1.appInfos.id(appInfoId).appInfoLocalizations.get()
            return try await client.send(request).data
        }.map { data in
            data.compactMap { .init(schema: $0) }
        }
    }

    public func fetchAppInfoLocalization(appInfoId: String, locale: AppStoreLanguage) async -> Result<AppInfoLocalization, Error> {

        let request = Resources.v1.appInfos.id(appInfoId).appInfoLocalizations.get(
            filterLocale: [locale.rawValue],
        )
        do {
            let data = try await client.send(request).data
            guard let firstDataItem = data.first, let appInfoLocalization: AppInfoLocalization = .init(schema: firstDataItem) else {
                return .failure(NetworkError.decode)
            }
            return .success(appInfoLocalization)
        } catch {
            return .failure(error.asNetworkError)
        }
    }

    public func patchAgeRatingDeclarations(
        ageRatingDeclarationId: String,
        alcoholTobaccoOrDrugUseOrReferences: AgeRatingDeclarationUpdateRequest.Data.Attributes.AlcoholTobaccoOrDrugUseOrReferences?,
        contests: AgeRatingDeclarationUpdateRequest.Data.Attributes.Contests?,
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
        koreaAgeRatingOverride: AgeRatingDeclarationUpdateRequest.Data.Attributes.KoreaAgeRatingOverride?,
    ) async -> Result<AgeRatingDeclaration, Error> {


        let requestAttributes: AgeRatingDeclarationUpdateRequest.Data.Attributes = .init(
            alcoholTobaccoOrDrugUseOrReferences: alcoholTobaccoOrDrugUseOrReferences,
            contests: contests,
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
            koreaAgeRatingOverride: koreaAgeRatingOverride,
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
                return .failure(NetworkError.decode)
            }
            return .success(ageRatingDeclaration)
        } catch {
            return .failure(error.asNetworkError)
        }
    }

    public func patchAppInfoLocalization(
        localizationId: String,
        name: String? = nil,
        subtitle: String? = nil,
        privacyPolicyURL: URL? = nil,
        privacyChoicesURL: URL? = nil,
        privacyPolicyText: String? = nil,
    ) async -> Result<AppInfoLocalization, Error> {


        let requestAttributes: AppInfoLocalizationUpdateRequest.Data.Attributes = .init(
            name: name,
            subtitle: subtitle,
            privacyPolicyURL: privacyPolicyURL?.absoluteString,
            privacyChoicesURL: privacyChoicesURL?.absoluteString,
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
                return .failure(NetworkError.decode)
            }
            return .success(versionLocalization)
        } catch {
            return .failure(error.asNetworkError)
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
    ) async -> Result<AppInfoLocalization, Error> {


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
                return .failure(NetworkError.decode)
            }
            return .success(versionLocalization)
        } catch {
            return .failure(error.asNetworkError)
        }
    }
}
