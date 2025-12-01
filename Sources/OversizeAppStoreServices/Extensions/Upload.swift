//
// Copyright © 2025 Alexander Romanov
// Upload.swift, created on 02.12.2025
//

import AppStoreConnect
import Foundation

extension AppStoreConnectClient {
    public func upload(
        operation: UploadOperation,
        from data: Data
    ) async throws {
        guard let offset = operation.offset,
              let length = operation.length,
              let urlString = operation.url,
              let url = URL(string: urlString),
              let method = operation.method
        else {
            throw NSError(domain: "UploadError", code: -1)
        }

        let dataChunk = data[offset..<(length + offset)]

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method

        for header in operation.requestHeaders {
            if let name = header.name, let value = header.value {
                urlRequest.setValue(value, forHTTPHeaderField: name)
            }
        }

        let (_, response) = try await URLSession.shared.upload(for: urlRequest, from: dataChunk)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
        }
    }
}
