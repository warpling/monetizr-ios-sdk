//
//  Device.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 04/05/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

// Calculate screen width in Portrait
func screenWidthPixelsInPortraitOrientation() -> Int {
    let window = UIApplication.shared.keyWindow
    if UIDevice.current.orientation.isLandscape {
        // Landscape
        return Int(((window?.frame.size.height)!) * UIScreen.main.scale)
    } else {
        // Portrait
        return Int(((window?.frame.size.width)!) * UIScreen.main.scale)
    }
}

// Get Device data
func deviceData() -> Dictionary<String, String> {
    var dict: Dictionary<String, String> = [:]
    dict["device_name"] = UIDevice.current.name
    dict["os_version"] = UIDevice.current.systemVersion
    dict["region"] = NSLocale.current.regionCode
    dict["device_identifier"] = UIDevice.current.identifierForVendor?.uuidString
    dict["language"] = Locale.current.languageCode
    return dict
}
