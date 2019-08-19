//
//  Device.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 04/05/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit
import PassKit

// Calculate screen width in Portrait
public func screenWidthPixelsInPortraitOrientation() -> Int {
    let screenRect = UIScreen.main.bounds
    let screenWidth = screenRect.size.width
    let screenHeight = screenRect.size.height
    //let window = UIApplication.shared.keyWindow
    
    if UIDevice.current.orientation.isLandscape {
        // Landscape
        return Int(((screenHeight)) * UIScreen.main.scale)
    } else {
        // Portrait
        return Int(((screenWidth)) * UIScreen.main.scale)
    }
}

// Get Device data
func deviceData() -> Dictionary<String, Any> {
    var dict: Dictionary<String, Any> = [:]
    dict["device_name"] = UIDevice.current.name
    dict["os_version"] = UIDevice.current.systemVersion
    dict["region"] = NSLocale.current.regionCode
    dict["device_identifier"] = deviceIdentifier()
    dict["language"] = Locale.current.languageCode
    dict["apple_pay_status"] = applePayAvailable()
    return dict
}

func regionCode() -> String? {
    return NSLocale.current.regionCode
}

func deviceIdentifier() -> String {
    return UIDevice.current.identifierForVendor!.uuidString
}

// Check if Apple pay is available
public func applePayAvailable() -> Bool{
    return PKPaymentAuthorizationViewController.canMakePayments()
}

public func applePaySupportedPaymentNetworks() -> Array<PKPaymentNetwork> {
    return [.amex, .visa, .masterCard]
}

public func applePayCanMakePayments() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: applePaySupportedPaymentNetworks())
}
