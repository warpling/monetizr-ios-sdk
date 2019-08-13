//
//  ApplePay.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 12/08/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import PassKit

// Check if Apple pay is available
public func applePayAvailable() -> Bool{
    return PKPaymentAuthorizationViewController.canMakePayments()
}

public func applePayCanMakePayments() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.amex, .visa, .masterCard])
}
