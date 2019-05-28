//
//  Product.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 24/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//
// To parse the JSON do:
//
//   let product = try? newJSONDecoder().decode(Product.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseProduct { response in
//     if let product = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

struct Product: Codable {
    let data: ProductDataClass?
}

struct ProductDataClass: Codable {
    let productByHandle: ProductByHandle?
}

struct ProductByHandle: Codable {
    let id, title, description, description_ios, descriptionHTML: String?
    let availableForSale: Bool?
    let onlineStoreURL: String?
    let images: Images?
    let variants: Variants?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, description_ios
        case descriptionHTML = "descriptionHtml"
        case availableForSale
        case onlineStoreURL = "onlineStoreUrl"
        case images, variants
    }
}

struct Images: Codable {
    let edges: [ImagesEdge]?
}

struct ImagesEdge: Codable {
    let node: ImageClass?
}

struct ImageClass: Codable {
    let transformedSrc: String?
}

struct Variants: Codable {
    let edges: [VariantsEdge]?
}

struct VariantsEdge: Codable {
    let node: PurpleNode?
}

struct PurpleNode: Codable {
    let id: String?
    let product: ProductClass?
    let title: String?
    let selectedOptions: [SelectedOption]?
    let priceV2: PriceV2?
    let image: ImageClass?
}

struct PriceV2: Codable {
    let currencyCode, currency, amount: String?
}

struct ProductClass: Codable {
    let title, description, description_ios, descriptionHTML: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description, description_ios
        case descriptionHTML = "descriptionHtml"
    }
}

struct SelectedOption: Codable {
    let name, value: String?
}

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
    func responseProduct(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Product>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
