//
//  CountryCatalog.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 14/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

import Foundation

// MARK: - CountryCatalogElement
public struct CountryCatalogElement: Codable {
    let countryName, countryShortCode: String
    let regions: [Region]
}

// MARK: CountryCatalogElement convenience initializers and mutators

extension CountryCatalogElement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CountryCatalogElement.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        countryName: String? = nil,
        countryShortCode: String? = nil,
        regions: [Region]? = nil
    ) -> CountryCatalogElement {
        return CountryCatalogElement(
            countryName: countryName ?? self.countryName,
            countryShortCode: countryShortCode ?? self.countryShortCode,
            regions: regions ?? self.regions
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Region
public struct Region: Codable {
    let name: String
    let shortCode: String?
}

// MARK: Region convenience initializers and mutators

extension Region {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Region.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        name: String? = nil,
        shortCode: String?? = nil
    ) -> Region {
        return Region(
            name: name ?? self.name,
            shortCode: shortCode ?? self.shortCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

typealias CountryCatalog = [CountryCatalogElement]

extension Array where Element == CountryCatalog.Element {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CountryCatalog.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

fileprivate func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

fileprivate func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

