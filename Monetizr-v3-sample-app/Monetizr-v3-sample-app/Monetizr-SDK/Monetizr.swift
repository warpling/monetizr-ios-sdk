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
    
    // Initialization
    private init(token: String) {
        self.token = token
        DispatchQueue.main.async { self.createHeaders() }
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
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
        print("App moved to ForeGround!")
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
    func impressionvisibleCreate(tag: String, fromDate:Date, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        let interval = Date().timeIntervalSince(fromDate)
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
    func clickrewardCreate(tag: String, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
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
}
