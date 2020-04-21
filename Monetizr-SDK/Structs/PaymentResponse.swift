//
//  PaymentResponse.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 24/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - PaymentResponse
public struct PaymentResponse: Codable {
    let status, message, intent: String?
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
