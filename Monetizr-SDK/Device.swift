//
//  Device.swift
//  Monetizr-v3
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
    
    if !screenIsInPortrait() {
        // Landscape
        return Int(((screenHeight)) * UIScreen.main.scale)
    } else {
        // Portrait
        return Int(((screenWidth)) * UIScreen.main.scale)
    }
}

// Orientation
public func screenIsInPortrait() -> Bool {
    if UIApplication.shared.statusBarOrientation.isPortrait {
        // Portrait
        return true
    } else {
        // Landscape
        return false
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

func countryName() -> String {
    if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: (regionCode() ?? "United States") as String) {
        // Country name was found
        return name
    } else {
        // Country name cannot be found
       return "United States"
    }
}

func deviceIdentifier() -> String {
    return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
}

func localeIdentifier() -> String {
    return NSLocale.current.identifier
}

func timestamp() -> String {
    return String(describing: Date().timeIntervalSince1970)
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
