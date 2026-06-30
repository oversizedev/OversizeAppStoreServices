//
// Copyright © 2024 Alexander Romanov
// FileCache.swift, created on 28.11.2024
//

import Foundation

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
        } catch {
            print("CacheService: Failed to save cache for key \(key): \(error)")
        }
    }

    public func load<T: Decodable>(key: String, as _: T.Type) async -> T? {
        let fileURL = cacheFilePath(for: key)
        guard FileManager.default.fileExists(atPath: fileURL.path), await isCacheValid(for: fileURL) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("CacheService: Failed to load cache for key \(key): \(error)")
            return nil
        }
    }

    public func remove(for key: String) async {
        let fileURL = cacheFilePath(for: key)
        try? FileManager.default.removeItem(at: fileURL)
    }

    public func clearAll() async {
        do {
            if FileManager.default.fileExists(atPath: cacheDirectory.path) {
                try FileManager.default.removeItem(at: cacheDirectory)
            }

            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        } catch {
            print("CacheService: Failed to clear cache: \(error)")
        }
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
        fetcher: @Sendable () async throws -> T,
    ) async -> Result<T, Error> {
        if !force {
            if let cachedData: T = await load(key: key, as: T.self) {
                return .success(cachedData)
            }
        }

        do {
            let fetchedData = try await fetcher()
            await save(fetchedData, key: key)
            return .success(fetchedData)
        } catch {
            let mapped = error.asNetworkError
            return .failure(mapped)
        }
    }
}
