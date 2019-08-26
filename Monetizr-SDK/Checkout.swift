//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 26/08/2019.
//  Copyright © 2019 Monetizr. All rights reserved.

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let checkout = try? newJSONDecoder().decode(Checkout.self, from: jsonData)

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCheckout { response in
//     if let checkout = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Checkout
public struct Checkout: Codable {
    let data: DataClass?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDataClass { response in
//     if let dataClass = response.result.value {
//       ...
//     }
//   }

// MARK: - DataClass
public struct DataClass: Codable {
    let checkoutCreate: CheckoutCreate?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCheckoutCreate { response in
//     if let checkoutCreate = response.result.value {
//       ...
//     }
//   }

// MARK: - CheckoutCreate
public struct CheckoutCreate: Codable {
    let checkoutUserErrors: [CheckoutUserError]?
    let checkout: CheckoutClass?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCheckoutClass { response in
//     if let checkoutClass = response.result.value {
//       ...
//     }
//   }

// MARK: - CheckoutClass
public struct CheckoutClass: Codable {
    let id: String?
    let webURL: String?
    let subtotalPriceV2: V2?
    let taxExempt, taxesIncluded: Bool?
    let totalPriceV2, totalTaxV2: V2?
    let requiresShipping: Bool?
    let availableShippingRates: AvailableShippingRates?
    let shippingLine: JSONNull?
    let lineItems: LineItems?
    
    enum CodingKeys: String, CodingKey {
        case id
        case webURL = "webUrl"
        case subtotalPriceV2, taxExempt, taxesIncluded, totalPriceV2, totalTaxV2, requiresShipping, availableShippingRates, shippingLine, lineItems
    }
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseAvailableShippingRates { response in
//     if let availableShippingRates = response.result.value {
//       ...
//     }
//   }

// MARK: - AvailableShippingRates
public struct AvailableShippingRates: Codable {
    let ready: Bool?
    let shippingRates: [ShippingRate]?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseShippingRate { response in
//     if let shippingRate = response.result.value {
//       ...
//     }
//   }

// MARK: - ShippingRate
public struct ShippingRate: Codable {
    let handle, title: String?
    let priceV2: V2?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseV2 { response in
//     if let v2 = response.result.value {
//       ...
//     }
//   }

// MARK: - V2
public struct V2: Codable {
    let amount, currencyCode: String?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseLineItems { response in
//     if let lineItems = response.result.value {
//       ...
//     }
//   }

// MARK: - LineItems
public struct LineItems: Codable {
    let edges: [Edge]?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseEdge { response in
//     if let edge = response.result.value {
//       ...
//     }
//   }

// MARK: - Edge
public struct Edge: Codable {
    let node: Node?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseNode { response in
//     if let node = response.result.value {
//       ...
//     }
//   }

// MARK: - Node
public struct Node: Codable {
    let title: String?
    let quantity: Int?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCheckoutUserError { response in
//     if let checkoutUserError = response.result.value {
//       ...
//     }
//   }

// MARK: - CheckoutUserError
public struct CheckoutUserError: Codable {
    let field: [String]?
    let message: String?
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

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseCheckout(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Checkout>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public func hash(into hasher: inout Hasher) {
        // No-op
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
