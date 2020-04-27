//
//  CheckoutAddress.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 08/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

import Foundation

// MARK: - CheckoutAddress
public struct CheckoutAddress: Codable {
    let firstName, lastName, address1: String
    let address2: String?
    let city, country, zip, province: String
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "firstName" : firstName,
            "lastName" : lastName,
            "address1" : address1,
            "address2" : address2 ?? "",
            "city" : city,
            "country" : country,
            "zip" : zip,
            "province" : province
        ]
    }
}

// MARK: CheckoutAddress convenience initializers and mutators

extension CheckoutAddress {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CheckoutAddress.self, from: data)
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
        firstName: String? = nil,
        lastName: String? = nil,
        address1: String? = nil,
        address2: String? = nil,
        city: String? = nil,
        country: String? = nil,
        zip: String? = nil,
        province: String? = nil
    ) -> CheckoutAddress {
        return CheckoutAddress(
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            address1: address1 ?? self.address1,
            address2: address2 ?? self.address2,
            city: city ?? self.city,
            country: country ?? self.country,
            zip: zip ?? self.zip,
            province: province ?? self.province
        )
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
