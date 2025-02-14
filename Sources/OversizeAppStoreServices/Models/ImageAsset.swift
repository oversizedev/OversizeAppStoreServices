//
// Copyright © 2025 Alexander Romanov
// ImageAsset.swift, created on 17.01.2025
//

import AppStoreAPI
import Foundation

public struct ImageAsset: Sendable {
    public let templateURL: String?
    public let width: Int?
    public let height: Int?
    public let imageURL: URL?

    public init(schema: AppStoreAPI.ImageAsset) {
        templateURL = schema.templateURL
        width = schema.width
        height = schema.height

        let constructedURLString = ImageAsset.constructURLString(
            baseURL: schema.templateURL ?? "",
            width: schema.width ?? 100,
            height: schema.height ?? 100,
            format: "png"
        )
        imageURL = ImageAsset.parseURL(from: constructedURLString)
    }
}

extension ImageAsset {
    static func parseURL(from urlString: String) -> URL? {
        if let url = URL(string: urlString), let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            if let scheme = components.scheme, let host = components.host {
                if !scheme.isEmpty, !host.isEmpty {
                    return url
                }
            }
        }
        return nil
    }

    static func constructURLString(baseURL: String, width: Int, height: Int, format: String) -> String {
        let replacedURL = baseURL.replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
            .replacingOccurrences(of: "{f}", with: format)
        return replacedURL
    }
}
