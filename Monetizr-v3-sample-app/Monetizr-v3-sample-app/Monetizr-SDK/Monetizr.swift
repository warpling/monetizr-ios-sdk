//
//  Monetizr.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 20/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

class Monetizr {
    
    static let shared = Monetizr(token: "")
    
    var token: String
    
    // Initialization
    
    private init(token: String) {
        self.token = token
    }
    
    func openProductForTag(tag: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let productViewController = ProductViewController()
            productViewController.token = token
            productViewController.tag = tag
            productViewController.modalPresentationStyle = .overCurrentContext
            topController.present(productViewController, animated: true, completion: nil)
        }
        
    }
    
}
