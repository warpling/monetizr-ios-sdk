//
//  CheckoutStatus.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 17/07/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - CheckoutStatus
public struct CheckoutStatus: Codable {
    let status: String
    let message, order_number: String?

    enum CodingKeys: String, CodingKey {
        case status, message, order_number
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
