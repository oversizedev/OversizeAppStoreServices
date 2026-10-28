//
// Copyright © 2026 Alexander Romanov
// TolerantPlacementResponse.swift, created on 27.10.2026
//

import AppStoreAPI
import AppStoreConnect
import Foundation

struct TolerantPlacementResponse<Wrapped: Decodable & Sendable>: Decodable, Sendable {
    let value: Wrapped

    init(from decoder: any Decoder) throws {
        let json = try PlacementJSON(from: decoder).normalizingPlacements()
        let wrappedDecoder = JSONDecoder()
        wrappedDecoder.dateDecodingStrategy = .custom(Self.decodeDate)
        value = try wrappedDecoder.decode(Wrapped.self, from: JSONEncoder().encode(json))
    }

    @Sendable
    private static func decodeDate(with decoder: any Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        let fractional = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        if let date = try? Date(text, strategy: fractional) {
            return date
        }
        if let date = try? Date(text, strategy: .iso8601) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected ISO8601 date, got \(text)")
    }
}

extension Request where Response: Decodable & Sendable {
    var tolerantPlacements: Request<TolerantPlacementResponse<Response>> {
        .init(path: path, baseURL: baseURL, method: method, query: query, body: body, headers: headers, id: id)
    }
}

private enum PlacementJSON: Codable, Sendable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([PlacementJSON])
    case object([String: PlacementJSON])

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([PlacementJSON].self) {
            self = .array(value)
        } else {
            self = .object(try container.decode([String: PlacementJSON].self))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case let .bool(value): try container.encode(value)
        case let .number(value): try container.encode(value)
        case let .string(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        case let .object(value): try container.encode(value)
        }
    }

    func normalizingPlacements() -> PlacementJSON {
        switch self {
        case let .array(items):
            return .array(items.map { $0.normalizingPlacements() })
        case var .object(fields):
            fields = fields.mapValues { $0.normalizingPlacements() }
            guard case .string("appAssetLibraryPlacements")? = fields["type"] else {
                return .object(fields)
            }
            var attributes: [String: PlacementJSON] = [:]
            if case let .object(existing)? = fields["attributes"] {
                attributes = existing
            }
            if case let .string(state)? = attributes["state"],
               AppStoreAPI.AppAssetLibraryPlacementState(rawValue: state) == nil
            {
                attributes["state"] = nil
                fields["attributes"] = .object(attributes)
            }
            if case var .object(relationships)? = fields["relationships"], relationships["mediaType"] == nil {
                relationships["mediaType"] = attributes["mediaType"] ?? .string("IMAGE")
                fields["relationships"] = .object(relationships)
            }
            return .object(fields)
        default:
            return self
        }
    }
}
