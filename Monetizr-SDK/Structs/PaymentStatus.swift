//
//  PaymentStatus.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 29/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let paymentStatus = try? newJSONDecoder().decode(PaymentStatus.self, from: jsonData)

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responsePaymentStatus { response in
//     if let paymentStatus = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - PaymentStatus
public struct PaymentStatus: Codable {
    let status, message, payment_status: String
    let paid: Bool

    enum CodingKeys: String, CodingKey {
        case status, message
        case payment_status
        case paid
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
    func responsePaymentStatus(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<PaymentStatus>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
