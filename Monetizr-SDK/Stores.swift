//
//  Store.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 28/11/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let stores = try? newJSONDecoder().decode(Stores.self, from: jsonData)

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseStore { response in
//     if let store = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Store
struct Store: Codable {
    let name: String?
    let salesStore: SalesStore?

    enum CodingKeys: String, CodingKey {
        case name
        case salesStore = "sales_store"
    }
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseSalesStore { response in
//     if let salesStore = response.result.value {
//       ...
//     }
//   }

// MARK: - SalesStore
struct SalesStore: Codable {
    let name, domain, shopifyAPIKey: String?

    enum CodingKeys: String, CodingKey {
        case name, domain
        case shopifyAPIKey = "shopify_api_key"
    }
}

typealias Stores = [Store]

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
    func responseStores(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Stores>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

