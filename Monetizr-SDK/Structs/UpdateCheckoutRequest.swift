//
//  UpdateCheckoutRequest.swift
//
//  Created by Armands Avotins on 06/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let updateCheckoutRequest = try UpdateCheckoutRequest(json)

import Foundation

// MARK: - UpdateCheckoutRequest
public struct UpdateCheckoutRequest: Codable {
    let productHandle, checkoutID, email, shippingRateHandle: String
    let shippingAddress, billingAddress: CheckoutAddress
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "product_handle" : productHandle,
            "checkoutId" : checkoutID,
            "email" : email,
            "shippingRateHandle" : shippingRateHandle,
            "shippingAddress" : shippingAddress.dictionaryRepresentation,
            "billingAddress" : billingAddress.dictionaryRepresentation
        ]
    }

    enum CodingKeys: String, CodingKey {
        case productHandle
        case checkoutID
        case email, shippingRateHandle, shippingAddress, billingAddress
    }
}

// MARK: UpdateCheckoutRequest convenience initializers and mutators

extension UpdateCheckoutRequest {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UpdateCheckoutRequest.self, from: data)
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
        productHandle: String? = nil,
        checkoutID: String? = nil,
        email: String? = nil,
        shippingRateHandle: String? = nil,
        shippingAddress: CheckoutAddress? = nil,
        billingAddress: CheckoutAddress? = nil
    ) -> UpdateCheckoutRequest {
        return UpdateCheckoutRequest(
            productHandle: productHandle ?? self.productHandle,
            checkoutID: checkoutID ?? self.checkoutID,
            email: email ?? self.email,
            shippingRateHandle: shippingRateHandle ?? self.shippingRateHandle,
            shippingAddress: shippingAddress ?? self.shippingAddress,
            billingAddress: billingAddress ?? self.billingAddress
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

