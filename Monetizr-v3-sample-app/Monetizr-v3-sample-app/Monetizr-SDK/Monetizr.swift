//
//  Monetizr.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 20/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Monetizr {
    
    static let shared = Monetizr(token: "")
    
    var token: String
    var language: String?
    let apiUrl = "https://api3.themonetizr.com/api/"
    var headers: HTTPHeaders = [:]
    var dateSessionStarted: Date = Date()
    var dateSessionEnded: Date = Date()
    var impressionCountInSession: Int = 0
    
    // Initialization
    private init(token: String) {
        self.token = token
        DispatchQueue.main.async { self.createHeaders() }
        DispatchQueue.main.async { self.trackAppVersion() }
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appTerminated), name: UIApplication.willTerminateNotification, object: nil)
        DispatchQueue.main.async { self.appMovedToForeground() }
        DispatchQueue.main.async { self.devicedataCreate() { success, error, value in ()} }
    }
    
    // Create headers
    func createHeaders() {
        headers["Authorization"] = "Bearer "+token
    }
    
    // Set language
    func setLanguage(language: String) {
        self.language = language
    }
    
    // Application become active
    @objc func appMovedToForeground() {
        dateSessionStarted = Date()
    }
    
    // Application resign active
    @objc func appMovedToBackground() {
        impressionCountInSession = 0
        dateSessionEnded = Date()
        sessionEnd(deviceIdentifier: deviceIdentifier(), startDate: stringFromDate(date: dateSessionStarted), endDate: stringFromDate(date: dateSessionEnded), completionHandler: { success, error, value in ()})
    }
    
    // Application resign active
    @objc func appTerminated() {
        impressionCountInSession = 0
        dateSessionEnded = Date()
        sessionEnd(deviceIdentifier: deviceIdentifier(), startDate: stringFromDate(date: dateSessionStarted), endDate: stringFromDate(date: dateSessionEnded), completionHandler: { success, error, value in ()})
    }
    
    // Update imprssion count
    func increaseImpressionCount() {
        impressionCountInSession = impressionCountInSession+1
    }
    
    // Session duration
    func sessionDuration() -> Int {
        let interval = Date().timeIntervalSince(dateSessionStarted)
        let duration = Int(interval)
        return duration
    }
    
    // Load product data
    func getProductForTag(tag: String, show: Bool, completionHandler: @escaping (Bool, Error?, Product?) -> Void){
        let size = screenWidthPixelsInPortraitOrientation().description
        var urlString = apiUrl+"products/tag/"+tag+"?size="+size
        if language != nil {
            urlString = urlString+"?language="+language!
        }
        Alamofire.request(URL(string: urlString)!, headers: headers).responseProduct { response in
            if let retrievedProduct = response.result.value {
                //var product: Product?
                if retrievedProduct.data != nil {
                    if show == true {
                        let product = retrievedProduct
                        self.openProductViewForProduct(product: product, tag: tag)
                    }
                    completionHandler(true, nil, retrievedProduct)
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.result.error as? URLError {
                print("URLError occurred: \(error)")
                completionHandler(false, error, nil)
            }
            else {
                print("Unknown error: \(String(describing: response.result.error))")
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Open product View
    func openProductViewForProduct(product: Product, tag: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let productViewController = ProductViewController()
            productViewController.modalPresentationStyle = .overCurrentContext
            productViewController.product = product
            productViewController.tag = tag
            topController.present(productViewController, animated: true, completion: nil)
        }
    }
    
    // Checkout variant for product
    func checkoutSelectedVariantForProduct(selectedVariant: PurpleNode, tag: String, completionHandler: @escaping (Bool, Error?, Checkout?) -> Void) {
        let urlString = apiUrl+"products/checkout"
        var parameters: [String: String] = [
            "product_handle" : tag,
            "variantId" : selectedVariant.id!,
            "quantity" : "1",
        ]
        if language != nil {
            parameters["language"] = language
        }
        
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseCheckout { response in
            if let responseCheckout = response.result.value {
                if responseCheckout.data != nil {
                    completionHandler(true, nil, responseCheckout)
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.result.error as? URLError {
                print("URLError occurred: \(error)")
                completionHandler(false, error, nil)
            }
            else {
                print("Unknown error: \(String(describing: response.result.error))")
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Track app version
    func trackAppVersion() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let versionOfLastRun = UserDefaults.standard.object(forKey: "MonetizrAppVersionOfLastRun") as? String
        if versionOfLastRun == nil {
            // First start after installing the app
            self.installCreate(deviceIdentifier: deviceIdentifier(), completionHandler: {_,_,_ in })
        } else if versionOfLastRun != currentVersion {
            // App was updated since last run
            self.updateCreate(deviceIdentifier: deviceIdentifier(), bundleVersion: currentVersion!, completionHandler: {_,_,_ in })
        } else {
            // nothing changed
        }
        UserDefaults.standard.set(currentVersion, forKey: "MonetizrAppVersionOfLastRun")
        UserDefaults.standard.synchronize()
    }
    
    /* Metrics section */
    // Create a new entry for device data
    func devicedataCreate(completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        let data = deviceData()
        let urlString = apiUrl+"telemetric/devicedata"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for impressionvisible
    func impressionvisibleCreate(tag: String?, fromDate:Date?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        let interval = Date().timeIntervalSince(fromDate!)
        let duration = Int(interval*1000)
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        data["time_until_dismiss"] = duration
        let urlString = apiUrl+"telemetric/impressionvisible"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for clickreward
    func clickrewardCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        let urlString = apiUrl+"telemetric/clickreward"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for design
    func designCreate(numberOfTriggers: Int?, funnelTriggerList: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["number_of_triggers"] = numberOfTriggers
        data["funnel_trigger_list"] = funnelTriggerList
        let urlString = apiUrl+"telemetric/design"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for dismiss
    func dismissCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        let urlString = apiUrl+"telemetric/dismiss"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for install
    func installCreate(deviceIdentifier: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["installed"] = true
        let urlString = apiUrl+"telemetric/install"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for update
    func updateCreate(deviceIdentifier: String, bundleVersion: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["bundle_version"] = bundleVersion
        let urlString = apiUrl+"telemetric/update"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for update
    func firstimpressionCreate(sessionDuration: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_shown"] = sessionDuration
        let urlString = apiUrl+"telemetric/firstimpression"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for playerbehaviour
    func playerbehaviourCreate(deviceIdentifier: String, gameProgress: Int?, sessionDuration: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        if (gameProgress != nil) {
            data["game_progress"] = gameProgress
        }
        data["session_time"] = sessionDuration
        let urlString = apiUrl+"telemetric/playerbehaviour"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for purchase
    func purchaseCreate(deviceIdentifier: String, triggerTag: String?, productPrice: String?, currency: String?, country: String?, city: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["trigger_tag"] = triggerTag
        data["product_price"] = productPrice
        data["currency"] = currency
        data["country"] = country
        data["city"] = city
        let urlString = apiUrl+"telemetric/purchase"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for session end
    func sessionEnd(deviceIdentifier: String, startDate: String?, endDate: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["session_start"] = startDate
        data["session_end"] = endDate
        let urlString = apiUrl+"telemetric/session/session_end"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Monetizr date string
    func stringFromDate(date: Date) -> String {
        // MOnetizr requirements "%Y-%m-%d %H:%M:%S.%f", 2019-03-08 14:44:57.08809+02
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSX"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let datestring = dateFormatter.string(from: date)
        return datestring
    }
}
