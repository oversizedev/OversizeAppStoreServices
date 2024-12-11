//
// Copyright © 2024 Alexander Romanov
// FileCache.swift, created on 28.11.2024
//

import Foundation
import OversizeCore
import OversizeModels

public actor CacheService {
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

    public func save(_ data: some Encodable, key: String) async {
        let fileURL = cacheFilePath(for: key)
        do {
            let jsonData = try JSONEncoder().encode(data)
            try jsonData.write(to: fileURL, options: .atomic)
            logData("Saved cache: \(key)")
        } catch {
            logError("Failed to save cache for key \(key): \(error)")
        }
    }

    public func load<T: Decodable>(key: String, as _: T.Type) async -> T? {
        let fileURL = cacheFilePath(for: key)
        guard FileManager.default.fileExists(atPath: fileURL.path), await isCacheValid(for: fileURL) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            logNotice("Read cache: \(key)")
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logError("Failed to load cache for key \(key): \(error)")
            return nil
        }
    }

    public func remove(for key: String) async {
        let fileURL = cacheFilePath(for: key)
        try? FileManager.default.removeItem(at: fileURL)
    }

    public func clearAll() async {
        try? FileManager.default.removeItem(at: cacheDirectory)
    }

    private func isCacheValid(for fileURL: URL) async -> Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let modificationDate = attributes[.modificationDate] as? Date
        else {
            return false
        }
        return Date().timeIntervalSince(modificationDate) < cacheExpiration
    }
}

public extension CacheService {
    func fetchWithCache<T: Codable & Sendable>(
        key: String,
        force: Bool = false,
        fetcher: () async throws -> T
    ) async -> Result<T, AppError> {
        if !force {
            if let cachedData: T = await load(key: key, as: T.self) {
                logNotice("Returning cached data for key: \(key)")
                return .success(cachedData)
            }
        }

        do {
            logNetwork(force ? "Force fetching: \(key)" : "Fetching: \(key)")
            let fetchedData = try await fetcher()
            await save(fetchedData, key: key) // Save new data to cache
            return .success(fetchedData)
        } catch let error as AppError {
            logError("Failed to fetch data for key \(key): \(error)")
            return .failure(error)
        } catch {
            logError("Unexpected error during fetch for key \(key): \(error)")
            return .failure(.network(type: .noResponse))
        }
    }
}
