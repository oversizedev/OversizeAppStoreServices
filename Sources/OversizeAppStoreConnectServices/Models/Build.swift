//
// Copyright © 2024 Alexander Romanov
// File.swift, created on 22.07.2024
//  

import AppStoreConnect
import Foundation

public struct Build {
    public let version: String
    public let uploadedDate: Date
    public let expirationDate: Date
    public let iconURL: URL?

    init?(schema: AppStoreConnect.Build) {
        guard let version = schema.attributes?.version,
              let uploadedDate = schema.attributes?.uploadedDate,
              let expirationDate = schema.attributes?.expirationDate
        else { return nil }
        self.version = version
        self.uploadedDate = uploadedDate
        self.expirationDate = expirationDate
        let templateUrl = schema.attributes?.iconAssetToken?.templateURL
        self.iconURL = parseURL(
            from: constructURLString(
                baseURL: templateUrl ?? "",
                width: schema.attributes?.iconAssetToken?.width ?? 100,
                height: schema.attributes?.iconAssetToken?.height ?? 100,
                format: "png"
            )
        )
    }
}

func parseURL(from urlString: String) -> URL? {
    if let url = URL(string: urlString), let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
        if let scheme = components.scheme, let host = components.host {
            if !scheme.isEmpty && !host.isEmpty {
                return url
            }
        }
    }
    return nil
}

func constructURLString(baseURL: String, width: Int, height: Int, format: String) -> String {
    let replacedURL = baseURL.replacingOccurrences(of: "{w}", with: "\(width)")
        .replacingOccurrences(of: "{h}", with: "\(height)")
        .replacingOccurrences(of: "{f}", with: format)
    return replacedURL
}
