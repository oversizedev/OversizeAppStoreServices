//
// Copyright © 2024 Alexander Romanov
// FileCache.swift, created on 28.11.2024
//

import Foundation
import OversizeCore

public final class СacheService {
    private let cacheDirectory: URL
    private let cacheExpiration: TimeInterval

    public init(expiration: TimeInterval = 300) { // Default expiration: 5 minutes
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        cacheDirectory = path ?? FileManager.default.temporaryDirectory.appendingPathComponent("Default")
        cacheExpiration = expiration
    }

    private func cacheFilePath(for key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }

    func save(_ data: some Encodable, key: String = #function) {
        let trimmedKey = key.hasSuffix("()") ? String(key.dropLast(2)) : key
        let fileURL = cacheFilePath(for: trimmedKey)
        do {
            let jsonData = try JSONEncoder().encode(data)
            try jsonData.write(to: fileURL, options: .atomic)
            logData("Saved cache: \(key)")
        } catch {
            logError("Failed to save cache for key \(key): \(error)")
        }
    }

    func load<T: Decodable>(key: String = #function, as _: T.Type) -> T? {
        let trimmedKey = key.hasSuffix("()") ? String(key.dropLast(2)) : key
        let fileURL = cacheFilePath(for: trimmedKey)

        guard FileManager.default.fileExists(atPath: fileURL.path),
              isCacheValid(for: fileURL)
        else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            logNotice("Readed cache: \(key)")
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logError("Failed to load cache for key \(key): \(error)")
            return nil
        }
    }

    func remove(for key: String = #function) {
        let trimmedKey = key.hasSuffix("()") ? String(key.dropLast(2)) : key
        let fileURL = cacheFilePath(for: key)
        try? FileManager.default.removeItem(at: fileURL)
    }

    func clearAll() {
        try? FileManager.default.removeItem(at: cacheDirectory)
    }

    private func isCacheValid(for fileURL: URL) -> Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let modificationDate = attributes[.modificationDate] as? Date
        else {
            return false
        }
        return Date().timeIntervalSince(modificationDate) < cacheExpiration
    }
}
